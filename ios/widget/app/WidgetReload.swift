import ObjectiveC
import UIKit
import WidgetKit

/// Added to the APP target by tools/ios/add_widget_target.rb. The WidgetBridge plugin (ObjC++) calls this C symbol.
@_cdecl("clickety_widget_reload")
public func clickety_widget_reload() {
    WidgetCenter.shared.reloadAllTimelines()
}

/// A locked-widget tap opens clickety://unlock. Godot 4.6 does not forward that URL into GDScript,
/// so this records it in the App Group. The app reads that note the next time it comes forward.
private enum ClicketyUnlockRoute {
    static let install: Void = {
        guard let delegate = NSClassFromString("GDTApplicationDelegate") else { return }
        add(delegate, "scene:openURLContexts:", "v@:@@", openContexts)
        add(delegate, "scene:willConnectToSession:options:", "v@:@@@", connectOptions)
        add(delegate, "application:openURL:options:", "v@:@@@", openURL)
    }()

    private static func add(_ cls: AnyClass, _ name: String, _ types: UnsafePointer<CChar>, _ block: Any) {
        let sel = NSSelectorFromString(name)
        guard !class_respondsToSelector(cls, sel) else { return }
        class_addMethod(cls, sel, imp_implementationWithBlock(block), types)
    }

    private static let openContexts: @convention(block) (Any, UIScene, Set<UIOpenURLContext>) -> Void = { _, _, contexts in
        contexts.forEach { note($0.url) }
    }

    private static let connectOptions: @convention(block) (Any, UIScene, UISceneSession, UIScene.ConnectionOptions) -> Void = { _, _, _, options in
        options.urlContexts.forEach { note($0.url) }
    }

    private static let openURL: @convention(block) (Any, UIApplication, URL, [UIApplication.OpenURLOptionsKey: Any]) -> Void = { _, _, url, _ in
        note(url)
    }

    private static func note(_ url: URL) {
        guard url.scheme == "clickety", url.host == "unlock" else { return }
        guard let group = Bundle.main.object(forInfoDictionaryKey: "ClicketyAppGroup") as? String,
              let defaults = UserDefaults(suiteName: group) else { return }
        var list: [[String: Any]] = []
        if let raw = defaults.string(forKey: "pending"),
           let data = raw.data(using: .utf8),
           let parsed = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            list = parsed
        }
        list.append(["route": "unlock", "t": Date().timeIntervalSince1970])
        guard let out = try? JSONSerialization.data(withJSONObject: list),
              let text = String(data: out, encoding: .utf8) else { return }
        defaults.set(text, forKey: "pending")
    }
}

private let clicketyUnlockRouteInstalled: Void = ClicketyUnlockRoute.install
