import Foundation

/// Written by the Godot app (WidgetBridge.write_snapshot) as a JSON string under "snapshot".
/// Decoding is tolerant: any missing key falls back to a default, so app/widget versions can drift.
struct Snapshot: Codable {
    var v: Int = 1
    var unlocked: Bool = false
    var project: String = ""
    var counter: String = "Row"
    var value: Int = 0
    var target: Int = 0
    var repeat_name: String = ""
    var repeat_value: Int = 0
    var repeat_of: Int = 0
    var project_id: String = ""
    var counter_id: String = ""
    var updated: Double = 0

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        v = (try? c.decodeIfPresent(Int.self, forKey: .v)) ?? 1
        unlocked = (try? c.decodeIfPresent(Bool.self, forKey: .unlocked)) ?? false
        project = (try? c.decodeIfPresent(String.self, forKey: .project)) ?? ""
        counter = (try? c.decodeIfPresent(String.self, forKey: .counter)) ?? "Row"
        value = (try? c.decodeIfPresent(Int.self, forKey: .value)) ?? 0
        target = (try? c.decodeIfPresent(Int.self, forKey: .target)) ?? 0
        repeat_name = (try? c.decodeIfPresent(String.self, forKey: .repeat_name)) ?? ""
        repeat_value = (try? c.decodeIfPresent(Int.self, forKey: .repeat_value)) ?? 0
        repeat_of = (try? c.decodeIfPresent(Int.self, forKey: .repeat_of)) ?? 0
        project_id = (try? c.decodeIfPresent(String.self, forKey: .project_id)) ?? ""
        counter_id = (try? c.decodeIfPresent(String.self, forKey: .counter_id)) ?? ""
        updated = (try? c.decodeIfPresent(Double.self, forKey: .updated)) ?? 0
    }
}

/// App Group storage shared with the app. The group id comes from Info.plist (ClicketyAppGroup), never hardcoded.
enum SharedStore {
    static var groupId: String {
        (Bundle.main.object(forInfoDictionaryKey: "ClicketyAppGroup") as? String) ?? ""
    }
    static var defaults: UserDefaults? {
        groupId.isEmpty ? nil : UserDefaults(suiteName: groupId)
    }

    static func load() -> Snapshot? {
        guard let s = defaults?.string(forKey: "snapshot"), let data = s.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(Snapshot.self, from: data)
    }

    /// Re-reads snapshot and pending immediately before writing. Appends one +1 and keeps the last 500.
    static func bump() {
        guard let d = defaults else { return }
        guard let raw = d.string(forKey: "snapshot"),
              let data = raw.data(using: .utf8),
              var snap = try? JSONDecoder().decode(Snapshot.self, from: data),
              snap.unlocked else { return }
        var list: [[String: Any]] = []
        if let pending = d.string(forKey: "pending"),
           let pdata = pending.data(using: .utf8),
           let arr = try? JSONSerialization.jsonObject(with: pdata) as? [[String: Any]] {
            list = arr
        }
        snap.value += 1
        snap.updated = Date().timeIntervalSince1970
        list.append([
            "project_id": snap.project_id,
            "counter_id": snap.counter_id,
            "d": 1,
            "t": snap.updated
        ])
        if list.count > 500 {
            list.removeFirst(list.count - 500)
        }
        save(snap)
        if let out = try? JSONSerialization.data(withJSONObject: list),
           let text = String(data: out, encoding: .utf8) {
            d.set(text, forKey: "pending")
        }
    }

    static func save(_ snap: Snapshot) {
        guard let data = try? JSONEncoder().encode(snap), let s = String(data: data, encoding: .utf8) else { return }
        defaults?.set(s, forKey: "snapshot")
    }

    /// Appends one +1 for the app to merge on launch/resume. Re-reads right before writing (minimise the race).
    static func appendPending(projectId: String, counterId: String) {
        guard let d = defaults else { return }
        var list: [[String: Any]] = []
        if let s = d.string(forKey: "pending"), let data = s.data(using: .utf8),
           let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            list = arr
        }
        list.append(["project_id": projectId, "counter_id": counterId, "d": 1, "t": Date().timeIntervalSince1970])
        if list.count > 500 { list.removeFirst(list.count - 500) }
        if let out = try? JSONSerialization.data(withJSONObject: list), let s = String(data: out, encoding: .utf8) {
            d.set(s, forKey: "pending")
        }
    }

    /// Queues an unlock open for the app. The app reads pending the next time it comes forward.
    static func requestUnlock() {
        guard let d = defaults else { return }
        var list: [[String: Any]] = []
        if let s = d.string(forKey: "pending"), let data = s.data(using: .utf8),
           let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            list = arr
        }
        list.append(["route": "unlock", "t": Date().timeIntervalSince1970])
        if let out = try? JSONSerialization.data(withJSONObject: list), let s = String(data: out, encoding: .utf8) {
            d.set(s, forKey: "pending")
        }
    }
}
