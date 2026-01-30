//
//  ScreenTimeWidget.swift
//  ScreenTimeWidget
//
//  Lock Screen widget showing total screen time today.
//

import WidgetKit
import SwiftUI

// MARK: - Widget Entry
struct ScreenTimeEntry: TimelineEntry {
    let date: Date
    let totalMinutes: Int
    let isPlaceholder: Bool

    init(date: Date = Date(), totalMinutes: Int = 0, isPlaceholder: Bool = false) {
        self.date = date
        self.totalMinutes = totalMinutes
        self.isPlaceholder = isPlaceholder
    }
}

// MARK: - Timeline Provider
struct ScreenTimeProvider: TimelineProvider {
    private let storage = WidgetStorage.shared

    func placeholder(in context: Context) -> ScreenTimeEntry {
        ScreenTimeEntry(totalMinutes: 47, isPlaceholder: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (ScreenTimeEntry) -> Void) {
        let totalMinutes = storage.loadTodayTotal()
        let entry = ScreenTimeEntry(totalMinutes: totalMinutes)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ScreenTimeEntry>) -> Void) {
        let currentDate = Date()
        let totalMinutes = storage.loadTodayTotal()

        // Create entry for now
        let entry = ScreenTimeEntry(date: currentDate, totalMinutes: totalMinutes)

        // Schedule next update in 15 minutes (conservative per WidgetKit guidelines)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!

        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Widget View
struct ScreenTimeWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: ScreenTimeProvider.Entry

    var body: some View {
        switch family {
        case .accessoryCircular:
            AccessoryCircularView(entry: entry)
        case .accessoryRectangular:
            AccessoryRectangularView(entry: entry)
        case .accessoryInline:
            AccessoryInlineView(entry: entry)
        default:
            AccessoryRectangularView(entry: entry)
        }
    }
}

// MARK: - Circular Widget (Lock Screen)
struct AccessoryCircularView: View {
    let entry: ScreenTimeEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()

            VStack(spacing: 2) {
                Image(systemName: "timer")
                    .font(.system(size: 14, weight: .medium))

                Text(formattedTimeShort)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .minimumScaleFactor(0.6)
            }
        }
        .redacted(reason: entry.isPlaceholder ? .placeholder : [])
    }

    private var formattedTimeShort: String {
        let hours = entry.totalMinutes / 60
        let minutes = entry.totalMinutes % 60

        if hours > 0 {
            return "\(hours)h\(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Rectangular Widget (Lock Screen)
struct AccessoryRectangularView: View {
    let entry: ScreenTimeEntry

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "timer")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.primary)

            VStack(alignment: .leading, spacing: 2) {
                Text("Screen Time")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Text(formattedTime)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
            }

            Spacer()
        }
        .redacted(reason: entry.isPlaceholder ? .placeholder : [])
    }

    private var formattedTime: String {
        let hours = entry.totalMinutes / 60
        let minutes = entry.totalMinutes % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes) min"
        }
    }
}

// MARK: - Inline Widget
struct AccessoryInlineView: View {
    let entry: ScreenTimeEntry

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "timer")
            Text("Today: \(formattedTime)")
        }
        .redacted(reason: entry.isPlaceholder ? .placeholder : [])
    }

    private var formattedTime: String {
        let hours = entry.totalMinutes / 60
        let minutes = entry.totalMinutes % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Widget Configuration
struct ScreenTimeWidget: Widget {
    let kind: String = "ScreenTimeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ScreenTimeProvider()) { entry in
            ScreenTimeWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Screen Time")
        .description("Shows your total tracked screen time today.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

// MARK: - Previews
#Preview("Circular", as: .accessoryCircular) {
    ScreenTimeWidget()
} timeline: {
    ScreenTimeEntry(totalMinutes: 47)
    ScreenTimeEntry(totalMinutes: 127)
}

#Preview("Rectangular", as: .accessoryRectangular) {
    ScreenTimeWidget()
} timeline: {
    ScreenTimeEntry(totalMinutes: 47)
    ScreenTimeEntry(totalMinutes: 127)
}

#Preview("Inline", as: .accessoryInline) {
    ScreenTimeWidget()
} timeline: {
    ScreenTimeEntry(totalMinutes: 47)
}
