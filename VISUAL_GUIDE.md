# NotchApp Visual Guide (NotchNook-Inspired)

## UI States

### 1. Collapsed State (Default) - Seamless Notch Integration

```
┌─────────────────────────────────────────────────────────────┐
│                     Top of Screen                           │
├─────────────────────────────────────────────────────────────┤
│                        ┌─────────┐                          │
│                        │ ║║║ Song│  <- Black notch shape   │
│                        └─────────┘                          │
│                             ↑                               │
│                    Looks like MacBook notch                 │
```

**Elements:**

-   **Black notch shape** (150px wide, 32px tall) - mimics actual MacBook notch
-   **Animated bars** (3 vertical capsules) when music is playing
    -   Wave animation with 0.6s duration
    -   0.2s delay between each bar
    -   White color with 60% opacity
-   **Song title preview** - truncated to 80px max width
-   **Hover effect** - slight scale (1.02x) with smooth spring animation
-   **Rounded bottom corners** (16px radius) for seamless look

---

### 2. Expanded State (On Hover) - NotchNook Style

```
┌─────────────────────────────────────────────────────────────┐
│                     Top of Screen                           │
├─────────────────────────────────────────────────────────────┤
│                        ┌─────────┐                          │
│                        │  Notch  │   <- Connector           │
│                     ┌──┴─────────┴──┐                       │
│                     │ ┌────┐ Title  │                       │
│                     │ │ 70 │ Artist │   ◉                  │
│                     │ │ px │ ━━●━━━ │  Play                │
│                     │ └────┘ 0:00/3:45│                      │
│                     └─────────────────┘                      │
│                                                             │
```

**Layout:**

```
┌─────────────────────────────────────────────────┐
│  ┌─────┐  ┌──────────────────────┐  ┌─────┐   │
│  │     │  │ Song Title           │  │     │   │
│  │ 60  │  │ Artist Name          │  │ ⏯  │   │
│  │ x   │  │                      │  │     │   │
│  │ 60  │  │ ━━━━━━━━━━━━━━━━━─── │  │ 32px│   │
│  │     │  │ 1:23        3:45     │  │     │   │
│  └─────┘  └──────────────────────┘  └─────┘   │
│  Artwork        Info Area           Play/Pause │
└─────────────────────────────────────────────────┘
```

**Dimensions:**

-   Total width: ~350-400px (adaptive)
-   Height: ~100-120px
-   Padding: 16px all around
-   Spacing between elements: 16px

---

## Component Breakdown

### Artwork Section

-   Size: 60x60 pixels
-   Rounded corners: 8px radius
-   Fallback: Gray rectangle with music note icon
-   Shadow: Subtle drop shadow

### Info Section

-   **Title:** 14pt, semibold, primary color, 1 line max
-   **Artist:** 12pt, regular, secondary color, 1 line max
-   **Progress Bar:**
    -   Height: 4px
    -   Background: Gray (30% opacity)
    -   Fill: Accent color
    -   Rounded corners: 2px
-   **Time Labels:** 10pt, secondary color

### Play/Pause Button

-   Icon size: 32px
-   Colors: Accent color
-   States: play.circle.fill / pause.circle.fill
-   Hover: Slight scale effect
-   Click: Toggles Music.app playback

---

## Animations

### Collapse → Expand

```
Duration: 0.4s
Type: Spring animation
Damping: 0.8
Effects:
  - Scale from 1.0 → content size
  - Opacity 0 → 1
  - Anchor: Top center
```

### Expand → Collapse

```
Duration: 0.4s
Type: Spring animation
Damping: 0.8
Effects:
  - Scale to 1.0
  - Opacity → 0
  - Smooth transition
```

### Playing Indicator Bars

```
3 bars, animated independently
Delay: 0.15s between each
Duration: 0.5s each
Repeat: Forever
Effect: Height oscillation (8-12px)
```

---

## Color Scheme

### Light Mode

-   Background: Ultra-thin material (blurred)
-   Text Primary: Black/Dark gray
-   Text Secondary: Medium gray
-   Accent: Blue (system accent)
-   Borders: White (20% opacity)

### Dark Mode

-   Background: Ultra-thin material (blurred)
-   Text Primary: White
-   Text Secondary: Light gray
-   Accent: Blue (system accent)
-   Borders: White (20% opacity)

---

## Interaction States

### Collapsed State

| State       | Visual Change             |
| ----------- | ------------------------- |
| Default     | Small pill, subtle shadow |
| Hover       | Scale 1.05x, brighter     |
| Playing     | Animated bars visible     |
| Not Playing | Static music note only    |

### Expanded State

| State             | Visual Change                         |
| ----------------- | ------------------------------------- |
| Default           | Full content displayed                |
| Play Button Hover | Icon slightly larger                  |
| Progress Bar      | Current position updates every second |
| No Media          | Shows "No Media Playing" / "---"      |

---

## Window Properties

```
Position: Top center of screen
Offset from top: 10px
Level: Status bar (.statusBar)
Style: Borderless, transparent
Behavior:
  - Stays on top of all windows
  - Visible on all spaces
  - Ignores window cycling
  - Non-movable
  - Accepts mouse events
```

---

## User Flow

```
1. App Launches
   └─→ Window appears at top center
       └─→ Shows collapsed notch

2. User Hovers
   └─→ Notch expands with animation
       └─→ Media info becomes visible

3. User Clicks Play/Pause
   └─→ AppleScript command sent
       └─→ Music.app state changes
       └─→ UI updates within 1 second

4. User Moves Mouse Away
   └─→ Notch collapses with animation
       └─→ Returns to pill shape
```

---

## Data Flow

```
Music.app (Playing)
    ↓
MediaPlayerManager (Polls every 1s)
    ↓
AppleScript Query
    ↓
MediaInfo Model (Updated)
    ↓
@Published Property Changes
    ↓
NotchBarView (Re-renders)
    ↓
MediaDisplayView (Shows new data)
```

---

## Accessibility

-   All buttons have tooltips (`.help()` modifier)
-   Play/Pause: "Play" or "Pause" tooltip
-   Text is readable (minimum 10pt)
-   High contrast support via system materials
-   Keyboard accessible (future enhancement)

---

This visual guide helps understand how the NotchApp UI is structured and behaves!
