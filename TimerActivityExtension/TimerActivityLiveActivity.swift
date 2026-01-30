//
//  TimerActivityLiveActivity.swift
//  TimerActivityExtension
//
//  Live Activity UI for Dynamic Island and Lock Screen banner.
//  Requires: TimerActivityAttributes.swift, TimerCustomization.swift
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TimerActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerActivityAttributes.self) { context in
            // Lock Screen / Banner UI
            LockScreenBannerView(
                state: context.state,
                style: context.attributes.timerStyle
            )
            .activityBackgroundTint(Color.black.opacity(0.9))
            .activitySystemActionForegroundColor(Color.white)

        } dynamicIsland: { context in
            let accentColor = context.state.timerColor.color
            let style = context.attributes.timerStyle

            DynamicIsland {
                // Expanded Region - Leading
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(accentColor.opacity(0.2))
                                .frame(width: 36, height: 36)

                            Image(systemName: "app.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(accentColor)
                        }

                        if style != .minimal {
                            VStack(alignment: .leading, spacing: 1) {
                                Text(context.state.appDisplayName)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .lineLimit(1)

                                if style == .detailed {
                                    Text("Session")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

                // Expanded Region - Trailing
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(context.state.sessionStartDate, style: .timer)
                            .font(.system(size: style == .compact ? 24 : 28, weight: .bold, design: .monospaced))
                            .foregroundStyle(accentColor)
                            .monospacedDigit()

                        if style == .detailed {
                            Text("elapsed")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Expanded Region - Center
                DynamicIslandExpandedRegion(.center) {
                    EmptyView()
                }

                // Expanded Region - Bottom
                DynamicIslandExpandedRegion(.bottom) {
                    if style == .detailed {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(accentColor)
                                .frame(width: 6, height: 6)

                            Text("Timer running")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 4)
                    }
                }

            } compactLeading: {
                // Compact Leading (left side of pill)
                Image(systemName: "timer")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(accentColor)

            } compactTrailing: {
                // Compact Trailing (right side of pill)
                Text(context.state.sessionStartDate, style: .timer)
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundStyle(accentColor)
                    .monospacedDigit()
                    .frame(minWidth: 44)

            } minimal: {
                // Minimal (smallest representation)
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.3))
                    Image(systemName: "timer")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(accentColor)
                }
            }
            .keylineTint(accentColor)
        }
    }
}

// MARK: - Lock Screen Banner View
struct LockScreenBannerView: View {
    let state: TimerActivityAttributes.ContentState
    let style: TimerStyle

    private var accentColor: Color {
        state.timerColor.color
    }

    var body: some View {
        HStack(spacing: 16) {
            // App icon
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.2))
                    .frame(width: style == .compact ? 40 : 48, height: style == .compact ? 40 : 48)

                Image(systemName: "app.fill")
                    .font(.system(size: style == .compact ? 18 : 22))
                    .foregroundStyle(accentColor)
            }

            // Info
            if style != .minimal {
                VStack(alignment: .leading, spacing: 4) {
                    Text(state.appDisplayName)
                        .font(style == .compact ? .subheadline : .headline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)

                    if style == .detailed {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(accentColor)
                                .frame(width: 6, height: 6)
                            Text("Session active")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                }
            }

            Spacer()

            // Timer
            VStack(alignment: .trailing, spacing: 2) {
                Text(state.sessionStartDate, style: .timer)
                    .font(.system(size: style == .compact ? 28 : 32, weight: .bold, design: .monospaced))
                    .foregroundStyle(accentColor)
                    .monospacedDigit()

                if style == .detailed {
                    Text("elapsed")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, style == .compact ? 12 : 16)
    }
}

// MARK: - Previews
#Preview("Lock Screen Banner - Blue", as: .content, using: TimerActivityAttributes.preview) {
    TimerActivityLiveActivity()
} contentStates: {
    TimerActivityAttributes.ContentState.preview
}

#Preview("Lock Screen Banner - Orange", as: .content, using: TimerActivityAttributes.preview) {
    TimerActivityLiveActivity()
} contentStates: {
    TimerActivityAttributes.ContentState.previewOrange
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
