# NotchApp - System Architecture & Flow

```
╔═══════════════════════════════════════════════════════════════════════╗
║                          MUSIC PLAYS ANYWHERE                          ║
║  Spotify │ Apple Music │ YouTube │ SoundCloud │ Pandora │ Any App    ║
╚═══════════════════════════════════════════════════════════════════════╝
                                    │
                                    ▼
        ┌───────────────────────────────────────────────────┐
        │       macOS System Now Playing Service            │
        │   (Same API used by Control Center & Lock Screen) │
        └───────────────────────────────────────────────────┘
                                    │
                                    ▼
╔═══════════════════════════════════════════════════════════════════════╗
║                    MediaRemote.framework (Private)                     ║
║  • MRMediaRemoteGetNowPlayingInfo()                                   ║
║  • MRMediaRemoteGetNowPlayingApplicationIsPlaying()                   ║
║  • MRMediaRemoteSendCommand()                                         ║
╚═══════════════════════════════════════════════════════════════════════╝
                                    │
                                    ▼
        ┌───────────────────────────────────────────────────┐
        │          MediaPlayerManager.swift                  │
        │                                                    │
        │  📊 Polls every 0.5 seconds                       │
        │  📻 Listens to system notifications               │
        │  🎮 Sends control commands                        │
        │  📱 Updates @Published currentMedia               │
        └───────────────────────────────────────────────────┘
                                    │
                                    ▼
        ┌───────────────────────────────────────────────────┐
        │            MediaInfo Model                         │
        │  • title: String                                  │
        │  • artist: String                                 │
        │  • artwork: NSImage?                              │
        │  • isPlaying: Bool                                │
        │  • duration: TimeInterval                         │
        │  • currentTime: TimeInterval                      │
        └───────────────────────────────────────────────────┘
                                    │
                                    ▼
╔═══════════════════════════════════════════════════════════════════════╗
║                          NotchBarView.swift                            ║
║                         (Main UI Container)                            ║
╠═══════════════════════════════════════════════════════════════════════╣
║                                                                        ║
║  ┌────────────────────────────────────────────────────────────────┐  ║
║  │              COLLAPSED STATE (Always Visible)                   │  ║
║  │                                                                 │  ║
║  │  ┌──────┐  West End Blues        |||                          │  ║
║  │  │ 🎵  │  Louis Armstrong         |||  (MusicBarsView)        │  ║
║  │  └──────┘  (AlbumArtworkView)    |||                          │  ║
║  │                                                                 │  ║
║  │  • Min Width: 180px, Min Height: 36px                          │  ║
║  │  • Artwork: 32x32 via AlbumArtworkView                         │  ║
║  │  • Only shows content when hasContent = true                   │  ║
║  │  • Blue glow + "Drop Files" when isDraggingFile                │  ║
║  │  • Hover trigger: Multi-phase expand animation                 │  ║
║  └────────────────────────────────────────────────────────────────┘  ║
║                                   │                                    ║
║                    (Multi-Phase Expand Animation)                      ║
║             Glow (0.35s) → Scale (0.4s) → Content (0.35s spring)      ║
║                                   ▼                                    ║
║  ┌────────────────────────────────────────────────────────────────┐  ║
║  │              EXPANDED STATE (Hover Activated)                   │  ║
║  │                                                                 │  ║
║  │  ┌────────────────────────────────────────────────────────┐    │  ║
║  │  │  [🎵 Nook]  [📦 Tray]  (TabSwitcher)          ⚙️       │    │  ║
║  │  └────────────────────────────────────────────────────────┘    │  ║
║  │                                                                 │  ║
║  │  ┌─── Content Area (Switches Based on Tab) ────┐              │  ║
║  │  │                                              │              │  ║
║  │  │  Case .nook → DashboardView                 │              │  ║
║  │  │  Case .tray → TrayView                      │              │  ║
║  │  │                                              │              │  ║
║  │  └──────────────────────────────────────────────┘              │  ║
║  │                                                                 │  ║
║  │  • Window Size: 580×400 (AppConstants.Window)                  │  ║
║  │  • Animation: Spring (response: 0.35, damping: 0.8)            │  ║
║  │  • Auto-collapse: 0.5 second after mouse leaves                │  ║
║  │  • Bottom Corner Radius: 16px (12px when collapsed)            │  ║
║  └────────────────────────────────────────────────────────────────┘  ║
╚═══════════════════════════════════════════════════════════════════════╝
                    │                              │
        ┌───────────┴───────────┐      ┌──────────┴──────────┐
        │                       │      │                     │
        ▼                       ▼      ▼                     ▼
┌────────────────┐    ┌────────────────┐          ┌──────────────────┐
│ NOOK TAB       │    │ TRAY TAB       │          │ Tab Switcher     │
│ (Dashboard)    │    │ (File Mgmt)    │          │ • Matched        │
└────────────────┘    └────────────────┘          │   Geometry       │
        │                       │                  │ • Smooth         │
        ▼                       ▼                  │   Transition     │
                                                   └──────────────────┘

╔═══════════════════════════════════════════════════════════════════════╗
║                      NOOK TAB (DashboardView)                          ║
╠═══════════════════════════════════════════════════════════════════════╣
║                                                                        ║
║  ┌────────────────────────────────────────────────────────────────┐  ║
║  │                    Media Player Section                        │  ║
║  │  ┌──────────┐  ┌────────────────────────┐  ┌──────────────┐   │  ║
║  │  │  Album   │  │ West End Blues         │  │   ⏮  ⏸  ⏭  │   │  ║
║  │  │  Artwork │  │ Jazz Classics (album)  │  │              │   │  ║
║  │  │  80x80   │  │ Louis Armstrong        │  │  Playback    │   │  ║
║  │  │  +Badge  │  │ (artist)               │  │  Controls    │   │  ║
║  │  └──────────┘  └────────────────────────┘  └──────────────┘   │  ║
║  │  AlbumArtwork   songInfoAndControls       PlaybackControlsRow │  ║
║  │  WithBadge      (title, album, artist)                        │  ║
║  └────────────────────────────────────────────────────────────────┘  ║
║                                                                        ║
║  ┌────────────────────────────────────────────────────────────────┐  ║
║  │                    Quick Actions Section                       │  ║
║  │                                                                │  ║
║  │  QuickActionPill Buttons (VStack, width: 120):                │  ║
║  │  ┌──────────────────────┐                                     │  ║
║  │  │ ✨ Spotify           │  (iconColor: accentGreen)          │  ║
║  │  └──────────────────────┘                                     │  ║
║  │  ┌──────────────────────┐                                     │  ║
║  │  │ ✨ Ring Laís         │  (iconColor: accentYellow)         │  ║
║  │  └──────────────────────┘                                     │  ║
║  │                                                                │  ║
║  │  Note: No system actions (Screenshot, Lock, Sleep) currently  │  ║
║  └────────────────────────────────────────────────────────────────┘  ║
╚═══════════════════════════════════════════════════════════════════════╝

╔═══════════════════════════════════════════════════════════════════════╗
║                      TRAY TAB (TrayView)                               ║
╠═══════════════════════════════════════════════════════════════════════╣
║                                                                        ║
║  ┌────────────────────────────────────────────────────────────────┐  ║
║  │                    Files Tray Section                          │  ║
║  │                                                                │  ║
║  │  Empty State:                                                 │  ║
║  │  ┌──────────────────────────────────────────┐                │  ║
║  │  │   🗂️  Files Tray                         │                │  ║
║  │  │   (tray.fill / tray.and.arrow.down.fill) │                │  ║
║  │  │   Changes to "Drop Files Here" when      │                │  ║
║  │  │   isDraggingFile = true with blue color  │                │  ║
║  │  └──────────────────────────────────────────┘                │  ║
║  │                                                                │  ║
║  │  With Files (Horizontal ScrollView):                          │  ║
║  │  ┌─────────┐  ┌─────────┐  ┌─────────┐                       │  ║
║  │  │TrayFile │  │TrayFile │  │TrayFile │                       │  ║
║  │  │ Chip    │  │ Chip    │  │ Chip    │ ...                   │  ║
║  │  └─────────┘  └─────────┘  └─────────┘                       │  ║
║  │                                                                │  ║
║  │  • Dashed border (strokeBorder with dash: [7, 5])             │  ║
║  │  • Blue highlight when drop target / isDraggingFile           │  ║
║  │  • Accepts: .fileURL, .url, .text                             │  ║
║  │  • Persistent storage via TrayStorageManager (UserDefaults)   │  ║
║  └────────────────────────────────────────────────────────────────┘  ║
║                                                                        ║
║  ┌────────────────────────────────────────────────────────────────┐  ║
║  │                    AirDrop Section                             │  ║
║  │                                                                │  ║
║  │              ┌─────────────────┐                              │  ║
║  │              │   ○   (pulse)   │                              │  ║
║  │              │  ○ ○  (rings)   │                              │  ║
║  │              │ ○ ○ ○           │                              │  ║
║  │              │                 │                              │  ║
║  │              │    AirDrop      │                              │  ║
║  │              │ "Share X items" │                              │  ║
║  │              └─────────────────┘                              │  ║
║  │                                                                │  ║
║  │  • Width: 140px fixed                                         │  ║
║  │  • Animated pulse rings when isAirDropDropTargeted            │  ║
║  │  • Concentric circles with accentBlue gradient                │  ║
║  │  • AirDropState manages sharing animations                    │  ║
║  └────────────────────────────────────────────────────────────────┘  ║
╚═══════════════════════════════════════════════════════════════════════╝


═══════════════════════════════════════════════════════════════════════
                           DATA FLOW DIAGRAM
═══════════════════════════════════════════════════════════════════════

Music Playing → System API → MediaRemote → MediaPlayerManager
                                                     │
                                                     ▼
                                            @Published Updates
                                                     │
                                    ┌────────────────┴─────────────────┐
                                    │                                  │
                                    ▼                                  ▼
                            Collapsed Notch                    Expanded Dashboard
                            (Album + Title)                     (Full Controls)
                                    │                                  │
                                    └──────────────┬───────────────────┘
                                                   │
                                              User Clicks
                                              (Play/Next)
                                                   │
                                                   ▼
                                         MRMediaRemoteSendCommand
                                                   │
                                                   ▼
                                              System API
                                                   │
                                                   ▼
                                         Music App Responds


═══════════════════════════════════════════════════════════════════════
                          ANIMATION TIMELINE
═══════════════════════════════════════════════════════════════════════

Mouse Enters Notch Area (Multi-Phase Expand):
    t=0.0s   → isHovering = true, glowIntensity = 1
    t=0.0s   → Glow animation starts (0.35s ease-in-out)
    t=0.1s   → Scale phase starts (scaleProgress → 1.0)
    t=0.25s  → Content phase starts (showContent = true)
    t=0.35s  → notchState.isExpanded = true
    t=0.6s   → Fully expanded (spring settles)

Mouse Leaves Notch Area:
    t=0.0s   → Start 0.5 second timer (AppConstants.Animation.closeDelay)
    t=0.5s   → Timer fires, check !isMouseInside && !isDraggingFile
    t=0.5s   → showContent = false, isExpanded = false (0.25s ease-out)
    t=0.65s  → scaleProgress = 0.5 (0.3s ease-out)
    t=0.75s  → isHovering = false, glowIntensity = 0 (0.35s ease-out)
    t=1.1s   → Fully collapsed

Tab Switch:
    t=0.0s   → User clicks tab
    t=0.0s   → withAnimation(AppTheme.Animations.spring)
    t=0.0-0.35s → matchedGeometryEffect transition for selection indicator
    t=0.35s  → Content switches with spring animation

File Drag Detection:
    t=0.0s   → System detects file drag near notch area (300x60 rect)
    t=0.0s   → notchState.fileDragEntered() called
    t=0.0s   → isDraggingFile = true, shouldShowTray = true
    t=0.0s   → selectedTab switches to .tray
    t=0.0s   → Blue glow appears, notch expands if collapsed


═══════════════════════════════════════════════════════════════════════
                       COMPONENT HIERARCHY
═══════════════════════════════════════════════════════════════════════

NotchAppApp (@main)
└── AppDelegate
    └── NotchWindowController
        └── NotchWindow (NSWindow subclass)
            ├── DropTargetView (NSView for drag detection)
            └── NSHostingView
                └── NotchBarView
                    ├── @StateObject: mediaManager (MediaPlayerManager)
                    ├── @StateObject: notchState (NotchState.shared)
                    ├── @State: isHovering, showContent, glowIntensity, scaleProgress
                    ├── @State: selectedTab (NotchTab), isMouseInside, closeTimer
                    │
                    ├── Collapsed State (when !showContent)
                    │   ├── collapsedDropIndicator (when isDraggingFile)
                    │   └── collapsedMediaContent (when hasContent)
                    │       ├── AlbumArtworkView (32x32)
                    │       ├── Song info (title, artist)
                    │       └── MusicBarsView (when isPlaying)
                    │
                    └── Expanded State (when showContent)
                        ├── expandedHeader
                        │   ├── tabSwitcher (inline TabSwitcher)
                        │   └── IconButton (settings gear)
                        │
                        └── Tab Content (switch selectedTab)
                            ├── Case .nook → DashboardView
                            │   ├── mediaPlayerSection
                            │   │   ├── AlbumArtworkWithBadge (80x80)
                            │   │   └── songInfoAndControls
                            │   │       ├── Title, Album, Artist text
                            │   │       └── PlaybackControlsRow
                            │   └── quickActionsSection
                            │       ├── QuickActionPill (Spotify)
                            │       └── QuickActionPill (Ring Laís)
                            │
                            └── Case .tray → TrayView
                                ├── filesTraySection
                                │   ├── emptyTrayState (when items.isEmpty)
                                │   └── filesScrollView (with TrayFileChip)
                                └── airDropSection
                                    └── airDropDropZone (animated circles)


═══════════════════════════════════════════════════════════════════════
                         KEY MEASUREMENTS (from AppConstants)
═══════════════════════════════════════════════════════════════════════

Window Configuration (AppConstants.Window):
  • Width: 580px
  • Height: 400px
  • Collapsed Offset: -22px (hides top portion)
  • Tracking Area Height: 50px

Collapsed Notch:
  • Min Width: 180px
  • Min Height: 36px
  • Artwork: 32x32px (smallIconSize)
  • Corner Radius: 8px (smallCornerRadius)
  • Bottom Corner Radius: 12px (NotchShape)
  • Font: body (12pt), caption (10pt)

Expanded Dashboard:
  • Bottom Corner Radius: 16px (NotchShape)
  • Padding: 16px (AppConstants.Layout.padding)
  • Header Top Padding: 16px, Bottom: 14px
  • Content Bottom Padding: 18px

Media Player (DashboardView):
  • Artwork: 80x80px (iconSize)
  • Corner Radius: 14px
  • Badge Size: 24px (30% of artwork)
  • Font: title (17pt bold), body (12pt), caption (10pt)

Playback Controls:
  • Small: icon 14pt, hit area 30px
  • Medium: icon 18pt, hit area 40px
  • Large: icon 24pt, hit area 50px

Tab Buttons:
  • Horizontal Padding: 14px
  • Vertical Padding: 8px
  • Icon: 11pt semibold
  • Text: 12pt (body)
  • Selection: 10px corner radius

Quick Action Pills:
  • Horizontal Padding: 12px
  • Vertical Padding: 10px
  • Icon: 10pt bold
  • Width: 120px (frame)

Tray View:
  • AirDrop Section Width: 140px
  • Drop Zone Corner Radius: 16px
  • Dashed Border: lineWidth 2, dash [7, 5]

MusicBarsView:
  • Bar Count: 3
  • Bar Width: 3px
  • Base Height: 6px
  • Max Height: 16px
  • Spacing: 2.5px


═══════════════════════════════════════════════════════════════════════
                       PERFORMANCE METRICS
═══════════════════════════════════════════════════════════════════════

Media Polling (AppConstants.MediaPlayer):
  • Interval: 0.5 seconds (pollingInterval)
  • Tolerance: 0.1 seconds (pollingTolerance)
  • Command Delay: 0.1 seconds (commandDelay)
  • CPU Impact: <1%

File Drag Detection:
  • Timer Interval: 0.1 seconds
  • Detection Area: 300x60 rect at top-center of screen

UI Updates:
  • @Published triggers: Automatic SwiftUI diff
  • Animation FPS: 60fps
  • Render time: <16ms per frame

Memory:
  • Base: ~30MB
  • With artwork: ~40-50MB
  • Artwork cache: Managed by NSImage
  • Tray storage: UserDefaults (JSON encoded)


═══════════════════════════════════════════════════════════════════════
```

## Quick Reference

### Main Components

-   **NotchBarView.swift** - Main container with collapsed/expanded states
-   **MediaPlayerManager.swift** - MediaRemote.framework integration
-   **NotchState.swift** - Singleton state manager, NotchTab enum
-   **DashboardView.swift** - Nook tab: media player + quick actions
-   **TrayView.swift** - Tray tab: TrayStorageManager, AirDropState, TrayFileChip
-   **NotchWindowController.swift** - NotchWindow (NSWindow), DropTargetView

### Key States

-   `isHovering` - Controls glow effect visibility
-   `showContent` - Controls collapsed/expanded content
-   `glowIntensity` - Glow animation progress (0-1)
-   `scaleProgress` - Scale animation progress (0.5-1.0)
-   `selectedTab` - Active tab (NotchTab: .nook or .tray)
-   `notchState.isExpanded` - Global expansion state
-   `notchState.isDraggingFile` - File drag detection state
-   `currentMedia` - Currently playing media info (MediaInfo)

### Animations (AppConstants.Animation)

-   **Glow**: easeInOut (0.35s)
-   **Scale**: spring (response: 0.4, damping: 0.8)
-   **Content**: spring (response: 0.35, damping: 0.8)
-   **Close Delay**: 0.5s timer
-   **Hover**: easeInOut (0.15s)

### Data Flow

Music App → System API → MediaRemote → MediaPlayerManager → @Published → NotchBarView → User → Controls → MRMediaRemoteSendCommand → System API → Music App
