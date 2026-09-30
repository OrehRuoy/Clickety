import AppIntents
import WidgetKit

/// iOS 17+ interactive "+1". Runs in the widget process: it updates the shown number and queues the tap;
/// the Godot app applies it (including linked/repeat counters) when it next launches or resumes.
@available(iOS 17.0, *)
struct IncrementIntent: AppIntent {
    static var title: LocalizedStringResource = "Add one row"
    static var description = IntentDescription("Adds one to the current Clickety counter.")

    func perform() async throws -> some IntentResult {
        // Re-read snapshot and pending, then write both. Shows main value + 1 only.
        // Linked counters and wraps are applied by the app when it merges pending.
        SharedStore.bump()
        return .result()
    }
}

/// The locked widget is one button. It asks the app to open Unlock, then brings Clickety forward.
@available(iOS 17.0, *)
struct OpenUnlockIntent: AppIntent {
    static var title: LocalizedStringResource = "Unlock Clickety"
    static var description = IntentDescription("Opens the Clickety purchase screen.")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        SharedStore.requestUnlock()
        return .result()
    }
}
