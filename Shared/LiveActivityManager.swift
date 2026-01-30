//
//  LiveActivityManager.swift
//  ScreenTimeTimer
//
//  Manages Live Activity lifecycle.
//  This file must be added to: Main App, DeviceActivityMonitorExtension
//

import Foundation
import ActivityKit

// MARK: - Live Activity Manager
public final class LiveActivityManager {
    public static let shared = LiveActivityManager()

    private init() {}

    // MARK: - Check Support

    public var areActivitiesEnabled: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    // MARK: - Start Activity

    @discardableResult
    public func startActivity(appDisplayName: String, appIdentifier: String) async -> String? {
        guard areActivitiesEnabled else {
            print("[LiveActivityManager] Live Activities are not enabled")
            return nil
        }

        // End any existing activities first
        await endAllActivities()

        let attributes = TimerActivityAttributes(trackedAppIdentifier: appIdentifier)
        let initialState = TimerActivityAttributes.ContentState(
            appDisplayName: appDisplayName,
            sessionStartDate: Date()
        )

        let content = ActivityContent(
            state: initialState,
            staleDate: Calendar.current.date(byAdding: .hour, value: 8, to: Date())
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            print("[LiveActivityManager] Started activity: \(activity.id)")

            // Save session info to shared storage
            AppGroupStorage.shared.saveActiveSession(
                startDate: initialState.sessionStartDate,
                appTokenData: nil
            )

            return activity.id
        } catch {
            print("[LiveActivityManager] Failed to start activity: \(error)")
            return nil
        }
    }

    // MARK: - Update Activity

    public func updateActivity(appDisplayName: String, sessionStartDate: Date) async {
        let state = TimerActivityAttributes.ContentState(
            appDisplayName: appDisplayName,
            sessionStartDate: sessionStartDate
        )
        let content = ActivityContent(state: state, staleDate: nil)

        for activity in Activity<TimerActivityAttributes>.activities {
            await activity.update(content)
        }
    }

    // MARK: - End Activity

    public func endActivity(id: String) async {
        guard let activity = Activity<TimerActivityAttributes>.activities.first(where: { $0.id == id }) else {
            return
        }

        // Calculate session duration and add to today's total
        let sessionStart = activity.content.state.sessionStartDate
        let duration = Date().timeIntervalSince(sessionStart)
        let minutes = Int(duration / 60)

        if minutes > 0 {
            AppGroupStorage.shared.addMinutesToToday(minutes)
        }

        let finalState = activity.content.state
        let content = ActivityContent(state: finalState, staleDate: Date())

        await activity.end(content, dismissalPolicy: .immediate)
        AppGroupStorage.shared.clearActiveSession()

        print("[LiveActivityManager] Ended activity: \(id), duration: \(minutes) minutes")
    }

    public func endAllActivities() async {
        for activity in Activity<TimerActivityAttributes>.activities {
            // Calculate duration before ending
            let sessionStart = activity.content.state.sessionStartDate
            let duration = Date().timeIntervalSince(sessionStart)
            let minutes = Int(duration / 60)

            if minutes > 0 {
                AppGroupStorage.shared.addMinutesToToday(minutes)
            }

            let finalState = activity.content.state
            let content = ActivityContent(state: finalState, staleDate: Date())
            await activity.end(content, dismissalPolicy: .immediate)
        }

        AppGroupStorage.shared.clearActiveSession()
        print("[LiveActivityManager] Ended all activities")
    }

    // MARK: - Check Active

    public var hasActiveActivity: Bool {
        !Activity<TimerActivityAttributes>.activities.isEmpty
    }

    public var currentActivityId: String? {
        Activity<TimerActivityAttributes>.activities.first?.id
    }
}
