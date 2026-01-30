//
//  WidgetStorage.swift
//  ScreenTimeWidget
//
//  Lightweight storage for widget that only needs to read today's total.
//  This avoids FamilyControls dependency which isn't available in widgets.
//

import Foundation

// MARK: - Widget Storage (Read-Only)
final class WidgetStorage {
    static let shared = WidgetStorage()

    private let suiteName = "group.com.alecrj.islandtime"
    private let defaults: UserDefaults?

    private init() {
        defaults = UserDefaults(suiteName: suiteName)
    }

    // MARK: - Today's Total Screen Time (Read-Only)

    func loadTodayTotal() -> Int {
        let todayDateKey = "todayDate"
        let todayTotalKey = "todayTotalMinutes"

        let storedDateTimestamp = defaults?.double(forKey: todayDateKey) ?? 0
        let storedDate = Date(timeIntervalSince1970: storedDateTimestamp)
        let today = Calendar.current.startOfDay(for: Date())

        // Check if stored date is today
        if !Calendar.current.isDate(storedDate, inSameDayAs: today) {
            return 0
        }

        return defaults?.integer(forKey: todayTotalKey) ?? 0
    }
}
