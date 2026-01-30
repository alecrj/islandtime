//
//  ScreenTimeTimerApp.swift
//  ScreenTimeTimer
//
//  Dynamic Island Screen-Time Timer
//

import SwiftUI
import FamilyControls

@main
struct ScreenTimeTimerApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}

// MARK: - Root View (Handles Onboarding vs Main)
struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if appState.hasCompletedOnboarding {
                MainSettingsView()
            } else {
                OnboardingContainerView()
            }
        }
        .animation(.easeInOut, value: appState.hasCompletedOnboarding)
    }
}
