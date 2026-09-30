import SwiftUI
import WidgetKit

struct CountEntry: TimelineEntry {
    let date: Date
    let snap: Snapshot?
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> CountEntry {
        var s = Snapshot()
        s.unlocked = true; s.project = "Holiday socks"; s.value = 42; s.target = 60
        s.repeat_name = "Pattern row"; s.repeat_value = 3; s.repeat_of = 8
        return CountEntry(date: Date(), snap: s)
    }
    func getSnapshot(in context: Context, completion: @escaping (CountEntry) -> Void) {
        completion(context.isPreview ? placeholder(in: context) : CountEntry(date: Date(), snap: SharedStore.load()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<CountEntry>) -> Void) {
        // .never: the app calls WidgetCenter.reloadAllTimelines() after it saves.
        completion(Timeline(entries: [CountEntry(date: Date(), snap: SharedStore.load())], policy: .never))
    }
}

private let cream = Color(red: 0.984, green: 0.965, blue: 0.933)
private let ink = Color(red: 0.118, green: 0.106, blue: 0.094)
private let terracotta = Color(red: 0.706, green: 0.286, blue: 0.180)
private let nightAccent = Color(red: 0.898, green: 0.541, blue: 0.420)

struct CountView: View {
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) private var scheme
    let entry: CountEntry

    private var paper: Color {
        scheme == .dark ? Color(red: 0.086, green: 0.078, blue: 0.071) : cream
    }

    private var label: Color {
        scheme == .dark ? Color(red: 0.953, green: 0.925, blue: 0.886) : ink
    }

    private var accent: Color {
        scheme == .dark ? nightAccent : terracotta
    }

    private var onAccent: Color {
        scheme == .dark ? Color(red: 0.086, green: 0.078, blue: 0.071) : Color.white
    }

    private func progressBar(_ s: Snapshot) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(label.opacity(0.14))
                Capsule().fill(accent)
                    .frame(width: max(6, geo.size.width * CGFloat(min(s.value, s.target)) / CGFloat(max(1, s.target))))
            }
        }
        .frame(height: 6)
    }

    var body: some View {
        content
            .widgetBackground(isAccessory: isAccessory, paper: paper)
            .widgetURL(URL(string: "clickety://open"))
    }

    private var isAccessory: Bool {
        family == .accessoryInline || family == .accessoryCircular || family == .accessoryRectangular
    }

    @ViewBuilder private var content: some View {
        if let s = entry.snap, s.unlocked {
            counted(s)
        } else {
            let msg = entry.snap == nil ? "Open Clickety" : "Unlock in Clickety"
            switch family {
            case .accessoryInline: Text(msg)
            case .accessoryCircular: Image(systemName: "lock.fill")
            default:
                VStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .frame(width: 48, height: 48)
                        .background(Circle().fill(accent.opacity(0.16)))
                        .foregroundColor(accent)
                    Text(msg)
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(label)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }

    private func repeatText(_ s: Snapshot) -> String? {
        guard !s.repeat_name.isEmpty else { return nil }
        return s.repeat_of > 0 ? "\(s.repeat_name) \(s.repeat_value)/\(s.repeat_of)" : "\(s.repeat_name) \(s.repeat_value)"
    }

    @ViewBuilder private func counted(_ s: Snapshot) -> some View {
        switch family {
        case .accessoryInline:
            Text([ "\(s.counter) \(s.value)", repeatText(s) ].compactMap { $0 }.joined(separator: " · "))
        case .accessoryCircular:
            if s.target > 0 {
                Gauge(value: Double(min(s.value, s.target)), in: 0...Double(s.target)) {
                    Text(s.counter)
                } currentValueLabel: {
                    Text("\(s.value)")
                }
                .gaugeStyle(.accessoryCircularCapacity)
            } else {
                ZStack {
                    AccessoryWidgetBackground()
                    Text("\(s.value)").font(.title2.bold()).minimumScaleFactor(0.5)
                }
            }
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 1) {
                Text(s.project).font(.headline).lineLimit(1)
                Text(s.target > 0 ? "\(s.counter) \(s.value) / \(s.target)" : "\(s.counter) \(s.value)")
                    .font(.title3.bold()).lineLimit(1).minimumScaleFactor(0.6)
                if let r = repeatText(s) { Text(r).font(.caption).lineLimit(1) }
            }
        default:
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(s.project)
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundColor(accent).lineLimit(1)
                    Text("\(s.value)").font(.system(size: 54, weight: .bold, design: .rounded))
                        .foregroundColor(label).minimumScaleFactor(0.4).lineLimit(1)
                    if s.target > 0 { progressBar(s) }
                    Text(s.target > 0 ? "\(s.counter) of \(s.target)" : s.counter)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(label.opacity(0.75)).lineLimit(1)
                    if let r = repeatText(s) {
                        Text(r).font(.system(.caption2, design: .rounded)).foregroundColor(label.opacity(0.65)).lineLimit(1)
                    }
                }
                if family == .systemMedium {
                    Spacer()
                    plusButton
                }
            }
        }
    }

    @ViewBuilder private var plusButton: some View {
        if #available(iOS 17.0, *) {
            Button(intent: IncrementIntent()) {
                Image(systemName: "plus").font(.system(size: 30, weight: .bold))
                    .frame(width: 68, height: 68)
                    .background(Circle().fill(accent)).foregroundColor(onAccent)
            }
            .buttonStyle(.plain)
        }
    }
}

extension View {
    @ViewBuilder func widgetBackground(isAccessory: Bool, paper: Color) -> some View {
        if #available(iOS 17.0, *) {
            if isAccessory { self.containerBackground(for: .widget) { Color.clear } }
            else { self.containerBackground(for: .widget) { paper } }
        } else {
            if isAccessory { self } else { self.padding().background(paper) }
        }
    }
}

struct ClicketyCountWidget: Widget {
    let kind = "ClicketyCount"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CountView(entry: entry)
        }
        .configurationDisplayName("Clickety")
        .description("Keep your row count on the Home Screen or Lock Screen.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryInline, .accessoryCircular, .accessoryRectangular])
    }
}

@main
struct ClicketyWidgets: WidgetBundle {
    var body: some Widget {
        ClicketyCountWidget()
    }
}
