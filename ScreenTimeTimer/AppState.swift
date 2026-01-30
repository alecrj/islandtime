//
//  AppState.swift
//  ScreenTimeTimer
//
//  Main app state management.
//

import SwiftUI
import FamilyControls
import DeviceActivity
import Combine

@MainActor
final class AppState: ObservableObject {
    // MARK: - Published Properties

    @Published var authorizationStatus: AuthorizationStatus = .notDetermined
    @Published var selectedApps: FamilyActivitySelection = FamilyActivitySelection()
    @Published var hasCompletedOnboarding: Bool = false
    @Published var isMonitoringEnabled: Bool = true
    @Published var todayTotalMinutes: Int = 0

    // MARK: - Private Properties

    private let storage = AppGroupStorage.shared
    private let authorizationCenter = AuthorizationCenter.shared
    private let deviceActivityCenter = DeviceActivityCenter()

    // MARK: - Initialization

    init() {
        loadPersistedState()
        checkAuthorizationStatus()
    }

    // MARK: - Load Persisted State

    private func loadPersistedState() {
        hasCompletedOnboarding = storage.hasCompletedOnboarding
        selectedApps = storage.loadSelectedApps()
        isMonitoringEnabled = storage.isMonitoringEnabled
        todayTotalMinutes = storage.loadTodayTotal()
    }

    // MARK: - Authorization

    func checkAuthorizationStatus() {
        switch authorizationCenter.authorizationStatus {
        case .notDetermined:
            authorizationStatus = .notDetermined
        case .denied:
            authorizationStatus = .denied
        case .approved:
            authorizationStatus = .approved
        @unknown default:
            authorizationStatus = .notDetermined
        }
    }

    func requestAuthorization() async {
        do {
            try await authorizationCenter.requestAuthorization(for: .individual)
            checkAuthorizationStatus()
        } catch {
            print("[AppState] Authorization request failed: \(error)")
            authorizationStatus = .denied
        }
    }

    // MARK: - App Selection

    func updateSelectedApps(_ selection: FamilyActivitySelection) {
        selectedApps = selection
        storage.saveSelectedApps(selection)

        // Restart monitoring with new selection
        if isMonitoringEnabled && authorizationStatus == .approved {
            restartMonitoring()
        }
    }

    // MARK: - Monitoring Control

    func setMonitoringEnabled(_ enabled: Bool) {
        isMonitoringEnabled = enabled
        storage.isMonitoringEnabled = enabled

        if enabled {
            startMonitoring()
        } else {
            stopMonitoring()
            endAnyActiveLiveActivity()
        }
    }

    func startMonitoring() {
        guard authorizationStatus == .approved else {
            print("[AppState] Cannot start monitoring: not authorized")
            return
        }

        guard !selectedApps.applicationTokens.isEmpty else {
            print("[AppState] Cannot start monitoring: no apps selected")
            return
        }

        // Create a daily schedule (midnight to midnight)
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )

        // Create events for each selected app with 1-minute threshold
        var events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]
        for (index, appToken) in selectedApps.applicationTokens.enumerated() {
            let eventName = DeviceActivityEvent.Name("app_active_\(index)")
            let event = DeviceActivityEvent(
                applications: [appToken],
                threshold: DateComponents(minute: 1)
            )
            events[eventName] = event
        }

        do {
            try deviceActivityCenter.startMonitoring(
                .daily,
                during: schedule,
                events: events
            )
            print("[AppState] Monitoring started for \(selectedApps.applicationTokens.count) apps")
        } catch {
            print("[AppState] Failed to start monitoring: \(error)")
        }
    }

    func stopMonitoring() {
        deviceActivityCenter.stopMonitoring([.daily])
        print("[AppState] Monitoring stopped")
    }

    func restartMonitoring() {
        stopMonitoring()
        startMonitoring()
    }

    // MARK: - Live Activity Control

    func endAnyActiveLiveActivity() {
        Task {
            await LiveActivityManager.shared.endAllActivities()
        }
    }

    // MARK: - Onboarding

    func completeOnboarding() {
        hasCompletedOnboarding = true
        storage.hasCompletedOnboarding = true

        // Start monitoring after onboarding
        if isMonitoringEnabled && authorizationStatus == .approved {
            startMonitoring()
        }
    }

    func resetOnboarding() {
        hasCompletedOnboarding = false
        storage.hasCompletedOnboarding = false
        stopMonitoring()
        endAnyActiveLiveActivity()
    }

    // MARK: - Refresh Data

    func refreshTodayTotal() {
        todayTotalMinutes = storage.loadTodayTotal()
    }
}

// MARK: - Authorization Status Enum
enum AuthorizationStatus {
    case notDetermined
    case approved
    case denied
}

// MARK: - Device Activity Name Extension
extension DeviceActivityName {
    static let daily = DeviceActivityName("daily_monitoring")
}
