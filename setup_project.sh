#!/bin/bash

# ============================================================
# Screen Time Timer - Xcode Project Setup Script
# ============================================================
#
# This script helps you set up the Xcode project structure.
# Run this from the ScreenTimeTimer directory.
#
# Usage: ./setup_project.sh
# ============================================================

set -e

echo "=============================================="
echo "Screen Time Timer - Project Setup"
echo "=============================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check we're in the right directory
if [ ! -d "ScreenTimeTimer" ] || [ ! -d "Shared" ]; then
    echo -e "${RED}Error: Please run this script from the ScreenTimeTimer project root directory.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Directory structure verified${NC}"
echo ""

# Print instructions
cat << 'EOF'
==================================================
MANUAL STEPS REQUIRED IN XCODE
==================================================

Since Xcode project files are complex and best created through Xcode,
follow these steps to set up your project:

──────────────────────────────────────────────────
STEP 1: Create the Main Project
──────────────────────────────────────────────────

1. Open Xcode
2. File → New → Project
3. Choose: iOS → App
4. Configure:
   • Product Name: ScreenTimeTimer
   • Team: [Your Team]
   • Organization Identifier: com.yourcompany
   • Interface: SwiftUI
   • Language: Swift
   • Storage: None
   • ☐ Include Tests (uncheck for now)
5. Save to the PARENT directory of this folder
   (Xcode will create a new ScreenTimeTimer folder)
6. DELETE the auto-generated files (ContentView.swift, ScreenTimeTimerApp.swift)

──────────────────────────────────────────────────
STEP 2: Add Files to Main Target
──────────────────────────────────────────────────

Drag these folders/files into your Xcode project navigator:

FROM: ./ScreenTimeTimer/
  → ScreenTimeTimerApp.swift
  → AppState.swift
  → Info.plist
  → Views/ (entire folder)
  → Utilities/ (entire folder)
  → Assets.xcassets (entire folder)

FROM: ./Shared/
  → AppGroupStorage.swift      ✓ Main App
  → LiveActivityManager.swift  ✓ Main App
  → TimerActivityAttributes.swift ✓ Main App
  → WidgetCenter+Extensions.swift ✓ Main App

When adding, ensure "Copy items if needed" is UNCHECKED
and target membership shows: ScreenTimeTimer ✓

──────────────────────────────────────────────────
STEP 3: Add Capabilities to Main App
──────────────────────────────────────────────────

1. Select project in navigator
2. Select "ScreenTimeTimer" target
3. Go to "Signing & Capabilities" tab
4. Click "+ Capability"
5. Add: "App Groups"
   → Click + → Enter: group.com.yourcompany.screentimetimer
6. Click "+ Capability"
7. Add: "Family Controls"

──────────────────────────────────────────────────
STEP 4: Create Device Activity Monitor Extension
──────────────────────────────────────────────────

1. File → New → Target
2. Search: "Device Activity Monitor Extension"
3. Product Name: DeviceActivityMonitorExtension
4. Click Finish
5. When asked to activate scheme, click "Activate"

Add files to this target:
  FROM: ./DeviceActivityMonitorExtension/
    → DeviceActivityMonitorExtension.swift (replace generated file)
    → Info.plist (replace if exists)

  FROM: ./Shared/
    → AppGroupStorage.swift      ✓ Add to target
    → LiveActivityManager.swift  ✓ Add to target
    → TimerActivityAttributes.swift ✓ Add to target

Add Capabilities:
  → App Groups: group.com.yourcompany.screentimetimer
  → Family Controls

──────────────────────────────────────────────────
STEP 5: Create Live Activity Widget Extension
──────────────────────────────────────────────────

1. File → New → Target
2. Search: "Widget Extension"
3. Product Name: TimerActivityExtension
4. ☑ Include Live Activity (CHECK THIS!)
5. Click Finish
6. Activate scheme when asked

DELETE the generated files, then add:
  FROM: ./TimerActivityExtension/
    → TimerActivityBundle.swift
    → TimerActivityLiveActivity.swift
    → Info.plist
    → Assets.xcassets

  FROM: ./Shared/
    → TimerActivityAttributes.swift ✓ Add to target

Add Capabilities:
  → App Groups: group.com.yourcompany.screentimetimer

──────────────────────────────────────────────────
STEP 6: Create Lock Screen Widget Extension
──────────────────────────────────────────────────

1. File → New → Target
2. Search: "Widget Extension"
3. Product Name: ScreenTimeWidget
4. ☐ Include Live Activity (UNCHECK)
5. Click Finish

DELETE the generated files, then add:
  FROM: ./ScreenTimeWidget/
    → ScreenTimeWidgetBundle.swift
    → ScreenTimeWidget.swift
    → WidgetStorage.swift
    → Info.plist
    → Assets.xcassets

Add Capabilities:
  → App Groups: group.com.yourcompany.screentimetimer

──────────────────────────────────────────────────
STEP 7: Configure Build Settings
──────────────────────────────────────────────────

For ALL targets, set:
  • iOS Deployment Target: 17.0
  • Swift Language Version: Swift 5

──────────────────────────────────────────────────
STEP 8: Set Entitlements Files
──────────────────────────────────────────────────

For each target, in Build Settings:
  1. Search "Code Signing Entitlements"
  2. Set path to the .entitlements file:
     • ScreenTimeTimer: ScreenTimeTimer/ScreenTimeTimer.entitlements
     • DeviceActivityMonitorExtension: DeviceActivityMonitorExtension/DeviceActivityMonitorExtension.entitlements
     • TimerActivityExtension: TimerActivityExtension/TimerActivityExtension.entitlements
     • ScreenTimeWidget: ScreenTimeWidget/ScreenTimeWidget.entitlements

──────────────────────────────────────────────────
STEP 9: Build and Run
──────────────────────────────────────────────────

1. Select "ScreenTimeTimer" scheme
2. Select a PHYSICAL device (Screen Time APIs don't work in Simulator)
3. Build (⌘B)
4. Fix any signing issues
5. Run (⌘R)

==================================================
FILE MEMBERSHIP QUICK REFERENCE
==================================================

File                          | Main | Monitor | LiveAct | Widget
------------------------------|------|---------|---------|-------
ScreenTimeTimerApp.swift      |  ✓   |         |         |
AppState.swift                |  ✓   |         |         |
AppGroupStorage.swift         |  ✓   |    ✓    |         |
LiveActivityManager.swift     |  ✓   |    ✓    |         |
TimerActivityAttributes.swift |  ✓   |    ✓    |    ✓    |
WidgetCenter+Extensions.swift |  ✓   |         |         |
Views/*                       |  ✓   |         |         |
DeviceActivityMonitor...swift |      |    ✓    |         |
TimerActivityBundle.swift     |      |         |    ✓    |
TimerActivityLiveActivity...  |      |         |    ✓    |
ScreenTimeWidgetBundle.swift  |      |         |         |   ✓
ScreenTimeWidget.swift        |      |         |         |   ✓
WidgetStorage.swift           |      |         |         |   ✓

==================================================
TROUBLESHOOTING
==================================================

"FamilyControls not found"
→ Ensure Family Controls capability is added
→ Must run on physical device

"App Group not accessible"
→ Check App Group ID matches exactly across all targets
→ Verify entitlements file is set in Build Settings

"Live Activity not showing"
→ Check NSSupportsLiveActivities = YES in Info.plist
→ Device must have Dynamic Island (iPhone 14 Pro+)
→ Check Settings → [Your App] → Live Activities is ON

"Widget not appearing"
→ Long-press Lock Screen → Customize → Widgets
→ Make sure widget bundle is included in build

EOF

echo ""
echo -e "${GREEN}=============================================="
echo "Setup instructions displayed above."
echo "Follow each step carefully in Xcode."
echo "==============================================${NC}"
