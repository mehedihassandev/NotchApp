# Contributing to NotchApp

Thank you for your interest in contributing to NotchApp! This document provides guidelines and information for contributors.

## 📁 Project Structure

```
NotchApp/
├── Core/                           # Core infrastructure
│   ├── Constants/
│   │   └── AppConstants.swift      # Window (580×400), Animation, MediaPlayer, Layout, Opacity
│   ├── Extensions/
│   │   ├── View+Extensions.swift   # cardStyle, glassStyle, hoverScale, pressEffect, standardShadow
│   │   └── NSWindow+Extensions.swift # smoothResize, fadeIn/Out, NSScreen.notchHeight
│   ├── Protocols/
│   │   └── MediaControlling.swift  # MediaControlling protocol, MediaRemoteCommand enum, function types
│   ├── Theme/
│   │   └── AppTheme.swift          # Colors, Typography (rounded fonts), Shadows, Animations
│   └── Utilities/
│       ├── Logger.swift            # AppLogger with Category enum and global convenience functions
│       └── HapticManager.swift     # NSHapticFeedbackManager wrapper for Force Touch
│
├── Models/
│   └── MediaInfo.swift             # Identifiable, Equatable model with progress, formatting, placeholder
│
├── ViewModels/
│   ├── MediaPlayerManager.swift    # MediaRemote.framework integration with CFBundle loading
│   └── NotchState.swift            # Singleton ObservableObject, NotchTab enum (TabItem protocol)
│
├── Views/
│   ├── NotchBarView.swift          # Main container with multi-phase animations (glow/scale/content)
│   ├── DashboardView.swift         # Nook tab - AlbumArtworkWithBadge, PlaybackControlsRow, QuickActionPill
│   └── TrayView.swift              # Tray tab - TrayItem, TrayStorageManager, AirDropState, TrayFileChip
│
├── UI/
│   └── Components/
│       ├── Buttons/
│       │   └── ActionButtons.swift # QuickActionPill (pill buttons), IconButton (circular buttons)
│       ├── Effects/
│       │   └── VisualEffectView.swift # NSViewRepresentable for NSVisualEffectView
│       ├── Media/
│       │   ├── AlbumArtworkView.swift # With placeholder gradient and optional badge
│       │   ├── PlaybackControls.swift # PlaybackControlButton (sizes: small/medium/large)
│       │   └── MusicBarsView.swift # Timer-based animated bars with configurable gradient
│       ├── Navigation/
│       │   └── TabSwitcher.swift   # Generic TabSwitcher<Tab: TabItem> with matchedGeometryEffect
│       └── Shapes/
│           └── NotchShape.swift    # Custom Shape with sharp top, rounded bottom corners
│
├── Persistence/
│   └── PersistenceController.swift # Core Data stack with history tracking, preview support
│
├── NotchAppApp.swift               # @main entry, AppDelegate (accessory activation policy)
└── NotchWindowController.swift     # NotchWindow (NSWindow), DropTargetView (NSView), drag detection
```

## 🎨 Code Style Guidelines

### Swift Style

-   Use `// MARK: -` comments to organize code sections
-   Follow Apple's Swift naming conventions
-   Use `final` for classes that shouldn't be subclassed (e.g., `final class AppDelegate`, `final class NotchWindow`)
-   Prefer `private` access level by default
-   Use meaningful variable and function names
-   Use `@StateObject` for owned observable objects, `@ObservedObject` for passed-in objects
-   Prefer composition via extensions to organize code (see NotchBarView)

### File Organization

Each Swift file should follow this structure:

```swift
import SwiftUI

// MARK: - Type Name
/// Brief description of the type

struct/class TypeName {

    // MARK: - Properties
    @StateObject private var mediaManager = MediaPlayerManager()
    @State private var isHovering = false

    // MARK: - Initialization
    init(...) { }

    // MARK: - Body (for Views)
    var body: some View { ... }

    // MARK: - Public Methods

    // MARK: - Private Methods
}

// MARK: - Extensions (for organizing view code)
extension TypeName {
    private var collapsedNotch: some View { ... }
    private var expandedContent: some View { ... }
}

// MARK: - Preview
#Preview {
    TypeName()
}
```

### Documentation

-   Add documentation comments (`///`) for public APIs and types
-   Include parameter descriptions for complex functions
-   Use inline comments sparingly for non-obvious logic
-   Global logging functions available: `logDebug()`, `logInfo()`, `logWarning()`, `logError()`

## 🧩 Component Guidelines

### Creating Reusable Components

1. Place in appropriate `UI/Components/` subdirectory
2. Make configurable via parameters with sensible defaults
3. Include `#Preview` for visual development
4. Use `AppTheme` and `AppConstants` for styling
5. Support both light interactions (hover) and press feedback

Example (based on actual `QuickActionPill`):

```swift
struct QuickActionPill: View {

    // MARK: - Properties
    let icon: String
    let title: String
    let iconColor: Color
    let action: () -> Void

    @State private var isPressed = false
    @State private var isHovering = false

    // MARK: - Initialization
    init(
        icon: String,
        title: String,
        iconColor: Color = .white,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.iconColor = iconColor
        self.action = action
    }

    // MARK: - Body
    var body: some View {
        Button(action: handleTap) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(iconColor)

                Text(title)
                    .font(AppTheme.Typography.body())
                    .foregroundColor(AppTheme.Colors.textPrimary.opacity(0.9))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .cardStyle(isHovering: isHovering)
        }
        .buttonStyle(.plain)
        .pressEffect(isPressed)
        .onHover { hovering in
            withAnimation(AppTheme.Animations.hover) {
                isHovering = hovering
            }
        }
    }

    // MARK: - Actions
    private func handleTap() {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
            isPressed = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isPressed = false
            action()
        }
    }
}

#Preview {
    QuickActionPill(icon: "sparkles", title: "Spotify", iconColor: .green) { }
        .frame(width: 120)
        .padding()
        .background(Color.black)
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
-   Verify media controls with various apps (Spotify, Apple Music, YouTube, browser media)
-   Test hover interactions and multi-phase animations
-   Test file drag detection from Finder and other apps
-   Verify AirDrop integration in TrayView
-   Check tab switching between Nook and Tray with matched geometry
-   Test collapsed state media display (artwork, title, music bars)
-   Check for memory leaks with Instruments
-   Verify window positioning on different screen sizes

## 🌿 Branching Strategy

All development should happen in a dedicated branch, not on `main`. Please name your branches using the following convention:

-   **feature/<description>**: For new features (e.g., `feature/add-lyrics-support`)
-   **bugfix/<description>**: For fixing bugs (e.g., `bugfix/fix-crash-on-launch`)
-   **chore/<description>**: For maintenance tasks (e.g., `chore/update-dependencies`)
-   **docs/<description>**: For documentation changes (e.g., `docs/update-readme`)

## 💬 Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification. Each commit message should consist of a **type**, a **scope** (optional), and a **description**.

**Format**: `type(scope): description`

-   **Types**: `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `test`
-   **Example**: `feat(media): Add support for Apple Music playback`

## 📝 Pull Request Process

1.  **Branch and Commit**: Create a branch and make your changes with clear, conventional commit messages.
2.  **Push**: Push your branch to the remote repository: `git push origin feature/<your-branch-name>`
3.  **Create PR**: Open a pull request from your branch to the `main` branch.
4.  **Describe**: Provide a clear and concise description of your changes in the pull request.
5.  **Test**: Ensure your changes have been thoroughly tested.

## 🐛 Reporting Issues

Include:

-   macOS version
-   MacBook model
-   Steps to reproduce
-   Expected vs actual behavior
-   Screenshots/videos if applicable

## 📜 License

By contributing, you agree that your contributions will be licensed under the project's license.
