//
//  TimerActivityAttributes.swift
//  ScreenTimeTimer
//
//  Activity attributes for the Live Activity timer.
//  This file must be added to: Main App, TimerActivityExtension, DeviceActivityMonitorExtension
//

import Foundation
import ActivityKit

// MARK: - Timer Activity Attributes
public struct TimerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var appDisplayName: String
        public var sessionStartDate: Date

        public init(appDisplayName: String, sessionStartDate: Date) {
            self.appDisplayName = appDisplayName
            self.sessionStartDate = sessionStartDate
        }
    }

    public var trackedAppIdentifier: String

    public init(trackedAppIdentifier: String) {
        self.trackedAppIdentifier = trackedAppIdentifier
    }
}

// MARK: - Preview Helpers
#if DEBUG
extension TimerActivityAttributes {
    public static var preview: TimerActivityAttributes {
        TimerActivityAttributes(trackedAppIdentifier: "preview_app")
    }
}

extension TimerActivityAttributes.ContentState {
    public static var preview: TimerActivityAttributes.ContentState {
        TimerActivityAttributes.ContentState(
            appDisplayName: "Social App",
            sessionStartDate: Date().addingTimeInterval(-127)
        )
    }
}
#endif
