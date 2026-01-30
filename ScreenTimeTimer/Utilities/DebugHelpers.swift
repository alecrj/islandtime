//
//  DebugHelpers.swift
//  ScreenTimeTimer
//
//  Debug utilities for development. Remove or disable in production.
//

import Foundation
import ActivityKit

#if DEBUG
enum DebugHelpers {
    /// Manually start a test Live Activity (for development testing)
    static func startTestLiveActivity() async {
        _ = await LiveActivityManager.shared.startActivity(
            appDisplayName: "Test App",
            appIdentifier: "debug_test"
        )
    }

    /// End all Live Activities (for development testing)
    static func endAllLiveActivities() async {
        await LiveActivityManager.shared.endAllActivities()
    }

    /// Add test minutes to today's total
    static func addTestMinutes(_ minutes: Int) {
        AppGroupStorage.shared.addMinutesToToday(minutes)
    }

    /// Reset today's total
    static func resetTodayTotal() {
        AppGroupStorage.shared.saveTodayTotal(minutes: 0)
    }

    /// Print current storage state
    static func printStorageState() {
        let storage = AppGroupStorage.shared
        print("=== Storage State ===")
        print("Onboarding completed: \(storage.hasCompletedOnboarding)")
        print("Monitoring enabled: \(storage.isMonitoringEnabled)")
        print("Selected apps count: \(storage.loadSelectedApps().applicationTokens.count)")
        print("Today total: \(storage.loadTodayTotal()) minutes")
        if let session = storage.loadActiveSession() {
            print("Active session start: \(session.startDate)")
        } else {
            print("No active session")
        }
        print("=====================")
    }
}
#endif
