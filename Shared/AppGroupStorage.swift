//
//  AppGroupStorage.swift
//  ScreenTimeTimer
//
//  Shared storage for all targets via App Group container.
//  Add this file to: Main App, DeviceActivityMonitorExtension, ScreenTimeWidget
//

import Foundation
import FamilyControls

// MARK: - Constants
public enum AppGroupConstants {
    public static let suiteName = "group.com.alecrj.islandtime"

    public enum Keys {
        public static let selectedApps = "selectedApps"
        public static let todayTotalMinutes = "todayTotalMinutes"
        public static let todayDate = "todayDate"
        public static let activeSessionStart = "activeSessionStart"
        public static let activeSessionAppToken = "activeSessionAppToken"
        public static let hasCompletedOnboarding = "hasCompletedOnboarding"
        public static let isMonitoringEnabled = "isMonitoringEnabled"
    }
}

// MARK: - App Group Storage Manager
public final class AppGroupStorage {
    public static let shared = AppGroupStorage()

    private let defaults: UserDefaults?
    private let encoder = PropertyListEncoder()
    private let decoder = PropertyListDecoder()

    private init() {
        defaults = UserDefaults(suiteName: AppGroupConstants.suiteName)

        if defaults == nil {
            print("[AppGroupStorage] WARNING: Could not initialize App Group storage. Check entitlements.")
        }
    }

    // MARK: - Selected Apps (FamilyActivitySelection)

    public func saveSelectedApps(_ selection: FamilyActivitySelection) {
        do {
            let data = try encoder.encode(selection)
            defaults?.set(data, forKey: AppGroupConstants.Keys.selectedApps)
            defaults?.synchronize()
            print("[AppGroupStorage] Saved \(selection.applicationTokens.count) selected apps")
        } catch {
            print("[AppGroupStorage] Failed to save selected apps: \(error)")
        }
    }

    public func loadSelectedApps() -> FamilyActivitySelection {
        guard let data = defaults?.data(forKey: AppGroupConstants.Keys.selectedApps) else {
            return FamilyActivitySelection()
        }
        do {
            let selection = try decoder.decode(FamilyActivitySelection.self, from: data)
            return selection
        } catch {
            print("[AppGroupStorage] Failed to load selected apps: \(error)")
            return FamilyActivitySelection()
        }
    }

    // MARK: - Today's Total Screen Time

    public func saveTodayTotal(minutes: Int) {
        let today = Calendar.current.startOfDay(for: Date())
        defaults?.set(minutes, forKey: AppGroupConstants.Keys.todayTotalMinutes)
        defaults?.set(today.timeIntervalSince1970, forKey: AppGroupConstants.Keys.todayDate)
        defaults?.synchronize()
        print("[AppGroupStorage] Saved today total: \(minutes) minutes")

        // Notify that widget should refresh (handled by main app)
        NotificationCenter.default.post(name: .screenTimeUpdated, object: nil)
    }

    public func loadTodayTotal() -> Int {
        let storedDateTimestamp = defaults?.double(forKey: AppGroupConstants.Keys.todayDate) ?? 0
        let storedDate = Date(timeIntervalSince1970: storedDateTimestamp)
        let today = Calendar.current.startOfDay(for: Date())

        // Reset if it's a new day
        if !Calendar.current.isDate(storedDate, inSameDayAs: today) {
            defaults?.set(0, forKey: AppGroupConstants.Keys.todayTotalMinutes)
            defaults?.set(today.timeIntervalSince1970, forKey: AppGroupConstants.Keys.todayDate)
            defaults?.synchronize()
            return 0
        }

        return defaults?.integer(forKey: AppGroupConstants.Keys.todayTotalMinutes) ?? 0
    }

    public func addMinutesToToday(_ additionalMinutes: Int) {
        guard additionalMinutes > 0 else { return }
        let current = loadTodayTotal()
        saveTodayTotal(minutes: current + additionalMinutes)
    }

    // MARK: - Active Session Tracking

    public func saveActiveSession(startDate: Date, appTokenData: Data?) {
        defaults?.set(startDate.timeIntervalSince1970, forKey: AppGroupConstants.Keys.activeSessionStart)
        defaults?.set(appTokenData, forKey: AppGroupConstants.Keys.activeSessionAppToken)
        defaults?.synchronize()
        print("[AppGroupStorage] Saved active session starting at: \(startDate)")
    }

    public func loadActiveSession() -> (startDate: Date, appTokenData: Data?)? {
        let timestamp = defaults?.double(forKey: AppGroupConstants.Keys.activeSessionStart) ?? 0
        if timestamp == 0 { return nil }
        let appTokenData = defaults?.data(forKey: AppGroupConstants.Keys.activeSessionAppToken)
        return (Date(timeIntervalSince1970: timestamp), appTokenData)
    }

    public func clearActiveSession() {
        defaults?.removeObject(forKey: AppGroupConstants.Keys.activeSessionStart)
        defaults?.removeObject(forKey: AppGroupConstants.Keys.activeSessionAppToken)
        defaults?.synchronize()
        print("[AppGroupStorage] Cleared active session")
    }

    // MARK: - Onboarding State

    public var hasCompletedOnboarding: Bool {
        get { defaults?.bool(forKey: AppGroupConstants.Keys.hasCompletedOnboarding) ?? false }
        set {
            defaults?.set(newValue, forKey: AppGroupConstants.Keys.hasCompletedOnboarding)
            defaults?.synchronize()
        }
    }

    // MARK: - Monitoring Toggle

    public var isMonitoringEnabled: Bool {
        get {
            if defaults?.object(forKey: AppGroupConstants.Keys.isMonitoringEnabled) == nil {
                return true
            }
            return defaults?.bool(forKey: AppGroupConstants.Keys.isMonitoringEnabled) ?? true
        }
        set {
            defaults?.set(newValue, forKey: AppGroupConstants.Keys.isMonitoringEnabled)
            defaults?.synchronize()
        }
    }

    // MARK: - Reset All Data

    public func resetAllData() {
        let keys = [
            AppGroupConstants.Keys.selectedApps,
            AppGroupConstants.Keys.todayTotalMinutes,
            AppGroupConstants.Keys.todayDate,
            AppGroupConstants.Keys.activeSessionStart,
            AppGroupConstants.Keys.activeSessionAppToken,
            AppGroupConstants.Keys.hasCompletedOnboarding,
            AppGroupConstants.Keys.isMonitoringEnabled
        ]

        for key in keys {
            defaults?.removeObject(forKey: key)
        }
        defaults?.synchronize()

        print("[AppGroupStorage] Reset all data")
    }
}

// MARK: - Notification Names
public extension Notification.Name {
    static let screenTimeUpdated = Notification.Name("screenTimeUpdated")
}

// MARK: - Timer Customization Storage
extension AppGroupStorage {
    private static let customizationKey = "timerCustomization"

    public func saveCustomization(_ customization: TimerCustomization) {
        do {
            let data = try JSONEncoder().encode(customization)
            defaults?.set(data, forKey: Self.customizationKey)
            defaults?.synchronize()
            print("[AppGroupStorage] Saved customization: \(customization)")
        } catch {
            print("[AppGroupStorage] Failed to save customization: \(error)")
        }
    }

    public func loadCustomization() -> TimerCustomization {
        guard let data = defaults?.data(forKey: Self.customizationKey) else {
            return .default
        }
        do {
            return try JSONDecoder().decode(TimerCustomization.self, from: data)
        } catch {
            print("[AppGroupStorage] Failed to load customization: \(error)")
            return .default
        }
    }
}
