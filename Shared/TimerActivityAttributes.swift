//
//  TimerActivityAttributes.swift
//  IslandTime
//
//  Activity attributes for the Live Activity timer.
//  This file must be added to: Main App, TimerActivityExtension, DeviceActivityMonitorExtension
//

import Foundation
import ActivityKit
import SwiftUI

// MARK: - Timer Activity Attributes
public struct TimerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var appDisplayName: String
        public var sessionStartDate: Date
        public var timerColorRaw: String  // Store as string for Codable

        public var timerColor: TimerColor {
            TimerColor(rawValue: timerColorRaw) ?? .blue
        }

        public init(appDisplayName: String, sessionStartDate: Date, timerColor: TimerColor = .blue) {
            self.appDisplayName = appDisplayName
            self.sessionStartDate = sessionStartDate
            self.timerColorRaw = timerColor.rawValue
        }
    }

    public var trackedAppIdentifier: String
    public var timerStyleRaw: String  // Store as string for Codable

    public var timerStyle: TimerStyle {
        TimerStyle(rawValue: timerStyleRaw) ?? .detailed
    }

    public init(trackedAppIdentifier: String, timerStyle: TimerStyle = .detailed) {
        self.trackedAppIdentifier = trackedAppIdentifier
        self.timerStyleRaw = timerStyle.rawValue
    }
}

// MARK: - Preview Helpers
#if DEBUG
extension TimerActivityAttributes {
    public static var preview: TimerActivityAttributes {
        TimerActivityAttributes(trackedAppIdentifier: "preview_app", timerStyle: .detailed)
    }
}

extension TimerActivityAttributes.ContentState {
    public static var preview: TimerActivityAttributes.ContentState {
        TimerActivityAttributes.ContentState(
            appDisplayName: "Social App",
            sessionStartDate: Date().addingTimeInterval(-127),
            timerColor: .blue
        )
    }

    public static var previewOrange: TimerActivityAttributes.ContentState {
        TimerActivityAttributes.ContentState(
            appDisplayName: "Video App",
            sessionStartDate: Date().addingTimeInterval(-3600),
            timerColor: .orange
        )
    }
}
#endif
