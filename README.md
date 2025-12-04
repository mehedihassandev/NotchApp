# NotchApp

A beautifully designed macOS app that seamlessly integrates with your MacBook's notch to display currently playing music from **ANY app**, featuring a **Dropover-style file tray** with AirDrop integration. Inspired by **NotchNook**, featuring smooth animations, glassmorphism design, and delightful interactions.

![macOS](https://img.shields.io/badge/macOS-13.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0+-green)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)
![Open Source](https://img.shields.io/badge/Open%20Source-%E2%9D%A4-red)

> **Built with ❤️ by [Md Mehedi Hassan](https://github.com/mdmehedihassan)**

## 📖 Documentation

### User Guides

-   **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture, component hierarchy & flow diagrams
-   **[MUSIC_INTEGRATION.md](MUSIC_INTEGRATION.md)** - How music detection works & customization

### Developer Guides

-   **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines & code style
-   **[ARCHITECTURE.md](ARCHITECTURE.md)** - Technical implementation details

### Community

-   **[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)** - Community standards

## 🎵 System-Wide Music Detection

**No configuration needed!** Just play music anywhere and it appears in your notch:

-   ✅ Spotify
-   ✅ Apple Music
-   ✅ YouTube (browser or app)
-   ✅ SoundCloud
-   ✅ Pandora
-   ✅ **ANY music app on your Mac!**

Uses Apple's `MediaRemote.framework` - the same API that powers Control Center, Lock Screen, and AirPods auto-switching.

## ✨ Features

### Music Integration

-   🎵 **System-Wide Detection** - Automatically detects music from ANY app via MediaRemote framework
-   🖼️ **Album Artwork Display** - Shows album art with app badge overlay in collapsed and expanded views
-   ⏯️ **Universal Controls** - Play/pause, next, previous work with all apps
-   📊 **Progress Tracking** - Real-time playback progress display
-   🎨 **Animated Music Bars** - Cyan-purple gradient animated bars when music is playing

### UI/UX Design

-   🎨 **Seamless Notch Integration** - Custom NotchShape blends with MacBook's notch
-   🌊 **Fluid Spring Animations** - Multi-phase animations (glow → scale → content)
-   💎 **Glassmorphism Design** - Modern blur effects with gradient borders
-   🎭 **Hover to Expand** - Auto-expand on hover with 0.5s auto-collapse delay
-   📑 **Tab Switching** - Switch between Nook (media) and Tray (files) with matched geometry
-   ✨ **Dynamic Glow Effects** - Purple/blue/indigo gradient glow when hovering

### Quick Actions

-   ⚡ **Quick Action Pills** - Spotify launcher, custom Ring Labs action
-   ⚙️ **Settings Access** - Settings gear button in expanded header

### File Tray (Dropover-style)

-   📂 **Persistent File Tray** - Drag and drop files with persistent storage
-   ✈️ **AirDrop Integration** - Direct AirDrop sharing with animated UI
-   🎯 **Smart File Detection** - Auto-expands notch when dragging files near it
-   🗑️ **File Management** - Hover to reveal delete button, click to open
-   🔗 **URL Support** - Supports both file URLs and web URLs
-   💾 **Persistent Storage** - Files persist between app restarts via TrayStorageManager

## 🚀 Quick Start

### 1. Clone & Open

```bash
git clone https://github.com/yourusername/NotchApp.git
cd NotchApp
open NotchApp.xcodeproj
```

### 2. Build & Run

```bash
# Using Xcode
# Press Cmd+R or click the Run button

# Or command line
xcodebuild -project NotchApp.xcodeproj -scheme NotchApp -configuration Debug build
```

### 3. Play Music

Open any music app (Spotify, Apple Music, YouTube) and play a song. The notch will automatically display the currently playing track!

## 🎬 How It Works

### Collapsed State

-   Custom NotchShape with sharp top corners, rounded bottom (12px radius)
-   Album artwork thumbnail (32×32) with rounded corners
-   Song title and artist text (truncated)
-   Animated MusicBarsView with cyan-purple gradient when playing
-   Blue glow effect and "Drop Files" indicator when dragging files nearby
-   Semi-transparent (50% opacity) with -22px offset when not hovering

### Expanded State (On Hover)

-   **Tab Switcher** - Nook/Tray tabs with matched geometry animation
-   **Nook Tab (DashboardView)**:
    -   Album artwork (80×80) with app badge overlay
    -   Song title, album, and artist information
    -   PlaybackControlsRow (Previous, Play/Pause, Next)
    -   QuickActionPill buttons (Spotify, Ring Labs)
-   **Tray Tab (TrayView)**:
    -   Dropover-style file shelf with horizontal scroll
    -   AirDrop drop zone with animated pulse rings
    -   TrayFileChip components for each stored file
-   **Settings Button** - IconButton in header

### Animation Details

-   **Glow Phase**: 0.35s ease-in-out
-   **Scale Phase**: 0.4s spring (response: 0.4, damping: 0.8)
-   **Content Phase**: 0.35s spring (response: 0.35, damping: 0.8)
-   **Auto-collapse**: 0.5s delay after mouse leaves
-   **Tab Switch**: Spring animation with matched geometry
-   **Button Press**: 0.2s spring with 0.9× scale feedback

## 🏗️ Project Structure

```
NotchApp/
├── Core/                              # Core infrastructure
│   ├── Constants/
│   │   └── AppConstants.swift         # Window, Animation, MediaPlayer, Layout, Opacity constants
│   ├── Extensions/
│   │   ├── View+Extensions.swift      # cardStyle, glassStyle, hoverScale, pressEffect, standardShadow
│   │   └── NSWindow+Extensions.swift  # smoothResize, fadeIn, fadeOut, NSScreen notch detection
│   ├── Protocols/
│   │   └── MediaControlling.swift     # MediaControlling protocol, MediaRemoteCommand, function types
│   ├── Theme/
│   │   └── AppTheme.swift             # Colors, Typography, Shadows, Animations design system
│   └── Utilities/
│       ├── Logger.swift               # AppLogger with categories (general, media, ui, window, persistence)
│       └── HapticManager.swift        # Force Touch trackpad haptic feedback
│
├── Models/
│   └── MediaInfo.swift                # Media data model with progress, formatted time, placeholder
│
├── ViewModels/
│   ├── MediaPlayerManager.swift       # MediaRemote framework integration, system-wide media control
│   └── NotchState.swift               # Singleton state manager, NotchTab enum with TabItem protocol
│
├── Views/
│   ├── NotchBarView.swift             # Main notch container with collapsed/expanded states
│   ├── DashboardView.swift            # Nook tab - media player + quick actions
│   └── TrayView.swift                 # Tray tab - TrayItem, TrayStorageManager, AirDropState
│
├── UI/Components/                     # Reusable UI components
│   ├── Buttons/
│   │   └── ActionButtons.swift        # QuickActionPill, IconButton with hover effects
│   ├── Effects/
│   │   └── VisualEffectView.swift     # NSVisualEffectView wrapper, blurBackground modifier
│   ├── Media/
│   │   ├── AlbumArtworkView.swift     # AlbumArtworkView, AlbumArtworkWithBadge
│   │   ├── PlaybackControls.swift     # PlaybackControlButton, PlaybackControlsRow
│   │   └── MusicBarsView.swift        # Animated music visualization bars
│   ├── Navigation/
│   │   └── TabSwitcher.swift          # Generic TabSwitcher with TabItem protocol
│   └── Shapes/
│       └── NotchShape.swift           # Custom notch shape (sharp top, rounded bottom)
│
├── Persistence/
│   └── PersistenceController.swift    # Core Data stack with preview support
│
├── NotchAppApp.swift                  # @main entry, AppDelegate with accessory policy
└── NotchWindowController.swift        # NotchWindow, DropTargetView, NotchWindowController
```

## ⚙️ Technical Details

### Window Configuration

-   **Window Size**: 580×400 pixels
-   **Level**: `.statusBar` - Always on top
-   **Style**: Borderless, fullSizeContentView, transparent background
-   **Position**: Top center of screen, aligned with notch
-   **Behavior**: canJoinAllSpaces, stationary, ignoresCycle, fullScreenAuxiliary
-   **Mouse Events**: Ignored when collapsed, captured when expanded

### Media Integration

-   Uses Apple's private `MediaRemote.framework`
-   **Functions**: MRMediaRemoteGetNowPlayingInfo, MRMediaRemoteGetNowPlayingApplicationIsPlaying, MRMediaRemoteSendCommand
-   **Polling**: 0.5s interval with 0.1s tolerance (via Timer.scheduledTimer)
-   **Commands**: togglePlayPause, nextTrack, previousTrack
-   Universal controls work with all media apps

### File Drag Detection

-   **DropTargetView**: NSView subclass registering for .fileURL drag types
-   **Drag Tracking Timer**: 0.1s polling to detect system-wide file drags
-   **Auto-expand**: Notch expands when files dragged near top-center of screen

### State Management

-   **NotchState**: Singleton ObservableObject for app-wide state
-   **TrayStorageManager**: Persistent file storage via UserDefaults/JSONEncoder
-   **AirDropState**: Manages AirDrop sharing UI state and animations

### Permissions Required

**Info.plist Keys:**

-   `NSAppleEventsUsageDescription` - Control Music app
-   `NSAppleMusicUsageDescription` - Access Apple Music
-   `LSUIElement` - Hide from Dock (runs as accessory app)

## 🔧 Requirements

-   macOS 13.0 (Ventura) or later
-   Xcode 15.0 or later
-   Swift 5.9 or later
-   MacBook with notch (recommended, but works on all Macs)

## 🐛 Troubleshooting

### Music not appearing?

1. Make sure music is actually playing
2. Try restarting the app
3. Grant automation permissions in System Settings → Privacy & Security

### Controls not working?

1. Check System Settings → Privacy & Security → Automation
2. Enable NotchApp permissions
3. Restart the app

### Window not appearing?

1. Check Activity Monitor to confirm app is running
2. The app runs as an accessory (won't appear in Dock)
3. Try quitting and restarting

## 🤝 Contributing

Contributions are welcome! This is an **open source project** and we love contributions from the community.

Please read our [Contributing Guidelines](CONTRIBUTING.md) before submitting a PR.

### How to Contribute

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 Md Mehedi Hassan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 👨‍💻 Author

**Md Mehedi Hassan**

-   GitHub: [@mdmehedihassan](https://github.com/mdmehedihassan)

## 🙏 Acknowledgments

-   Inspired by [NotchNook](https://notchnook.app/)
-   Built with SwiftUI & MediaRemote Framework
-   Thanks to all contributors who help improve this project

---

⭐ **Star this repo if you find it useful!**
