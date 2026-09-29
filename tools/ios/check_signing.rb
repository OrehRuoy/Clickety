#!/usr/bin/env ruby
# Clickety: print per-target Release signing and fail if a target has the wrong profile.
# Usage: ruby tools/ios/check_signing.rb <xcodeproj> <app_profile_name> <widget_profile_name>
require 'xcodeproj'
proj_path, app_profile, widget_profile = ARGV
abort 'usage: check_signing.rb <xcodeproj> <app_profile_name> <widget_profile_name>' unless proj_path && app_profile && widget_profile
project = Xcodeproj::Project.open(proj_path)
ok = true
puts format('%-18s %-42s %-8s %-22s %s', 'TARGET', 'BUNDLE ID', 'STYLE', 'IDENTITY', 'PROFILE')
project.targets.each do |t|
  c = t.build_configurations.find { |x| x.name == 'Release' }
  next unless c
  s = c.build_settings
  prof = s['PROVISIONING_PROFILE_SPECIFIER'].to_s
  puts format('%-18s %-42s %-8s %-22s %s', t.name, s['PRODUCT_BUNDLE_IDENTIFIER'], s['CODE_SIGN_STYLE'], s['CODE_SIGN_IDENTITY'], prof)
  if t.respond_to?(:product_type) && t.product_type == 'com.apple.product-type.application'
    (ok = false; warn "ERROR: app target #{t.name} uses \"#{prof}\", expected \"#{app_profile}\"") unless prof == app_profile
  elsif t.name == 'ClicketyWidget'
    (ok = false; warn "ERROR: widget uses \"#{prof}\", expected \"#{widget_profile}\"") unless prof == widget_profile
    (ok = false; warn 'ERROR: widget CODE_SIGN_STYLE must be Manual') unless s['CODE_SIGN_STYLE'] == 'Manual'
  end
end
abort 'Signing check FAILED' unless ok
puts 'Signing check OK'
