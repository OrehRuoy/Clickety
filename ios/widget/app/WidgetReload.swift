import ObjectiveC
import UIKit
import WidgetKit

/// Added to the APP target by tools/ios/add_widget_target.rb. The WidgetBridge plugin (ObjC++) calls this C symbol.
@_cdecl("clickety_widget_reload")
public func clickety_widget_reload() {
    ClicketyUnlockRoute.install()
    WidgetCenter.shared.reloadAllTimelines()
}

/// A locked-widget tap opens clickety://unlock. Godot 4.6 receives that URL and then drops it,
/// so this records it first. The app reads that note the next time it comes forward.
private enum ClicketyUnlockRoute {
    private static var installed = false

    static func install() {
        if installed { return }
        guard let delegate = NSClassFromString("GDTApplicationDelegate") else { return }
        installed = true
        swizzleOpen(delegate)
        swizzleConnect(delegate)
        swizzleLegacy(delegate)
    }

    private static func swizzleOpen(_ cls: AnyClass) {
        let sel = NSSelectorFromString("scene:openURLContexts:")
        guard let method = class_getInstanceMethod(cls, sel) else {
            let block: @convention(block) (AnyObject, UIScene, Set<UIOpenURLContext>) -> Void = { _, _, contexts in
                contexts.forEach { note($0.url) }
            }
            class_addMethod(cls, sel, imp_implementationWithBlock(block), "v@:@@")
            return
        }
        typealias Orig = @convention(c) (AnyObject, Selector, UIScene, Set<UIOpenURLContext>) -> Void
        let orig = unsafeBitCast(method_getImplementation(method), to: Orig.self)
        let block: @convention(block) (AnyObject, UIScene, Set<UIOpenURLContext>) -> Void = { obj, scene, contexts in
            contexts.forEach { note($0.url) }
            orig(obj, sel, scene, contexts)
        }
        method_setImplementation(method, imp_implementationWithBlock(block))
    }

    private static func swizzleConnect(_ cls: AnyClass) {
        let sel = NSSelectorFromString("scene:willConnectToSession:options:")
        guard let method = class_getInstanceMethod(cls, sel) else { return }
        typealias Orig = @convention(c) (AnyObject, Selector, UIScene, UISceneSession, UIScene.ConnectionOptions) -> Void
        let orig = unsafeBitCast(method_getImplementation(method), to: Orig.self)
        let block: @convention(block) (AnyObject, UIScene, UISceneSession, UIScene.ConnectionOptions) -> Void = { obj, scene, session, options in
            options.urlContexts.forEach { note($0.url) }
            orig(obj, sel, scene, session, options)
        }
        method_setImplementation(method, imp_implementationWithBlock(block))
    }

    private static func swizzleLegacy(_ cls: AnyClass) {
        let sel = NSSelectorFromString("application:openURL:options:")
        guard let method = class_getInstanceMethod(cls, sel) else { return }
        typealias Orig = @convention(c) (AnyObject, Selector, UIApplication, URL, [UIApplication.OpenURLOptionsKey: Any]) -> Bool
        let orig = unsafeBitCast(method_getImplementation(method), to: Orig.self)
        let block: @convention(block) (AnyObject, UIApplication, URL, [UIApplication.OpenURLOptionsKey: Any]) -> Bool = { obj, app, url, options in
            note(url)
            return orig(obj, sel, app, url, options)
        }
        method_setImplementation(method, imp_implementationWithBlock(block))
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

private let clicketyUnlockRouteInstalled: Void = ClicketyUnlockRoute.install()
