# Quick Setup Guide

Follow these steps to configure and run NotchApp:

## Step 1: Configure Xcode Project Settings

1. **Open the project in Xcode:**

    ```bash
    open NotchApp.xcodeproj
    ```

2. **Link Info.plist:**

    - Select the `NotchApp` project in the navigator
    - Select the `NotchApp` target
    - Go to the "Build Settings" tab
    - Search for "Info.plist File"
    - Set the value to: `NotchApp/Info.plist`

3. **Link Entitlements:**

    - Stay in the `NotchApp` target settings
    - Go to "Signing & Capabilities" tab
    - Find "Code Signing Entitlements"
    - Set the value to: `NotchApp/NotchApp.entitlements`

4. **Enable App Sandbox (if needed):**
    - In "Signing & Capabilities"
    - Click "+ Capability"
    - Add "App Sandbox"

## Step 2: Add Files to Project (if not already added)

Make sure these files are in your Xcode project:

-   `NotchApp/Models/MediaInfo.swift` ✅
-   `NotchApp/ViewModels/MediaPlayerManager.swift` ✅
-   `NotchApp/Views/NotchBarView.swift` ✅
-   `NotchApp/Views/Components/MediaDisplayView.swift` ✅
-   `NotchApp/NotchWindowController.swift` ✅
-   `NotchApp/Info.plist` ✅
-   `NotchApp/NotchApp.entitlements` ✅

## Step 3: Build and Run

1. Select your Mac as the run destination
2. Press `Cmd + R` or click the Run button
3. The app will build and launch

## Step 4: Grant Permissions

When the app first runs, you'll see a permission dialog:

1. Click "OK" when asked for automation access to Music.app
2. If you miss it, go to:
    - **System Settings** → **Privacy & Security** → **Automation**
    - Find **NotchApp** → Enable **Music**

## Step 5: Test the App

1. Open Music.app and play a song
2. Look at the top center of your screen for the notch
3. Hover over the notch to see it expand with song info
4. Click the play/pause button to control playback

## What You Should See

### Collapsed State (NotchNook-style):

-   **Black notch shape** at top center (150px wide)
-   Blends seamlessly with MacBook notch
-   **Animated wave bars** when music is playing (3 capsules)
-   Song title preview (truncated)
-   Subtle scale effect on hover

### Expanded State (on hover):

-   **Smooth slide-down animation** from notch (0.6s spring)
-   Notch connector bridge at top
-   **Glassmorphic card** with gradient borders
-   Album artwork (70×70) with shadows
-   Song title and artist with premium typography
-   **Modern progress bar** with gradient fill and glow
-   Progress indicator dot
-   **Circular play/pause button** with hover effects
-   Multiple shadow layers for depth

## Troubleshooting Quick Fixes

### Issue: "Command CodeSign failed"

**Fix:** Make sure you have a valid signing certificate or enable "Automatically manage signing"

### Issue: No notch appears

**Fix:**

-   Check Activity Monitor to confirm app is running
-   The app runs as an accessory (won't appear in Dock)
-   Try quitting and restarting

### Issue: Media info not showing

**Fix:**

1. Make sure Music.app is running and playing
2. Grant automation permissions (Step 4)
3. Restart NotchApp

### Issue: "Cannot find 'MediaPlayerManager' in scope"

**Fix:** Make sure all new files are added to the Xcode project target

## Adding Files to Xcode Target

If you get compilation errors about missing files:

1. Right-click on `NotchApp` folder in Xcode
2. Select "Add Files to NotchApp..."
3. Navigate to the new files
4. Check "Copy items if needed"
5. Make sure "NotchApp" target is checked
6. Click "Add"

## Keyboard Shortcuts

Currently none - coming in future updates!

## Need Help?

Check the full README.md for detailed documentation and architecture information.

---

**Ready to go!** 🚀 Your notch-style music display should now be working.
