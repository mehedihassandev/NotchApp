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

-   **Album artwork thumbnail** - Shows the current song's cover art
-   **Song title & artist** - Displays in a compact, readable format
-   **Animated music bars** - Green animated bars when music is playing
-   **Dynamic width** - Expands when music is playing, compact when idle
-   **Smooth animations** - Matches the NotchNook design style

### Expanded Dashboard (Hover to Open)

-   **Full media player** - Large artwork, progress bar, time display
-   **Media controls** - Play/Pause, Previous, Next buttons
-   **Tab switching** - Switch between "Nook" and "Tray" views
-   **Quick actions** - Spotify shortcuts, Mirror, Screenshot, Lock, Sleep
-   **File tray** - Drag and drop files for quick access

## UI Components

### 1. NotchBarView

Main container that manages the collapsed/expanded states with smooth animations.

### 2. MediaDisplayView

Beautiful media player UI with:

-   Glassmorphic design
-   Progress bar with gradient
-   Hover effects on controls
-   Smooth play/pause animations

### 3. TrayView

File management interface:

-   Drag and drop support
-   File preview with system icons
-   Quick share actions (AirDrop, Share, Copy)
-   Grid layout for multiple files

### 4. LiveActionsView

Quick action buttons:

-   **Music Actions**: Spotify Top Songs, Ring Labs
-   **System Actions**: Mirror, Screenshot, Lock, Sleep

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

In `MediaPlayerManager.swift`:

```swift
timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true)
// Change 0.5 to adjust how often it checks for updates
```

### Modify Notch Width

In `NotchBarView.swift`:

```swift
private var notchWidth: CGFloat {
    if mediaManager.currentMedia.title != "No Media Playing" {
        return 280  // Change this for different width
    }
    return 150  // Width when no music playing
}
```

### Add More Quick Actions

In `LiveActionsView.swift`, add new buttons:

```swift
MusicActionButton(
    icon: "your.icon",
    title: "Your Action",
    color: Color.purple
) {
    // Your action code
}
```

## Design Philosophy

The design follows **NotchNook principles**:

1. **Seamless Integration** - Blends naturally with MacBook notch
2. **Smooth Animations** - Spring-based animations for organic feel
3. **Glassmorphic UI** - Translucent materials with subtle gradients
4. **Hover Interaction** - Expand on hover, collapse after 1 second
5. **Minimal Distraction** - Compact when collapsed, informative when expanded

## Troubleshooting

### Music Not Showing?

1. **Check if music is playing** - The app only shows active playback
2. **Try different apps** - Test with Spotify, Apple Music, YouTube
3. **Restart the app** - Sometimes needed after first install

### Controls Not Working?

1. **Grant permissions** - Check System Settings > Privacy & Security
2. **Enable Automation** - Allow NotchApp to control other apps
3. **Check app sandbox** - Make sure sandbox is disabled (already set to false)

### Performance Issues?

1. **Adjust poll rate** - Increase from 0.5s to 1.0s if needed
2. **Close unused tabs** - Switch between Nook/Tray as needed
3. **Limit files in tray** - Keep file count reasonable

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

-   [ ] Lyrics display
-   [ ] Music library integration
-   [ ] Custom shortcuts per app
-   [ ] Volume control slider
-   [ ] AirPlay device selector
-   [ ] Playlist management
-   [ ] Recently played history

## Conclusion

Your NotchApp now provides a **beautiful, functional, and automatic** music experience that works with every music player on your Mac. No setup, no configuration - just pure music enjoyment! 🎵

---

**Built with SwiftUI & MediaRemote Framework**
_Designed to match NotchNook's aesthetic_
