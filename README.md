# Screen Time Timer

A minimal iOS app that shows a **Dynamic Island timer** while using selected apps, plus a **Lock Screen widget** showing daily screen time totals.

## Features

- **Dynamic Island Timer**: Live Activity shows elapsed time when using tracked apps
- **App Selection**: Choose which apps to track via Apple's FamilyActivityPicker
- **Lock Screen Widget**: Shows total tracked screen time today
- **Privacy-First**: All data stays on device, no analytics, no ads

## Requirements

- **Xcode 15.0+**
- **iOS 17.0+**
- **Physical device** (Screen Time APIs don't work in Simulator)
- **iPhone 14 Pro or later** (for Dynamic Island)
- Apple Developer account with Family Controls capability

## Project Structure

```
ScreenTimeTimer/
├── ScreenTimeTimer/           # Main iOS App
│   ├── ScreenTimeTimerApp.swift
│   ├── AppState.swift
│   ├── Views/
│   │   ├── MainSettingsView.swift
│   │   └── Onboarding/
│   │       ├── OnboardingContainerView.swift
│   │       ├── OnboardingPreviewView.swift
│   │       ├── OnboardingPermissionView.swift
│   │       └── OnboardingAppPickerView.swift
│   └── Utilities/
│       └── DebugHelpers.swift
│
├── Shared/                    # Shared across targets
│   ├── AppGroupStorage.swift
│   ├── LiveActivityManager.swift
│   ├── TimerActivityAttributes.swift
│   └── WidgetCenter+Extensions.swift
│
├── DeviceActivityMonitorExtension/
│   ├── DeviceActivityMonitorExtension.swift
│   └── Info.plist
│
├── TimerActivityExtension/    # Live Activity
│   ├── TimerActivityBundle.swift
│   ├── TimerActivityLiveActivity.swift
│   └── Info.plist
│
└── ScreenTimeWidget/          # Lock Screen Widget
    ├── ScreenTimeWidgetBundle.swift
    ├── ScreenTimeWidget.swift
    ├── WidgetStorage.swift
    └── Info.plist
```

## Setup Instructions

### Quick Start

```bash
cd /Users/alec/ScreenTimeTimer
./setup_project.sh
```

This displays detailed step-by-step instructions for Xcode setup.

### Manual Setup

1. **Create Xcode Project**
   - File → New → Project → App (iOS)
   - Product Name: `ScreenTimeTimer`
   - Interface: SwiftUI

2. **Add Extensions**
   - Device Activity Monitor Extension: `DeviceActivityMonitorExtension`
   - Widget Extension (with Live Activity): `TimerActivityExtension`
   - Widget Extension (without Live Activity): `ScreenTimeWidget`

3. **Add Capabilities** (to appropriate targets)
   - App Groups: `group.com.yourcompany.screentimetimer`
   - Family Controls (Main App + Monitor Extension)

4. **Add Source Files** (see setup script for details)

## Target File Membership

| File | Main App | Monitor | Live Activity | Widget |
|------|:--------:|:-------:|:-------------:|:------:|
| AppGroupStorage.swift | ✓ | ✓ | | |
| LiveActivityManager.swift | ✓ | ✓ | | |
| TimerActivityAttributes.swift | ✓ | ✓ | ✓ | |
| WidgetStorage.swift | | | | ✓ |

## How It Works

### App Detection (Threshold-Based)

Apple's DeviceActivity framework uses **threshold-based monitoring**, not real-time app launch detection:

1. We create a daily monitoring schedule (midnight to midnight)
2. For each tracked app, we set up an event with a 1-minute threshold
3. When usage reaches the threshold, we get a callback
4. We start a Live Activity showing the session timer

**Important**: There's approximately a ~1 minute delay before the timer appears. This is an Apple framework limitation.

### Live Activity Timer

- Uses SwiftUI's `Text(date, style: .timer)` for automatic updating
- No background execution needed - the system handles timer rendering
- Timer continues accurately even when phone is locked

### Lock Screen Widget

- Reads from App Group shared storage
- Updates every ~15 minutes (WidgetKit throttling)
- Shows total tracked screen time for the current day

## Known Limitations

| Limitation | Explanation |
|------------|-------------|
| ~1 min detection delay | DeviceActivity uses threshold-based detection |
| Timer may persist briefly | Imperfect "app closed" detection |
| Generic app labels | Apple doesn't expose app names from tokens |
| Widget not real-time | WidgetKit enforces minimum refresh intervals |
| Physical device required | Screen Time APIs don't work in Simulator |

## Testing

### On Device

1. Build and run on a physical iOS 17+ device
2. Complete onboarding and grant Screen Time permission
3. Select at least one app to track
4. Open the tracked app and use it for >1 minute
5. The Dynamic Island timer should appear
6. Check Lock Screen widget shows accumulated time

### Debug Mode

In `DebugHelpers.swift` (only in DEBUG builds):

```swift
// Start a test Live Activity
await DebugHelpers.startTestLiveActivity()

// End all Live Activities
await DebugHelpers.endAllLiveActivities()

// Add test minutes
DebugHelpers.addTestMinutes(30)

// Print storage state
DebugHelpers.printStorageState()
```

## App Group Configuration

All targets must use the same App Group ID:

```
group.com.yourcompany.screentimetimer
```

**To change this**, update in:
1. All `.entitlements` files
2. `AppGroupStorage.swift` → `suiteName`
3. `WidgetStorage.swift` → `suiteName`

## Troubleshooting

### "FamilyControls not found"
- Add Family Controls capability in Xcode
- Must run on physical device

### "Live Activity not showing"
- Check `NSSupportsLiveActivities = YES` in Info.plist
- iPhone must have Dynamic Island (14 Pro+)
- Settings → [App] → Live Activities must be ON

### "App Group not accessible"
- Verify App Group ID matches exactly across all targets
- Check entitlements file path in Build Settings

### "Widget not appearing"
- Long-press Lock Screen → Customize → Widgets
- Ensure widget extension is included in build

## Privacy

- All data stored locally on device
- No network requests, no analytics
- Uses Apple's privacy-preserving Screen Time APIs
- App tokens are opaque - we can't see actual app names

## Architecture Notes

### Why Separate Widget Storage?

The `ScreenTimeWidget` target can't import `FamilyControls`, so it uses a lightweight `WidgetStorage.swift` that only reads the screen time total from UserDefaults.

### Why Threshold-Based Detection?

Apple's `DeviceActivityMonitor` doesn't provide real-time "app launched" callbacks. Instead, it notifies when cumulative usage reaches defined thresholds. We use a 1-minute threshold as the minimum practical value.

## License

MIT License - See LICENSE file
