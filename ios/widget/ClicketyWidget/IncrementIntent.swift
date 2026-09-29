import AppIntents
import WidgetKit

/// iOS 17+ interactive "+1". Runs in the widget process: it updates the shown number and queues the tap;
/// the Godot app applies it (including linked/repeat counters) when it next launches or resumes.
@available(iOS 17.0, *)
struct IncrementIntent: AppIntent {
    static var title: LocalizedStringResource = "Add one row"
    static var description = IntentDescription("Adds one to the current Clickety counter.")

    func perform() async throws -> some IntentResult {
        if var s = SharedStore.load(), s.unlocked {
            s.value += 1
            s.updated = Date().timeIntervalSince1970
            SharedStore.save(s)
            SharedStore.appendPending(projectId: s.project_id, counterId: s.counter_id)
        }
        return .result()  // WidgetKit reloads the widget after an intent runs
    }
}
