# NotchApp - System-Wide Music Integration Guide

## Overview

Your NotchApp now has **automatic system-wide music detection** that works with **ANY music player** on your Mac:

-   ✅ Spotify
-   ✅ Apple Music
-   ✅ YouTube Music (in browser or app)
-   ✅ SoundCloud
-   ✅ Any other music app

**No manual setup required!** Just play music anywhere and it will automatically appear in your notch.

## How It Works

### 1. **MediaRemote Framework Integration**

The app uses Apple's private `MediaRemote.framework` to tap into the system-wide "Now Playing" information. This is the same technology that powers:

-   Control Center's music widget
-   Lock screen music controls
-   Touch Bar music controls
-   AirPods automatic switching

### 2. **Automatic Detection**

The `MediaPlayerManager` class:

-   Polls for music info every 0.5 seconds
-   Listens to system notifications when music changes
-   Automatically updates the UI when any app starts/stops playing
-   Works even if the music app is in the background or minimized

### 3. **Universal Controls**

The media controls (play/pause, next, previous) work with **all apps** through the MediaRemote API:

```swift
// These commands work system-wide
- Play/Pause (kMRTogglePlayPause)
- Next Track (kMRNextTrack)
- Previous Track (kMRPreviousTrack)
```

## Features

### Collapsed Notch (Always Visible)

-   **Album artwork thumbnail** - 32×32 rounded artwork via `AlbumArtworkView`
-   **Song title & artist** - Truncated text display with `AppTheme.Typography`
-   **Animated music bars** - Cyan-purple gradient `MusicBarsView` when music is playing
-   **Dynamic visibility** - Only shows media content when `mediaManager.currentMedia.hasContent`
-   **Smooth animations** - Multi-phase expansion (glow → scale → content)

### Expanded Dashboard (Hover to Open)

-   **Full media player** - 80×80 `AlbumArtworkWithBadge` with app icon overlay
-   **Song information** - Title, album (if available), and artist
-   **Media controls** - `PlaybackControlsRow` with Previous, Play/Pause, Next
-   **Tab switching** - Switch between "Nook" and "Tray" via `TabSwitcher`
-   **Quick actions** - `QuickActionPill` buttons (Spotify, Ring Labs)
-   **File tray** - `TrayView` with drag-and-drop file storage and AirDrop

## UI Components

### 1. NotchBarView

Main container that manages collapsed/expanded states:

-   Multi-phase animations (glow phase, scale phase, content phase)
-   `NotchShape` with sharp top corners, rounded bottom (12-16px radius)
-   Purple/blue/indigo gradient glow effects
-   File drag detection via `notchState.isDraggingFile`

### 2. DashboardView

Nook tab content with:

-   `AlbumArtworkWithBadge` (80×80 with Apple Music gradient badge)
-   Song info (title, album, artist) with `AppTheme.Typography`
-   `PlaybackControlsRow` for media controls
-   `QuickActionPill` buttons for quick actions

### 3. TrayView

Dropover-style file management:

-   `TrayStorageManager` for persistent file storage
-   `TrayFileChip` components with hover delete button
-   `AirDropState` for sharing animation management
-   Dashed border drop zone with blue highlight on drag

### 4. Media Components

-   `AlbumArtworkView` - Artwork with placeholder gradient
-   `AlbumArtworkWithBadge` - Artwork with app icon overlay
-   `PlaybackControlButton` - Individual control button (small/medium/large)
-   `PlaybackControlsRow` - Horizontal row of controls
-   `MusicBarsView` - Animated bars with configurable gradient

## How to Use

### Just Play Music!

1. **Open any music app** (Spotify, Apple Music, YouTube, etc.)
2. **Play a song**
3. **Watch your notch** - It will automatically show:
    - Album artwork
    - Song title and artist
    - Animated music bars

### Hover to Expand

1. **Move your mouse** over the notch area
2. **Dashboard expands** automatically with smooth animation
3. **Control playback** using the buttons:
    - Click play/pause button
    - Skip to next/previous track
    - See progress bar and time

### Switch Tabs

1. **In expanded view**, click "Nook" or "Tray" tabs
2. **Nook tab**: Shows media player and quick actions
3. **Tray tab**: Shows file management interface

### Quick Actions

-   **Spotify Top...**: Opens Spotify app or web
-   **Ring Labs**: Custom action (customize as needed)
-   **Mirror**: Camera/mirror functionality
-   **Screenshot**: Takes interactive screenshot
-   **Lock**: Locks your Mac screen
-   **Sleep**: Puts display to sleep

## Technical Details

### Required Permissions

The app needs these entitlements (already configured):

```xml
<key>com.apple.security.app-sandbox</key>
<false/>  <!-- Required for MediaRemote access -->

<key>com.apple.security.automation.apple-events</key>
<true/>   <!-- For controlling apps -->

<key>com.apple.security.files.user-selected.read-write</key>
<true/>   <!-- For file tray -->
```

### Info.plist Descriptions

User-friendly permission descriptions:

-   `NSAppleEventsUsageDescription`: For media control
-   `NSAppleMusicUsageDescription`: For music info
-   `NSSystemAdministrationUsageDescription`: For system actions

### MediaRemote Functions Used

```swift
MRMediaRemoteGetNowPlayingInfo()        // Gets current song info
MRMediaRemoteGetNowPlayingApplicationIsPlaying() // Playing state
MRMediaRemoteSendCommand()              // Controls (play/pause/next/prev)
```

## Customization

### Change Poll Interval

In `MediaPlayerManager.swift` and `AppConstants.swift`:

```swift
// AppConstants.swift
enum MediaPlayer {
    static let pollingInterval: TimeInterval = 0.5  // Change this value
    static let pollingTolerance: TimeInterval = 0.1
    static let commandDelay: TimeInterval = 0.1
}
```

### Modify Animation Timings

In `AppConstants.swift`:

```swift
enum Animation {
    static let glowDuration: TimeInterval = 0.35      // Glow phase duration
    static let scaleDuration: TimeInterval = 0.4     // Scale phase duration
    static let contentDelay: TimeInterval = 0.25     // Content appearance delay
    static let closeDelay: TimeInterval = 0.5        // Auto-collapse delay
    static let springResponse: Double = 0.35         // Spring animation response
    static let springDamping: Double = 0.8           // Spring animation damping
}
```

### Modify Album Artwork Sizes

In `AppConstants.swift`:

```swift
enum Layout {
    static let iconSize: CGFloat = 80           // Expanded state artwork
    static let smallIconSize: CGFloat = 32      // Collapsed state artwork
    static let cornerRadius: CGFloat = 14       // Artwork corner radius
    static let smallCornerRadius: CGFloat = 8   // Small artwork radius
}
```

### Customize Music Bars

In `MusicBarsView` initialization:

```swift
MusicBarsView(
    isPlaying: true,
    barCount: 3,                    // Number of bars
    barWidth: 3,                    // Bar width
    baseHeight: 6,                  // Minimum height
    maxHeight: 16,                  // Maximum height
    spacing: 2.5,                   // Space between bars
    gradient: AppTheme.Colors.musicGradient  // Custom gradient
)
```

### Add More Quick Actions

In `DashboardView.swift`, add new `QuickActionPill` buttons:

```swift
QuickActionPill(
    icon: "your.icon",
    title: "Your Action",
    iconColor: AppTheme.Colors.accentPurple
) {
    // Your action code
}
```

## Design Philosophy

The design follows **NotchNook principles**:

1. **Seamless Integration** - Custom `NotchShape` blends with MacBook notch
2. **Multi-Phase Animations** - Glow (0.35s) → Scale (0.4s) → Content (0.35s spring)
3. **Glassmorphic UI** - `cardStyle()` and `glassStyle()` view modifiers
4. **Hover Interaction** - Expand on hover, 0.5s delay auto-collapse
5. **Minimal Distraction** - Collapsed shows only essential info, expanded reveals full controls
6. **Consistent Theming** - All colors via `AppTheme.Colors`, typography via `AppTheme.Typography`

## Troubleshooting

### Music Not Showing?

1. **Check if music is playing** - The app only shows when `mediaManager.currentMedia.hasContent`
2. **Verify MediaRemote loaded** - Check console for "MediaRemote framework loaded successfully"
3. **Try different apps** - Test with Spotify, Apple Music, YouTube in browser
4. **Restart the app** - Sometimes needed after first install

### Controls Not Working?

1. **Grant permissions** - Check System Settings → Privacy & Security → Automation
2. **Check sandbox status** - App runs with sandbox disabled for MediaRemote access
3. **Verify commands sent** - Check console for media command logs

### Window Not Appearing?

1. **Check Activity Monitor** - Confirm NotchApp process is running
2. **App runs as accessory** - Won't appear in Dock (LSUIElement = true)
3. **Check window level** - Window should be at `.statusBar` level
4. **Verify screen position** - Window positioned at top center of main screen

### File Tray Not Working?

1. **Check drag detection** - Look for blue glow when dragging files near notch
2. **Verify TrayStorageManager** - Files persist in UserDefaults
3. **AirDrop issues** - Ensure AirDrop is enabled in Finder

## What Makes This Special

Unlike other music players that require:

-   ❌ Installing Spotify SDK
-   ❌ Logging into accounts
-   ❌ Granting API access
-   ❌ Running background services

**NotchApp** simply:

-   ✅ Taps into system Now Playing info
-   ✅ Works with ANY music source
-   ✅ No configuration needed
-   ✅ Lightweight and fast
-   ✅ Native macOS integration

## Future Enhancements

Consider adding:

-   [ ] Progress bar with seek functionality
-   [ ] Lyrics display integration
-   [ ] Volume control slider
-   [ ] AirPlay device selector
-   [ ] App-specific icons in collapsed state
-   [ ] Keyboard shortcuts for media control
-   [ ] Menu bar icon for settings access
-   [ ] System quick actions (Screenshot, Lock, Sleep)
-   [ ] Recently played history
-   [ ] Playlist management

## Conclusion

Your NotchApp now provides a **beautiful, functional, and automatic** music experience that works with every music player on your Mac. No setup, no configuration - just pure music enjoyment! 🎵

---

**Built with SwiftUI & MediaRemote Framework**
_Designed to match NotchNook's aesthetic_
