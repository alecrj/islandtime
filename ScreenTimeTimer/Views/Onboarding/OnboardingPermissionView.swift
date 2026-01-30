//
//  OnboardingPermissionView.swift
//  ScreenTimeTimer
//
//  Screen 2: Request Screen Time authorization.
//

import SwiftUI

struct OnboardingPermissionView: View {
    @EnvironmentObject var appState: AppState
    let onContinue: () -> Void

    @State private var isRequesting = false
    @State private var showDeniedAlert = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Icon and explanation
            VStack(spacing: 32) {
                // Shield icon
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.1))
                        .frame(width: 100, height: 100)

                    Image(systemName: "lock.shield")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.accentColor)
                }

                VStack(spacing: 12) {
                    Text("Screen Time Access")
                        .font(.system(size: 28, weight: .bold))

                    Text("To track which apps you use, we need\nScreen Time permission. This stays\ncompletely private on your device.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                // Privacy points
                VStack(alignment: .leading, spacing: 16) {
                    PrivacyPointRow(
                        icon: "eye.slash",
                        text: "Your data never leaves your device"
                    )
                    PrivacyPointRow(
                        icon: "hand.raised",
                        text: "We only see apps you choose to track"
                    )
                    PrivacyPointRow(
                        icon: "xmark.circle",
                        text: "No ads, no selling data, ever"
                    )
                }
                .padding(.top, 8)
            }

            Spacer()

            // Status and Action
            VStack(spacing: 16) {
                if appState.authorizationStatus == .approved {
                    // Already authorized
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Permission Granted")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Button(action: handleButtonTap) {
                    HStack(spacing: 8) {
                        if isRequesting {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(buttonTitle)
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(buttonBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(isRequesting)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .alert("Permission Required", isPresented: $showDeniedAlert) {
            Button("Open Settings") {
                openSettings()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Screen Time access was denied. Please enable it in Settings to use this app.")
        }
    }

    private var buttonTitle: String {
        switch appState.authorizationStatus {
        case .approved:
            return "Continue"
        case .denied:
            return "Open Settings"
        case .notDetermined:
            return "Allow Access"
        }
    }

    private var buttonBackground: Color {
        appState.authorizationStatus == .approved ? .accentColor : .accentColor
    }

    private func handleButtonTap() {
        switch appState.authorizationStatus {
        case .approved:
            onContinue()
        case .denied:
            showDeniedAlert = true
        case .notDetermined:
            requestPermission()
        }
    }

    private func requestPermission() {
        isRequesting = true
        Task {
            await appState.requestAuthorization()
            isRequesting = false

            if appState.authorizationStatus == .approved {
                // Small delay for user to see success
                try? await Task.sleep(nanoseconds: 500_000_000)
                onContinue()
            } else if appState.authorizationStatus == .denied {
                showDeniedAlert = true
            }
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Privacy Point Row
struct PrivacyPointRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color.accentColor)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingPermissionView(onContinue: {})
        .environmentObject(AppState())
}
