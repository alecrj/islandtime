//
//  DeviceActivityMonitorExtension.swift
//  DeviceActivityMonitorExtension
//
//  Monitors selected apps and triggers Live Activities.
//

import DeviceActivity
import ManagedSettings
import Foundation
import ActivityKit

// MARK: - Device Activity Monitor Extension
class DeviceActivityMonitorExtension: DeviceActivityMonitor {

    private let storage = AppGroupStorage.shared

    // MARK: - Schedule Lifecycle

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        print("[Monitor] Interval started for: \(activity.rawValue)")

        // Reset today's total at the start of a new day
        // (The schedule runs midnight to midnight)
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        print("[Monitor] Interval ended for: \(activity.rawValue)")

        // End any active Live Activity when the monitoring interval ends
        Task {
            await LiveActivityManager.shared.endAllActivities()
        }
    }

    // MARK: - Event Threshold Reached

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        print("[Monitor] Event threshold reached: \(event.rawValue)")

        // Check if monitoring is enabled
        guard storage.isMonitoringEnabled else {
            print("[Monitor] Monitoring disabled, ignoring event")
            return
        }

        // Extract app index from event name (format: "app_active_X")
        let eventString = event.rawValue
        if eventString.hasPrefix("app_active_") {
            handleAppBecameActive(eventName: eventString)
        }
    }

    // MARK: - Handle App Activity

    private func handleAppBecameActive(eventName: String) {
        // Extract the app index from the event name
        guard let indexString = eventName.split(separator: "_").last,
              let appIndex = Int(indexString) else {
            print("[Monitor] Could not parse app index from event: \(eventName)")
            return
        }

        // Get the selected apps
        let selection = storage.loadSelectedApps()
        let tokens = Array(selection.applicationTokens)

        guard appIndex < tokens.count else {
            print("[Monitor] App index \(appIndex) out of bounds")
            return
        }

        // We have a tracked app becoming active
        // Start a Live Activity
        Task {
            // Generate a display name (tokens are opaque, so we use a generic label)
            let displayName = "App \(appIndex + 1)"
            let identifier = "tracked_app_\(appIndex)"

            _ = await LiveActivityManager.shared.startActivity(
                appDisplayName: displayName,
                appIdentifier: identifier
            )

            print("[Monitor] Started Live Activity for app index: \(appIndex)")
        }
    }

    // MARK: - Warning Callbacks (Optional)

    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        // Called before interval starts (if configured)
    }

    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        // Called before interval ends (if configured)
    }

    override func eventWillReachThresholdWarning(
        _ event: DeviceActivityEvent.Name,
        activity: DeviceActivityName
    ) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        // Called before threshold is reached (if configured)
    }
}
