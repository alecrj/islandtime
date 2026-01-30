//
//  MainSettingsView.swift
//  ScreenTimeTimer
//
//  Main settings screen after onboarding.
//

import SwiftUI
import FamilyControls

struct MainSettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showAppPicker = false
    @State private var showPrivacyInfo = false

    var body: some View {
        NavigationStack {
            List {
                // Status Section
                Section {
                    StatusCard()
                } header: {
                    Text("Today")
                }

                // Monitoring Toggle
                Section {
                    Toggle(isOn: Binding(
                        get: { appState.isMonitoringEnabled },
                        set: { appState.setMonitoringEnabled($0) }
                    )) {
                        Label {
                            Text("Live Timer")
                        } icon: {
                            Image(systemName: "timer")
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                } header: {
                    Text("Timer")
                } footer: {
                    Text("When enabled, a timer appears in the Dynamic Island while using tracked apps.")
                }

                // Tracked Apps Section
                Section {
                    Button(action: { showAppPicker = true }) {
                        HStack {
                            Label {
                                Text("Tracked Apps")
                            } icon: {
                                Image(systemName: "square.grid.2x2")
                                    .foregroundStyle(Color.accentColor)
                            }

                            Spacer()

                            Text("\(appState.selectedApps.applicationTokens.count)")
                                .foregroundStyle(.secondary)

                            Image(systemName: "chevron.right")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .foregroundStyle(.primary)
                } header: {
                    Text("Apps")
                } footer: {
                    Text("Select which apps show a session timer in the Dynamic Island.")
                }

                // Widget Info Section
                Section {
                    HStack {
                        Label {
                            Text("Lock Screen Widget")
                        } icon: {
                            Image(systemName: "rectangle.on.rectangle")
                                .foregroundStyle(Color.accentColor)
                        }

                        Spacer()

                        Text("Available")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray5))
                            .clipShape(Capsule())
                    }
                } header: {
                    Text("Widget")
                } footer: {
                    Text("Add the Screen Time widget to your Lock Screen for a quick daily total. Long-press your Lock Screen to customize.")
                }

                // Privacy & About
                Section {
                    Button(action: { showPrivacyInfo = true }) {
                        Label {
                            Text("Privacy")
                        } icon: {
                            Image(systemName: "hand.raised")
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .foregroundStyle(.primary)
                }
            }
            .navigationTitle("Screen Time Timer")
            .navigationBarTitleDisplayMode(.large)
            .familyActivityPicker(
                isPresented: $showAppPicker,
                selection: Binding(
                    get: { appState.selectedApps },
                    set: { appState.updateSelectedApps($0) }
                )
            )
            .sheet(isPresented: $showPrivacyInfo) {
                PrivacyInfoView()
            }
            .onAppear {
                appState.refreshTodayTotal()
            }
        }
    }
}

// MARK: - Status Card
struct StatusCard: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Screen Time")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(formattedTime)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                }

                Spacer()

                // Status indicator
                VStack(alignment: .trailing, spacing: 4) {
                    Circle()
                        .fill(appState.isMonitoringEnabled ? Color.green : Color.gray)
                        .frame(width: 8, height: 8)

                    Text(appState.isMonitoringEnabled ? "Active" : "Paused")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if appState.selectedApps.applicationTokens.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                        .font(.footnote)
                    Text("No apps selected for tracking")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var formattedTime: String {
        let hours = appState.todayTotalMinutes / 60
        let minutes = appState.todayTotalMinutes % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Privacy Info View
struct PrivacyInfoView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.accentColor)

                        Text("Your Privacy Matters")
                            .font(.title.bold())
                    }
                    .padding(.top)

                    // Privacy points
                    VStack(alignment: .leading, spacing: 20) {
                        PrivacySection(
                            title: "Local Only",
                            description: "All your screen time data stays on your device. We never upload, sync, or share your usage information with anyone.",
                            icon: "iphone"
                        )

                        PrivacySection(
                            title: "You Control Access",
                            description: "We only see the apps you explicitly choose to track. System apps and other apps remain private.",
                            icon: "slider.horizontal.3"
                        )

                        PrivacySection(
                            title: "No Analytics",
                            description: "We don't collect analytics about how you use this app. No tracking, no profiling.",
                            icon: "chart.bar.xaxis"
                        )

                        PrivacySection(
                            title: "No Ads, Ever",
                            description: "This app has no ads and will never have ads. Your attention is not for sale.",
                            icon: "nosign"
                        )

                        PrivacySection(
                            title: "Pure Awareness",
                            description: "This app exists to help you be aware of how you spend your time. No guilt, no judgment, no manipulation.",
                            icon: "eye"
                        )
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct PrivacySection: View {
    let title: String
    let description: String
    let icon: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.accentColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    MainSettingsView()
        .environmentObject(AppState())
}
