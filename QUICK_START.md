# Quick Start Guide - NotchApp Music Player

## 🎵 Instant Music Integration - Zero Setup Required!

Your NotchApp automatically detects and displays music from **ANY app** on your Mac. Here's everything you need to know:

## How to Use (3 Simple Steps)

### 1. Build & Run the App

```bash
# Open in Xcode
open NotchApp.xcodeproj

# Or build from command line
xcodebuild -project NotchApp.xcodeproj -scheme NotchApp build
```

### 2. Play Music Anywhere

-   Open **Spotify**, **Apple Music**, **YouTube**, or any music player
-   Play any song
-   **That's it!** The notch will automatically show your music

### 3. Control Your Music

-   **Hover** over the notch to see full controls
-   **Click** play/pause, next, or previous
-   **View** progress bar and time
-   Works with **all music apps** - no exceptions!

## What You'll See

### Collapsed View (Always Visible)

```
┌─────────────────────────────────────┐
│ 🎵 [Album Art] Song Title          │
│              Artist Name      |||   │
└─────────────────────────────────────┘
```

-   Compact and unobtrusive
-   Shows album artwork thumbnail
-   Animated bars when playing
-   Dynamic width based on content

### Expanded View (Hover to Show)

```
┌─────────────────────────────────────────┐
│           [Nook] [Tray]        ⚙️       │
├─────────────────────────────────────────┤
│  ┌──────┐                              │
│  │      │  Song Title                  │
│  │ Art  │  Artist Name                 │
│  │      │  ───────○─────  2:34 / 4:20  │
│  └──────┘    ⏮ ⏯ ⏭                    │
├─────────────────────────────────────────┤
│  ✨ Spotify Top...  🔔 Ring Labs        │
│  📹 Mirror  📸 Screenshot  🔒 Lock      │
└─────────────────────────────────────────┘
```

## Features Checklist

✅ **System-Wide Detection**

-   Spotify
-   Apple Music
-   YouTube Music
-   SoundCloud
-   Any music app

✅ **Media Controls**

-   Play/Pause
-   Next/Previous track
-   Progress bar
-   Time display

✅ **Beautiful UI**

-   Glassmorphic design
-   Smooth animations
-   Album artwork
-   Hover interactions

✅ **Quick Actions**

-   Open Spotify
-   Take screenshot
-   Lock screen
-   Sleep display
-   File management

✅ **No Configuration**

-   Zero setup
-   No API keys
-   No login required
-   Works immediately

## Keyboard Shortcuts (Native macOS)

While the app uses system media keys, you can still use:

-   **Play/Pause**: Your media key or Space in app
-   **Next**: Your next track key
-   **Previous**: Your previous track key

These will work through the MediaRemote framework!

## Permissions

On first run, macOS may ask for:

1. **Automation/Apple Events** → Click **OK**

    - Allows controlling music playback
    - Required for media controls

2. **Accessibility** (if prompted) → Click **Open System Settings**
    - Allows system-wide features
    - Optional for full functionality

## Tab Features

### 🎵 Nook Tab (Default)

-   Media player with full controls
-   Quick action buttons
-   System utilities

### 📦 Tray Tab

-   Drag & drop files
-   Quick file access
-   Share via AirDrop
-   File management

## Architecture

```
┌─────────────────────────────────────┐
│  NotchBarView (Main UI)            │
├─────────────────────────────────────┤
│  MediaPlayerManager                 │
│  ├─ MediaRemote Framework          │
│  ├─ Polling (0.5s interval)        │
│  └─ System Notifications           │
├─────────────────────────────────────┤
│  Views:                             │
│  ├─ DashboardView (Nook Tab)       │
│  ├─ TrayView (Tray Tab)            │
│  ├─ MediaDisplayView (Player UI)   │
│  └─ LiveActionsView (Quick Actions)│
└─────────────────────────────────────┘
```

## How It Detects Music

```swift
// Uses Apple's MediaRemote Framework
MRMediaRemoteGetNowPlayingInfo()
↓
Checks every 0.5 seconds
↓
Updates UI automatically
↓
Shows album art, title, artist, progress
```

**Works with ALL apps** because it taps into the same API that:

-   Control Center uses
-   Lock screen uses
-   AirPods use for auto-switching
-   Touch Bar uses

## Customization Tips

### Change Update Speed

Edit `MediaPlayerManager.swift`:

```swift
// Line ~108
timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true)
// Change 0.5 to 1.0 for less frequent updates
```

### Adjust Notch Size

Edit `NotchBarView.swift`:

```swift
// Line ~150+
private var notchWidth: CGFloat {
    if mediaManager.currentMedia.title != "No Media Playing" {
        return 280  // Change width here
    }
    return 150
}
```

### Add Custom Actions

Edit `LiveActionsView.swift`:

```swift
MusicActionButton(
    icon: "music.note.list",
    title: "Playlists",
    color: Color.purple
) {
    // Open playlists
}
```

## Testing Checklist

-   [ ] Build the app in Xcode
-   [ ] Run the app
-   [ ] Open Spotify/Apple Music
-   [ ] Play a song
-   [ ] Verify song info appears in notch
-   [ ] Hover over notch to expand
-   [ ] Test play/pause button
-   [ ] Test next/previous buttons
-   [ ] Switch to Tray tab
-   [ ] Drag a file to tray
-   [ ] Click quick actions

## Troubleshooting

### "Music not appearing"

→ Make sure music is actually playing
→ Try restarting the app
→ Test with Apple Music first (most reliable)

### "Controls not working"

→ Grant Automation permission in System Settings
→ Check Privacy & Security settings
→ Restart the app

### "App not building"

→ Clean build folder (Cmd+Shift+K)
→ Check Xcode version (14.0+)
→ Verify macOS target (12.0+)

## Pro Tips

1. **Auto-launch on startup**: Add to Login Items in System Settings
2. **Keep it hidden**: It runs in the menu bar (LSUIElement = true)
3. **Multiple music apps**: Works even if multiple apps are playing (shows active one)
4. **Browser music**: Works with YouTube, SoundCloud, Spotify Web Player
5. **Podcast apps**: Also works with podcast players!

## What's Different from NotchNook?

This implementation:

-   ✅ Fully open source
-   ✅ Customizable design
-   ✅ No subscription required
-   ✅ Privacy-focused (no tracking)
-   ✅ Native Swift/SwiftUI
-   ✅ Lightweight and fast

## Next Steps

1. **Build the app** → Xcode will compile everything
2. **Run it** → App appears in notch area
3. **Play music** → Enjoy automatic detection!
4. **Customize** → Make it your own

## File Structure

```
NotchApp/
├── NotchApp/
│   ├── NotchAppApp.swift          # App entry point
│   ├── NotchWindowController.swift # Window management
│   ├── ContentView.swift           # Root view
│   ├── ViewModels/
│   │   └── MediaPlayerManager.swift  # 🎵 Core music logic
│   ├── Views/
│   │   ├── NotchBarView.swift      # Main UI container
│   │   ├── DashboardView.swift     # Nook tab
│   │   ├── TrayView.swift          # Tray tab
│   │   └── Components/
│   │       ├── MediaDisplayView.swift    # Player UI
│   │       ├── LiveActionsView.swift     # Quick actions
│   │       └── [other components]
│   ├── Models/
│   │   └── MediaInfo.swift         # Data model
│   └── Shared/
│       └── Theme.swift             # Design system
└── MUSIC_INTEGRATION.md           # Full documentation
```

## Support

-   📖 Read `MUSIC_INTEGRATION.md` for detailed info
-   🐛 Found a bug? Check the code comments
-   💡 Want to add features? Edit the Swift files
-   🎨 Customize design? Check `Theme.swift`

---

**Enjoy your automatic music player!** 🎵

No configuration needed. Just build, run, and play music anywhere! ✨
