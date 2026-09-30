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
