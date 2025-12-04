# NotchApp

A beautifully designed macOS app that seamlessly integrates with your MacBook's notch to display currently playing music from **ANY app**. Inspired by **NotchNook**, featuring smooth animations, glassmorphism design, and delightful interactions.

![macOS](https://img.shields.io/badge/macOS-13.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-4.0+-green)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)
![Open Source](https://img.shields.io/badge/Open%20Source-%E2%9D%A4-red)

> **Built with ❤️ by [Md Mehedi Hassan](https://github.com/mdmehedihassan)**

## 📖 Documentation

-   **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture & flow diagrams
-   **[MUSIC_INTEGRATION.md](MUSIC_INTEGRATION.md)** - How music detection works
-   **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines & code style

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

-   🎵 **System-Wide Detection** - Automatically detects music from ANY app
-   🖼️ **Album Artwork Display** - Shows album art in collapsed and expanded views
-   ⏯️ **Universal Controls** - Play/pause, next, previous work with all apps
-   📊 **Progress Tracking** - Real-time progress bar with time display
-   🎨 **Animated Music Bars** - Green waving bars when music is playing

### UI/UX Design

-   🎨 **Seamless Notch Integration** - Looks like part of your MacBook's notch
-   🌊 **Fluid Spring Animations** - NotchNook-style smooth transitions
-   💎 **Glassmorphism Design** - Modern blur effects and layered materials
-   🎭 **Hover to Expand** - Smooth expansion with auto-collapse
-   📑 **Tab Switching** - Switch between Nook (media) and Tray (files)

### Quick Actions

-   ⚡ **Music Shortcuts** - Spotify Top Songs, custom actions
-   📸 **Screenshot Tool** - Interactive screenshot capture
-   🔒 **Lock Screen** - Instant Mac screen lock
-   🌙 **Sleep Display** - Put display to sleep

### File Management

-   📂 **File Tray** - Drag and drop files for quick access
-   🔄 **Quick Share** - AirDrop, Share Sheet, Copy to clipboard
-   🖼️ **File Preview** - System icons and file info

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

-   Black notch shape that blends with MacBook notch
-   Animated wave bars when music is playing
-   Song title preview (truncated)
-   Subtle scale on hover

### Expanded State (On Hover)

-   **Glassmorphic card** with gradient borders
-   **Album artwork** with rounded corners and shadow
-   **Song information** - Title and artist
-   **Progress bar** with gradient fill
-   **Playback controls** - Previous, Play/Pause, Next

### Animation Details

-   **Expand**: Spring animation (response: 0.6, damping: 0.75)
-   **Hover**: Spring animation (response: 0.3, damping: 0.7)
-   **Button press**: Spring with 0.85× scale feedback

## 🏗️ Project Structure

```
NotchApp/
├── Core/                              # Core infrastructure
│   ├── Constants/
│   │   └── AppConstants.swift         # App-wide configuration
│   ├── Extensions/
│   │   ├── View+Extensions.swift      # SwiftUI view modifiers
│   │   └── NSWindow+Extensions.swift  # Window utilities
│   ├── Protocols/
│   │   └── MediaControlling.swift     # Media control abstraction
│   ├── Theme/
│   │   └── AppTheme.swift             # Design tokens & colors
│   └── Utilities/
│       ├── Logger.swift               # Logging utility
│       └── HapticManager.swift        # Haptic feedback
│
├── Models/
│   └── MediaInfo.swift                # Media data model
│
├── ViewModels/
│   ├── MediaPlayerManager.swift       # Media control logic
│   └── NotchState.swift               # Notch expansion state
│
├── Views/
│   ├── NotchBarView.swift             # Main notch interface
│   ├── DashboardView.swift            # Media player dashboard
│   └── TrayView.swift                 # File tray view
│
├── UI/Components/                     # Reusable UI components
│   ├── Buttons/
│   │   └── ActionButtons.swift
│   ├── Effects/
│   │   └── VisualEffectView.swift
│   ├── Media/
│   │   ├── AlbumArtworkView.swift
│   │   ├── PlaybackControls.swift
│   │   └── MusicBarsView.swift
│   ├── Navigation/
│   │   └── TabSwitcher.swift
│   └── Shapes/
│       └── NotchShape.swift
│
├── Persistence/
│   └── PersistenceController.swift    # Core Data management
│
├── NotchAppApp.swift                  # App entry point
└── NotchWindowController.swift        # Window management
```

## ⚙️ Technical Details

### Window Configuration

-   **Level**: `.statusBar` - Always on top
-   **Style**: Borderless, transparent background
-   **Position**: Top center of screen

### Media Integration

-   Uses Apple's private `MediaRemote.framework`
-   Polls for updates every 0.5 seconds
-   Universal controls work with all media apps

### Permissions Required

**Info.plist Keys:**

-   `NSAppleEventsUsageDescription` - Control Music app
-   `NSAppleMusicUsageDescription` - Access Apple Music
-   `LSUIElement` - Hide from Dock

## 🔧 Requirements

-   macOS 13.0 or later
-   Xcode 15.0 or later
-   Swift 5.9 or later
-   MacBook with notch (recommended)

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
