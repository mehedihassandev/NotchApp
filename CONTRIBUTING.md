# Contributing to NotchApp

Thank you for your interest in contributing to NotchApp! This document provides guidelines and information for contributors.

## 📁 Project Structure

```
NotchApp/
├── Core/                           # Core infrastructure
│   ├── Constants/
│   │   └── AppConstants.swift      # App-wide configuration values
│   ├── Extensions/
│   │   ├── View+Extensions.swift   # SwiftUI view modifiers
│   │   └── NSWindow+Extensions.swift
│   ├── Protocols/
│   │   └── MediaControlling.swift  # Media control abstractions
│   ├── Theme/
│   │   └── AppTheme.swift          # Design tokens and colors
│   └── Utilities/
│       ├── Logger.swift            # Logging utility
│       └── HapticManager.swift     # Haptic feedback
│
├── Models/
│   └── MediaInfo.swift             # Media data model
│
├── ViewModels/
│   ├── MediaPlayerManager.swift    # Media control logic
│   └── NotchState.swift            # Notch expansion state
│
├── Views/
│   ├── NotchBarView.swift          # Main notch interface
│   ├── DashboardView.swift         # Media player dashboard
│   └── TrayView.swift              # File tray view
│
├── UI/
│   └── Components/
│       ├── Buttons/
│       │   └── ActionButtons.swift # Reusable button components
│       ├── Effects/
│       │   └── VisualEffectView.swift
│       ├── Media/
│       │   ├── AlbumArtworkView.swift
│       │   ├── PlaybackControls.swift
│       │   └── MusicBarsView.swift
│       ├── Navigation/
│       │   └── TabSwitcher.swift
│       └── Shapes/
│           └── NotchShape.swift
│
├── Persistence/
│   └── PersistenceController.swift # Core Data management
│
├── NotchAppApp.swift               # App entry point
└── NotchWindowController.swift     # Window management
```

## 🎨 Code Style Guidelines

### Swift Style

-   Use `MARK: -` comments to organize code sections
-   Follow Apple's Swift naming conventions
-   Use `final` for classes that shouldn't be subclassed
-   Prefer `private` access level by default
-   Use meaningful variable and function names

### File Organization

Each Swift file should follow this structure:

```swift
import SwiftUI

// MARK: - Type Name
/// Brief description of the type

struct/class TypeName {

    // MARK: - Properties

    // MARK: - Initialization

    // MARK: - Body (for Views)

    // MARK: - Public Methods

    // MARK: - Private Methods
}

// MARK: - Extensions

// MARK: - Preview
```

### Documentation

-   Add documentation comments (`///`) for public APIs
-   Include parameter descriptions for complex functions
-   Use inline comments sparingly for non-obvious logic

## 🧩 Component Guidelines

### Creating Reusable Components

1. Place in appropriate `UI/Components/` subdirectory
2. Make configurable via parameters with sensible defaults
3. Include `#Preview` for visual development
4. Use `AppTheme` and `AppConstants` for styling

Example:

```swift
struct MyComponent: View {
    let title: String
    let size: CGFloat

    init(title: String, size: CGFloat = 44) {
        self.title = title
        self.size = size
    }

    var body: some View {
        // Implementation using AppTheme colors
    }
}

#Preview {
    MyComponent(title: "Example")
}
```

### Using the Theme System

Always use `AppTheme` for colors and typography:

```swift
// ✅ Good
Text("Hello")
    .font(AppTheme.Typography.title())
    .foregroundColor(AppTheme.Colors.textPrimary)

// ❌ Avoid
Text("Hello")
    .font(.system(size: 17, weight: .bold))
    .foregroundColor(.white)
```

### Using Constants

Use `AppConstants` for magic numbers:

```swift
// ✅ Good
.padding(AppConstants.Layout.padding)
.cornerRadius(AppConstants.Layout.cornerRadius)

// ❌ Avoid
.padding(16)
.cornerRadius(14)
```

## 🔧 Development Setup

1. Clone the repository
2. Open `NotchApp.xcodeproj` in Xcode
3. Select a macOS target with a notch (or any macOS 12+ target)
4. Build and run

## 🧪 Testing

-   Test on both notch and non-notch MacBooks
-   Verify media controls with various apps (Spotify, Apple Music, YouTube)
-   Test hover interactions and animations
-   Check for memory leaks with Instruments

## 📝 Pull Request Process

1. Create a feature branch from `main`
2. Follow the code style guidelines
3. Include relevant documentation
4. Test your changes thoroughly
5. Submit a PR with a clear description

## 🐛 Reporting Issues

Include:

-   macOS version
-   MacBook model
-   Steps to reproduce
-   Expected vs actual behavior
-   Screenshots/videos if applicable

## 📜 License

By contributing, you agree that your contributions will be licensed under the project's license.
