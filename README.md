# NotchApp - NotchNook-Inspired Music Display

A beautifully designed macOS app that seamlessly integrates with your MacBook's notch to display currently playing music from **ANY app**. Inspired by **NotchNook**, featuring smooth animations, glassmorphism design, and delightful interactions.

## 📖 Documentation

### User Guides

-   **[QUICK_START.md](QUICK_START.md)** - Get started in 3 steps
-   **[MUSIC_INTEGRATION.md](MUSIC_INTEGRATION.md)** - How music detection works
-   **[VISUAL_GUIDE.md](VISUAL_GUIDE.md)** - Visual features & design system

### Developer Guides

-   **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture & flow diagrams
-   **[SETUP.md](SETUP.md)** - Development environment setup
-   **[BUILD_AND_TEST.md](BUILD_AND_TEST.md)** - Build and test instructions
-   **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines

### Community

-   **[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)** - Community standards

## 🎵 **NEW: System-Wide Music Detection!**

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

-   🎵 **System-Wide Detection**: Automatically detects music from ANY app
-   🖼️ **Album Artwork Display**: Shows album art in collapsed and expanded views
-   ⏯️ **Universal Controls**: Play/pause, next, previous work with all apps
-   📊 **Progress Tracking**: Real-time progress bar with time display
-   🎨 **Animated Music Bars**: Green waving bars when music is playing
-   🔄 **Auto-Updates**: Polls every 0.5s for responsive updates

### UI/UX Design

-   🎨 **Seamless Notch Integration**: Looks like part of your MacBook's notch
-   🌊 **Fluid Spring Animations**: NotchNook-style smooth transitions
-   💎 **Glassmorphism Design**: Modern blur effects and layered materials
-   🎭 **Hover to Expand**: Smooth expansion with auto-collapse after 1s
-   📑 **Tab Switching**: Switch between Nook (media) and Tray (files)
-   🖱️ **Delightful Interactions**: Hover effects, press animations, visual feedback

### Quick Actions

-   ⚡ **Music Shortcuts**: Spotify Top Songs, custom actions
-   📸 **Screenshot Tool**: Interactive screenshot capture
-   🔒 **Lock Screen**: Instant Mac screen lock
-   🌙 **Sleep Display**: Put display to sleep
-   📹 **Mirror**: Camera/mirror functionality

### File Management

-   📂 **File Tray**: Drag and drop files for quick access
-   🔄 **Quick Share**: AirDrop, Share Sheet, Copy to clipboard
-   🖼️ **File Preview**: System icons and file info
-   ✨ **Beautiful UI**: Grid layout with hover effects

## 🎬 How It Works

### Collapsed State (Seamless Notch)

-   Black notch shape (150px wide) that blends with MacBook notch
-   Animated wave bars when music is playing (3 capsules with staggered animation)
-   Song title preview (truncated)
-   Subtle 1.02× scale on hover
-   Minimal screen space - just 32px tall

### Expanded State (On Hover)

The notch smoothly expands downward with spring animation, revealing:

-   **Notch connector** - Seamless bridge from screen bezel
-   **Glassmorphic card** - Ultra-thin material with gradient borders
-   **Album artwork** - 70×70 with rounded corners and shadow
-   **Song information** - Title and artist with gradient text
-   **Progress bar** - Capsule shape with gradient fill and glow
-   **Time indicators** - Monospaced, current/total duration
-   **Play/Pause button** - Circular button with smooth press animation

### Animation Details

-   **Expand**: 0.6s spring animation (damping 0.75)
-   **Hover**: 0.3s spring animation (damping 0.7)
-   **Button press**: 0.3s spring with 0.85× scale feedback
-   **Wave bars**: Continuous 0.6s ease-in-out with 0.2s stagger

## Setup Instructions

### 1. Configure Xcode Project

You need to link the Info.plist and entitlements file in your Xcode project:

1. Open `NotchApp.xcodeproj` in Xcode
2. Select the NotchApp target
3. Go to "Build Settings"
4. Search for "Info.plist File"
5. Set the path to: `NotchApp/Info.plist`
6. Go to "Signing & Capabilities"
7. Under "Code Signing Entitlements", set: `NotchApp/NotchApp.entitlements`

### 2. Grant Permissions

When you first run the app, macOS will ask for permissions:

-   **AppleScript/Automation Access**: Required to read Music app information
-   Click "OK" to allow access to Music.app

You can manually grant permissions in:

-   System Settings → Privacy & Security → Automation
-   Enable NotchApp → Music

### 3. Build and Run

```bash
# Open in Xcode
open NotchApp.xcodeproj

# Or build from command line
xcodebuild -project NotchApp.xcodeproj -scheme NotchApp -configuration Debug
```

## Architecture

### Key Components

#### Models

-   **`MediaInfo.swift`**: Data model for media information (title, artist, artwork, playback state)

#### ViewModels

-   **`MediaPlayerManager.swift`**: Manages media playback monitoring and AppleScript integration
    -   Polls Music app every second
    -   Handles play/pause commands
    -   Publishes media updates

#### Views

-   **`NotchBarView.swift`**: Main notch UI with collapse/expand animation
-   **`MediaDisplayView.swift`**: Expanded view showing full media details
-   **`NotchWindowController.swift`**: Manages the floating, borderless window

#### App Structure

-   **`NotchAppApp.swift`**: App entry point with AppDelegate
-   Hides from Dock (runs as accessory app)
-   Creates floating window at screen top

## Technical Details

### Window Configuration

-   **Level**: `.statusBar` - Always on top
-   **Style**: Borderless, transparent background
-   **Position**: Top center, 10px from screen edge
-   **Size**: 400x200 (adaptive to content)

### Media Integration

-   Uses AppleScript to communicate with Music.app
-   Falls back to MPNowPlayingInfoCenter when available
-   Updates every 1 second for real-time progress

### Animations

-   Spring animation (response: 0.4, damping: 0.8)
-   Scale + opacity transition for expand/collapse
-   Animated "playing" bars in collapsed state

## Permissions Required

### Info.plist Keys

-   `NSAppleEventsUsageDescription`: Control Music app
-   `NSAppleMusicUsageDescription`: Access Apple Music
-   `LSUIElement`: Hide from Dock

### Entitlements

-   `com.apple.security.app-sandbox`: App Sandbox
-   `com.apple.security.scripting-targets`: Music.app access
-   `com.apple.security.temporary-exception.apple-events`: AppleScript access

## Future Enhancements (Planned)

-   📸 Drag-and-drop tray for images/photos
-   🎬 Video player integration
-   ⚙️ Customization settings (size, position, appearance)
-   🔔 Notifications for song changes
-   ⌨️ Global keyboard shortcuts
-   🎨 Theme customization

## Troubleshooting

### App doesn't show media info

1. Make sure Music.app is running and playing media
2. Check System Settings → Privacy & Security → Automation
3. Ensure NotchApp has permission to control Music.app

### Window not appearing

1. Check that the app is running (look in Activity Monitor)
2. Try quitting and restarting the app
3. Check Console.app for any error messages

### AppleScript errors

-   Grant permissions in System Settings → Privacy & Security → Automation
-   You may need to restart the app after granting permissions

## Development

### Requirements

-   macOS 13.0 or later
-   Xcode 15.0 or later
-   Swift 5.9 or later

### Project Structure

```
NotchApp/
├── Models/
│   ├── MediaInfo.swift          # Media data model
│   ├── Notch.swift              # Core Data model (legacy)
│   └── Tag.swift                # Core Data model (legacy)
├── ViewModels/
│   └── MediaPlayerManager.swift # Media playback manager
├── Views/
│   ├── NotchBarView.swift       # Main notch UI
│   └── Components/
│       └── MediaDisplayView.swift # Expanded media view
├── NotchWindowController.swift   # Window management
├── NotchAppApp.swift            # App entry point
├── Info.plist                   # App permissions
└── NotchApp.entitlements        # Security entitlements
```

## 🤝 Contributing

We welcome contributions from the community! Whether it's bug fixes, new features, or documentation improvements, your help is appreciated.

### How to Contribute

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Make your changes** and commit (`git commit -m 'Add amazing feature'`)
4. **Push to your branch** (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

Please read our [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines and our [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for community standards.

### Contributors

Thanks to all the contributors who have helped make NotchApp better!

<!-- ALL-CONTRIBUTORS-LIST:START -->
<!-- This section will be automatically updated -->
<!-- ALL-CONTRIBUTORS-LIST:END -->

Want to see your name here? Check out [CONTRIBUTING.md](CONTRIBUTING.md) to get started!

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Credits

Created for macOS using SwiftUI and AppKit.

Inspired by NotchNook's beautiful design and seamless notch integration.
