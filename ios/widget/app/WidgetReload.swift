import WidgetKit

/// Added to the APP target by tools/ios/add_widget_target.rb. The WidgetBridge plugin (ObjC++) calls this C symbol.
@_cdecl("clickety_widget_reload")
public func clickety_widget_reload() {
    WidgetCenter.shared.reloadAllTimelines()
}
