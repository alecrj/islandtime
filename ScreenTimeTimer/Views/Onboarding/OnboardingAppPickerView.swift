//
//  OnboardingAppPickerView.swift
//  ScreenTimeTimer
//
//  Screen 3: App picker using FamilyActivityPicker.
//

import SwiftUI
import FamilyControls

struct OnboardingAppPickerView: View {
    @EnvironmentObject var appState: AppState
    let onComplete: () -> Void

    @State private var selection = FamilyActivitySelection()
    @State private var showPicker = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Icon and explanation
            VStack(spacing: 32) {
                // Apps icon
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.1))
                        .frame(width: 100, height: 100)

                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.accentColor)
                }

                VStack(spacing: 12) {
                    Text("Choose Apps to Track")
                        .font(.system(size: 28, weight: .bold))

                    Text("Select the apps where you'd like to\nsee a session timer. You can always\nchange this later.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                // Selected count
                if !selection.applicationTokens.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("\(selection.applicationTokens.count) app\(selection.applicationTokens.count == 1 ? "" : "s") selected")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)
                }
            }

            Spacer()

            // Buttons
            VStack(spacing: 12) {
                Button(action: { showPicker = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text(selection.applicationTokens.isEmpty ? "Select Apps" : "Change Selection")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                if !selection.applicationTokens.isEmpty {
                    Button(action: completeSetup) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundStyle(Color.accentColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.accentColor.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .familyActivityPicker(
            isPresented: $showPicker,
            selection: $selection
        )
        .onChange(of: selection) { _, newValue in
            appState.updateSelectedApps(newValue)
        }
    }

    private func completeSetup() {
        appState.updateSelectedApps(selection)
        onComplete()
    }
}

// MARK: - Preview
#Preview {
    OnboardingAppPickerView(onComplete: {})
        .environmentObject(AppState())
}
