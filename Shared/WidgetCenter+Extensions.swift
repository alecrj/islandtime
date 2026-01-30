//
//  WidgetCenter+Extensions.swift
//  ScreenTimeTimer
//
//  Helper to trigger widget updates.
//

import WidgetKit

extension WidgetCenter {
    /// Requests the Screen Time widget to reload its timeline.
    /// Note: WidgetKit may throttle refresh requests.
    static func reloadScreenTimeWidget() {
        WidgetCenter.shared.reloadTimelines(ofKind: "ScreenTimeWidget")
    }

    /// Reload all app widgets.
    static func reloadAllWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
