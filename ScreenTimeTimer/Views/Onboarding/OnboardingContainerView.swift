//
//  OnboardingContainerView.swift
//  ScreenTimeTimer
//
//  Container for the onboarding flow.
//

import SwiftUI

struct OnboardingContainerView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage: OnboardingPage = .preview

    enum OnboardingPage: Int, CaseIterable {
        case preview = 0
        case permission = 1
        case appPicker = 2
    }

    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()

            // Content
            TabView(selection: $currentPage) {
                OnboardingPreviewView(onContinue: { currentPage = .permission })
                    .tag(OnboardingPage.preview)

                OnboardingPermissionView(onContinue: { currentPage = .appPicker })
                    .tag(OnboardingPage.permission)

                OnboardingAppPickerView(onComplete: completeOnboarding)
                    .tag(OnboardingPage.appPicker)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
        }
    }

    private func completeOnboarding() {
        appState.completeOnboarding()
    }
}

// MARK: - Preview
#Preview {
    OnboardingContainerView()
        .environmentObject(AppState())
}
