#!/usr/bin/env ruby
# Clickety: add the ClicketyWidget WidgetKit extension to Godot's exported Xcode project (CI only).
# Usage: ruby tools/ios/add_widget_target.rb <build/Clickety.xcodeproj> <widget_bundle_id> <widget_profile_name> <team_id> <app_group>
# Run AFTER tools/ios/patch_xcode_signing.py (which would otherwise overwrite this target's profile).
require 'xcodeproj'
require 'fileutils'

proj_path, widget_id, widget_profile, team_id, app_group = ARGV
if [proj_path, widget_id, widget_profile, team_id, app_group].any? { |a| a.nil? || a.empty? }
  abort 'usage: add_widget_target.rb <xcodeproj> <widget_bundle_id> <widget_profile_name> <team_id> <app_group>'
end

repo    = File.expand_path(File.join(__dir__, '..', '..'))
srcroot = File.dirname(File.expand_path(proj_path))
project = Xcodeproj::Project.open(proj_path)

def fail!(msg)
  warn "ERROR (add_widget_target): #{msg}"
  exit 1
end

app = project.targets.find { |t| t.respond_to?(:product_type) && t.product_type == 'com.apple.product-type.application' }
fail!("no application target in #{proj_path}") unless app
if project.targets.any? { |t| t.name == 'ClicketyWidget' }
  puts 'ClicketyWidget target already present; nothing to do.'
  exit 0
end

release = app.build_configurations.find { |c| c.name == 'Release' } || fail!('app has no Release configuration')
resolve = ->(v) { v.to_s.gsub('$(SRCROOT)/', '').gsub('$(SRCROOT)', '').gsub('"', '') }
info_rel = resolve.call(release.build_settings['INFOPLIST_FILE'])
fail!('app INFOPLIST_FILE is not set') if info_rel.empty?
info_path = File.join(srcroot, info_rel)
fail!("app Info.plist not found at #{info_path}") unless File.exist?(info_path)
app_info  = Xcodeproj::Plist.read_from_path(info_path)
short_ver = app_info['CFBundleShortVersionString'] || fail!('CFBundleShortVersionString missing in app Info.plist')
build_ver = app_info['CFBundleVersion'] || fail!('CFBundleVersion missing in app Info.plist')
app_dir   = File.dirname(info_rel) # e.g. "Clickety"
puts "App target: #{app.name}  version #{short_ver} (#{build_ver})  folder #{app_dir}"

# 1) Copy widget sources into the exported project
wsrc = File.join(repo, 'ios', 'widget', 'ClicketyWidget')
fail!("missing #{wsrc}") unless Dir.exist?(wsrc)
wdst = File.join(srcroot, 'ClicketyWidget')
FileUtils.rm_rf(wdst)
FileUtils.cp_r(wsrc, wdst)
reload_src = File.join(repo, 'ios', 'widget', 'app', 'WidgetReload.swift')
fail!("missing #{reload_src}") unless File.exist?(reload_src)
FileUtils.cp(reload_src, File.join(srcroot, app_dir, 'WidgetReload.swift'))

# 2) Widget Info.plist: versions must equal the app's; group id for the Swift code
wplist_path = File.join(wdst, 'Info.plist')
wplist = Xcodeproj::Plist.read_from_path(wplist_path)
wplist['CFBundleShortVersionString'] = short_ver
wplist['CFBundleVersion'] = build_ver
wplist['ClicketyAppGroup'] = app_group
Xcodeproj::Plist.write_to_path(wplist, wplist_path)

# 3) Widget entitlements (generated, so the group id is never hardcoded in the repo)
went_path = File.join(wdst, 'ClicketyWidget.entitlements')
Xcodeproj::Plist.write_to_path({ 'com.apple.security.application-groups' => [app_group] }, went_path)

# 4) The target
widget = project.new_target(:app_extension, 'ClicketyWidget', :ios, '16.0', nil, :swift)
group = project.main_group.find_subpath('ClicketyWidget', true)
group.set_source_tree('<group>')
group.set_path('ClicketyWidget')
swift_refs = Dir[File.join(wdst, '*.swift')].sort.map { |f| group.new_reference(File.basename(f)) }
fail!('no .swift files in ios/widget/ClicketyWidget') if swift_refs.empty?
widget.add_file_references(swift_refs)
group.new_reference('Info.plist')
group.new_reference('ClicketyWidget.entitlements')
privacy = File.join(wdst, 'PrivacyInfo.xcprivacy')
widget.add_resources([group.new_reference('PrivacyInfo.xcprivacy')]) if File.exist?(privacy)
widget.add_system_framework('WidgetKit')
widget.add_system_framework('SwiftUI')

widget.build_configurations.each do |c|
  s = c.build_settings
  s['PRODUCT_BUNDLE_IDENTIFIER']      = widget_id
  s['PRODUCT_NAME']                   = 'ClicketyWidget'
  s['INFOPLIST_FILE']                 = 'ClicketyWidget/Info.plist'
  s['CODE_SIGN_ENTITLEMENTS']         = 'ClicketyWidget/ClicketyWidget.entitlements'
  s['CODE_SIGN_STYLE']                = 'Manual'
  s['CODE_SIGN_IDENTITY']             = 'Apple Distribution'
  s['DEVELOPMENT_TEAM']               = team_id
  s['PROVISIONING_PROFILE_SPECIFIER'] = widget_profile
  s['SWIFT_VERSION']                  = '5.0'
  s['IPHONEOS_DEPLOYMENT_TARGET']     = '16.0'
  s['TARGETED_DEVICE_FAMILY']         = '1,2'
  s['SKIP_INSTALL']                   = 'YES'
  s['APPLICATION_EXTENSION_API_ONLY'] = 'YES'
  s['GENERATE_INFOPLIST_FILE']        = 'NO'
  s['MARKETING_VERSION']              = short_ver
  s['CURRENT_PROJECT_VERSION']        = build_ver
  s['LD_RUNPATH_SEARCH_PATHS']        = ['$(inherited)', '@executable_path/Frameworks', '@executable_path/../../Frameworks']
  s['SDKROOT']                        = 'iphoneos'
end

# 5) Embed the .appex in the app (Copy Files -> PlugIns) + build dependency
embed = app.new_copy_files_build_phase('Embed App Extensions')
embed.symbol_dst_subfolder_spec = :plug_ins
bf = embed.add_file_reference(widget.product_reference, true)
bf.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
app.add_dependency(widget)

# 6) App side: reload hook, plus the unlock intent. openAppWhenRun runs that intent in the app,
# so the app target has to compile it too. The widget keeps its own copies.
app_group_ref = project.main_group.children.find { |g| g.respond_to?(:path) && g.path == app_dir } || project.main_group
app_swift = ['WidgetReload.swift']
%w[Snapshot.swift IncrementIntent.swift].each do |name|
  src = File.join(wsrc, name)
  fail!("missing #{src}") unless File.exist?(src)
  FileUtils.cp(src, File.join(srcroot, app_dir, name))
  app_swift << name
end
app_swift.each do |name|
  app.add_file_references([app_group_ref.new_reference(name)])
end
app.add_system_framework('WidgetKit')
app.add_system_framework('AppIntents')
app.build_configurations.each do |c|
  c.build_settings['SWIFT_VERSION'] ||= '5.0'
end

# 7) App entitlements: make sure the App Group is present (the preset adds it too; idempotent)
ent_rel = resolve.call(release.build_settings['CODE_SIGN_ENTITLEMENTS'])
if ent_rel.empty?
  ent_rel = File.join(app_dir, "#{app.name}.entitlements")
  app.build_configurations.each { |c| c.build_settings['CODE_SIGN_ENTITLEMENTS'] = ent_rel }
end
ent_path = File.join(srcroot, ent_rel)
ent = File.exist?(ent_path) ? Xcodeproj::Plist.read_from_path(ent_path) : {}
groups = Array(ent['com.apple.security.application-groups'])
groups << app_group unless groups.include?(app_group)
ent['com.apple.security.application-groups'] = groups
Xcodeproj::Plist.write_to_path(ent, ent_path)

project.save
puts "Added ClicketyWidget (#{widget_id}, profile \"#{widget_profile}\") embedded in #{app.name}; app group #{app_group}"
