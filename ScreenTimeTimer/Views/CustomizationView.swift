//
//  CustomizationView.swift
//  IslandTime
//
//  Timer appearance customization settings.
//

import SwiftUI

struct CustomizationView: View {
    @EnvironmentObject var appState: AppState
    @State private var customization: TimerCustomization = .default
    @State private var showPreview = false

    var body: some View {
        List {
            // Preview Section
            Section {
                TimerPreviewCard(customization: customization)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }

            // Color Selection
            Section {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(TimerColor.allCases) { color in
                        ColorButton(
                            color: color,
                            isSelected: customization.color == color,
                            action: { customization.color = color }
                        )
                    }
                }
                .padding(.vertical, 8)
            } header: {
                Text("Timer Color")
            }

            // Style Selection
            Section {
                ForEach(TimerStyle.allCases) { style in
                    StyleRow(
                        style: style,
                        isSelected: customization.style == style,
                        action: { customization.style = style }
                    )
                }
            } header: {
                Text("Display Style")
            }

            // Options
            Section {
                Toggle(isOn: $customization.hapticOnStart) {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Haptic Feedback")
                            Text("Vibrate when timer starts")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "iphone.radiowaves.left.and.right")
                            .foregroundStyle(customization.color.color)
                    }
                }
            } header: {
                Text("Options")
            }

            // Test Button (Debug)
            #if DEBUG
            Section {
                Button {
                    Task {
                        await LiveActivityManager.shared.startActivity(
                            appDisplayName: "Test App",
                            appIdentifier: "test"
                        )
                    }
                } label: {
                    Label("Test Live Activity", systemImage: "play.circle.fill")
                }

                Button(role: .destructive) {
                    Task {
                        await LiveActivityManager.shared.endAllActivities()
                    }
                } label: {
                    Label("End All Activities", systemImage: "stop.circle.fill")
                }
            } header: {
                Text("Debug")
            }
            #endif
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            customization = AppGroupStorage.shared.loadCustomization()
        }
        .onChange(of: customization) { _, newValue in
            AppGroupStorage.shared.saveCustomization(newValue)
        }
    }
}

// MARK: - Timer Preview Card
struct TimerPreviewCard: View {
    let customization: TimerCustomization

    var body: some View {
        VStack(spacing: 16) {
            // Mock Dynamic Island
            HStack(spacing: 12) {
                // App icon
                ZStack {
                    Circle()
                        .fill(customization.color.color.opacity(0.2))
                        .frame(width: 40, height: 40)

                    Image(systemName: "app.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(customization.color.color)
                }

                if customization.style != .minimal {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Example App")
                            .font(.caption)
                            .fontWeight(.medium)

                        if customization.style == .detailed {
                            Text("Session")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("12:34")
                        .font(.system(size: customization.style == .compact ? 24 : 28, weight: .bold, design: .monospaced))
                        .foregroundStyle(customization.color.color)

                    if customization.style == .detailed {
                        Text("elapsed")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemGray6))
            }

            Text("Preview")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

// MARK: - Color Button
struct ColorButton: View {
    let color: TimerColor
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color.color)
                    .frame(width: 44, height: 44)

                if isSelected {
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 3)
                        .frame(width: 44, height: 44)

                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(color.displayName)
    }
}

// MARK: - Style Row
struct StyleRow: View {
    let style: TimerStyle
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(style.displayName)
                        .font(.body)
                        .foregroundStyle(.primary)

                    Text(style.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.title2)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        CustomizationView()
            .environmentObject(AppState())
    }
}
