//
//  TimerActivityLiveActivity.swift
//  TimerActivityExtension
//
//  Live Activity UI for Dynamic Island and Lock Screen banner.
//  Requires: TimerActivityAttributes.swift to be added to this target
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TimerActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerActivityAttributes.self) { context in
            // Lock Screen / Banner UI
            LockScreenBannerView(state: context.state)
                .activityBackgroundTint(Color.black.opacity(0.9))
                .activitySystemActionForegroundColor(Color.white)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded Region - Leading
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 36, height: 36)

                            Image(systemName: "app.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.blue)
                        }

                        VStack(alignment: .leading, spacing: 1) {
                            Text(context.state.appDisplayName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .lineLimit(1)

                            Text("Session")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Expanded Region - Trailing
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(context.state.sessionStartDate, style: .timer)
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color.blue)
                            .monospacedDigit()

                        Text("elapsed")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                // Expanded Region - Center
                DynamicIslandExpandedRegion(.center) {
                    EmptyView()
                }

                // Expanded Region - Bottom
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 6) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundStyle(.green)

                        Text("Timer running")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 4)
                }

            } compactLeading: {
                // Compact Leading (left side of pill)
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.blue)
                }

            } compactTrailing: {
                // Compact Trailing (right side of pill)
                Text(context.state.sessionStartDate, style: .timer)
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.blue)
                    .monospacedDigit()
                    .frame(minWidth: 44)

            } minimal: {
                // Minimal (smallest representation)
                Image(systemName: "timer")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.blue)
            }
            .keylineTint(Color.blue)
        }
    }
}

// MARK: - Lock Screen Banner View
struct LockScreenBannerView: View {
    let state: TimerActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 16) {
            // App icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 48, height: 48)

                Image(systemName: "app.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Color.blue)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(state.appDisplayName)
                    .font(.headline)
                    .foregroundStyle(.white)

                HStack(spacing: 4) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .foregroundStyle(.green)
                    Text("Session active")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }

            Spacer()

            // Timer
            VStack(alignment: .trailing, spacing: 2) {
                Text(state.sessionStartDate, style: .timer)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.blue)
                    .monospacedDigit()

                Text("elapsed")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - Previews
#Preview("Lock Screen Banner", as: .content, using: TimerActivityAttributes.preview) {
    TimerActivityLiveActivity()
} contentStates: {
    TimerActivityAttributes.ContentState.preview
}

#Preview("Dynamic Island Compact", as: .dynamicIsland(.compact), using: TimerActivityAttributes.preview) {
    TimerActivityLiveActivity()
} contentStates: {
    TimerActivityAttributes.ContentState.preview
}

#Preview("Dynamic Island Expanded", as: .dynamicIsland(.expanded), using: TimerActivityAttributes.preview) {
    TimerActivityLiveActivity()
} contentStates: {
    TimerActivityAttributes.ContentState.preview
}

#Preview("Dynamic Island Minimal", as: .dynamicIsland(.minimal), using: TimerActivityAttributes.preview) {
    TimerActivityLiveActivity()
} contentStates: {
    TimerActivityAttributes.ContentState.preview
}
