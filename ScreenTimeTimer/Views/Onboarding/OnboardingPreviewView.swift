//
//  OnboardingPreviewView.swift
//  ScreenTimeTimer
//
//  Screen 1: Shows a preview of the Dynamic Island timer.
//

import SwiftUI

struct OnboardingPreviewView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Dynamic Island Mock
            VStack(spacing: 32) {
                DynamicIslandMockView()

                VStack(spacing: 12) {
                    Text("See Your Time")
                        .font(.system(size: 32, weight: .bold))

                    Text("A live timer in your Dynamic Island\nshows exactly how long you've been\nin any app you choose to track.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }

            Spacer()

            // Continue Button
            Button(action: onContinue) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }
}

// MARK: - Dynamic Island Mock View
struct DynamicIslandMockView: View {
    @State private var timerValue: TimeInterval = 0
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 16) {
            // Phone frame
            ZStack {
                // Phone body
                RoundedRectangle(cornerRadius: 40)
                    .fill(Color(.systemGray6))
                    .frame(width: 200, height: 120)

                // Dynamic Island expanded
                HStack(spacing: 12) {
                    // App icon placeholder
                    Circle()
                        .fill(Color.accentColor.opacity(0.2))
                        .frame(width: 36, height: 36)
                        .overlay {
                            Image(systemName: "app.fill")
                                .foregroundStyle(Color.accentColor)
                        }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Social App")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)

                        Text(formattedTime)
                            .font(.system(size: 20, weight: .semibold, design: .monospaced))
                            .foregroundStyle(Color.accentColor)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background {
                    Capsule()
                        .fill(Color.black)
                }
            }
        }
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
    }

    private var formattedTime: String {
        let minutes = Int(timerValue) / 60
        let seconds = Int(timerValue) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func startTimer() {
        timerValue = 127 // Start at 2:07 for visual interest
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timerValue += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Preview
#Preview {
    OnboardingPreviewView(onContinue: {})
}
