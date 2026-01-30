//
//  TimerCustomization.swift
//  IslandTime
//
//  Timer appearance customization settings.
//  Add this file to: Main App, TimerActivityExtension
//

import SwiftUI

// MARK: - Timer Color Options
public enum TimerColor: String, CaseIterable, Codable, Identifiable {
    case blue = "blue"
    case green = "green"
    case orange = "orange"
    case purple = "purple"
    case pink = "pink"
    case red = "red"
    case cyan = "cyan"
    case mint = "mint"

    public var id: String { rawValue }

    public var color: Color {
        switch self {
        case .blue: return .blue
        case .green: return .green
        case .orange: return .orange
        case .purple: return .purple
        case .pink: return .pink
        case .red: return .red
        case .cyan: return .cyan
        case .mint: return .mint
        }
    }

    public var displayName: String {
        switch self {
        case .blue: return "Blue"
        case .green: return "Green"
        case .orange: return "Orange"
        case .purple: return "Purple"
        case .pink: return "Pink"
        case .red: return "Red"
        case .cyan: return "Cyan"
        case .mint: return "Mint"
        }
    }
}

// MARK: - Timer Style Options
public enum TimerStyle: String, CaseIterable, Codable, Identifiable {
    case minimal = "minimal"       // Just the timer
    case detailed = "detailed"     // Timer + app name + labels
    case compact = "compact"       // Smaller, tighter layout

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .minimal: return "Minimal"
        case .detailed: return "Detailed"
        case .compact: return "Compact"
        }
    }

    public var description: String {
        switch self {
        case .minimal: return "Clean timer only"
        case .detailed: return "Timer with labels"
        case .compact: return "Space-efficient"
        }
    }
}

// MARK: - Timer Customization Settings
public struct TimerCustomization: Codable, Equatable {
    public var color: TimerColor
    public var style: TimerStyle
    public var showSeconds: Bool
    public var hapticOnStart: Bool

    public init(
        color: TimerColor = .blue,
        style: TimerStyle = .detailed,
        showSeconds: Bool = true,
        hapticOnStart: Bool = true
    ) {
        self.color = color
        self.style = style
        self.showSeconds = showSeconds
        self.hapticOnStart = hapticOnStart
    }

    public static let `default` = TimerCustomization()
}

// MARK: - Storage Extension
extension AppGroupStorage {
    private static let customizationKey = "timerCustomization"

    public func saveCustomization(_ customization: TimerCustomization) {
        do {
            let data = try JSONEncoder().encode(customization)
            UserDefaults(suiteName: AppGroupConstants.suiteName)?.set(data, forKey: Self.customizationKey)
            UserDefaults(suiteName: AppGroupConstants.suiteName)?.synchronize()
            print("[AppGroupStorage] Saved customization: \(customization)")
        } catch {
            print("[AppGroupStorage] Failed to save customization: \(error)")
        }
    }

    public func loadCustomization() -> TimerCustomization {
        guard let data = UserDefaults(suiteName: AppGroupConstants.suiteName)?.data(forKey: Self.customizationKey) else {
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

// MARK: - Widget Storage Extension (for read-only access)
extension WidgetStorage {
    private static let customizationKey = "timerCustomization"

    func loadCustomization() -> TimerCustomization {
        guard let defaults = UserDefaults(suiteName: "group.com.alecrj.islandtime"),
              let data = defaults.data(forKey: Self.customizationKey) else {
            return .default
        }
        do {
            return try JSONDecoder().decode(TimerCustomization.self, from: data)
        } catch {
            return .default
        }
    }
}
