# Keyboard Shortcuts Guide

Welcome to NotchApp's keyboard shortcuts feature! This guide will help you understand and customize global hotkeys to control NotchApp from anywhere on your Mac.

## 🎹 Quick Reference

### Notch Control

| Action         | Default Shortcut | Description                      |
| -------------- | ---------------- | -------------------------------- |
| Toggle Notch   | `⌘⇧N`            | Show or hide the notch interface |
| Expand Notch   | `⌘⇧E`            | Always expand the notch          |
| Collapse Notch | `⌘⇧C`            | Collapse the notch               |

### Tab Navigation

| Action         | Default Shortcut | Description                  |
| -------------- | ---------------- | ---------------------------- |
| Switch to Nook | `⌘⇧1`            | Open Nook tab (media player) |
| Switch to Tray | `⌘⇧2`            | Open Tray tab (file storage) |

### Media Control

| Action         | Default Shortcut | Description           |
| -------------- | ---------------- | --------------------- |
| Play/Pause     | `⌘⇧P`            | Toggle media playback |
| Next Track     | `⌘⇧→`            | Skip to next track    |
| Previous Track | `⌘⇧←`            | Go to previous track  |

### App Control

| Action        | Default Shortcut | Description                |
| ------------- | ---------------- | -------------------------- |
| Open Settings | `⌘,`             | Open NotchApp settings     |
| Clear Tray    | `⌘⇧K`            | Remove all files from tray |

## 🚀 Getting Started

### Enabling Keyboard Shortcuts

1. Open NotchApp settings (`⌘,` or click the gear icon)
2. Navigate to the **"Shortcuts"** tab
3. Toggle **"Enable Keyboard Shortcuts"** on
4. All shortcuts are now active!

### How to Use

1. **Press your shortcut from anywhere** (e.g., `⌘⇧P` to pause music)
2. **Action happens immediately** - works even when you're in another app
3. **No need to focus NotchApp** - shortcuts are system-wide

### Customizing Shortcuts

1. Open NotchApp Settings → **Shortcuts**
2. Find the action you want to customize
3. Click on the shortcut recorder field
4. Press your desired key combination
5. The shortcut is saved automatically

**Tips:**

-   Use modifier keys (⌘, ⌥, ⌃, ⇧) to avoid conflicts
-   The system will warn you if a shortcut is already in use
-   Click the **"×"** button to remove a shortcut
-   Use **"Reset All"** to restore default shortcuts

## 🎯 Use Cases

### Productivity Workflows

**Quick Media Control Without Context Switching:**

```
Working in browser → Music playing → Press ⌘⇧P to pause → Continue working
No need to switch apps or focus NotchApp!
```

**Fast Tab Switching:**

```
Working anywhere → Press ⌘⇧2 → Notch expands to Tray tab → Drag file from Finder
```

**Keyboard-Only Navigation:**

```
Press ⌘⇧1 to open Nook → Control playback with ⌘⇧P/→/← → Press ⌘⇧C to collapse
All from your current app without switching!
```

### Power User Tips

1. **Combine with System Shortcuts:**

    - Use Mission Control (`^↑`) + NotchApp shortcuts for ultimate control
    - Combine with Spotlight (`⌘Space`) for file searching + quick tray access

2. **Create Shortcut Chains:**

    - `⌘⇧2` to open tray → Drop files → `⌘⇧1` to switch to music → `⌘⇧P` to play → `⌘⇧C` to collapse

3. **Minimal Mouse Usage:**
    - Never leave your keyboard - all shortcuts work from any app
    - Control media: `⌘⇧P`, `⌘⇧→`, `⌘⇧←`
    - Switch tabs: `⌘⇧1` or `⌘⇧2`
    - Toggle: `⌘⇧N` or `⌘⇧C`

## ⚙️ Technical Details

### How It Works

NotchApp uses the [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) library by Sindre Sorhus to register **global** hotkeys that work:

-   ✅ When NotchApp is in the background
-   ✅ When other apps are focused
-   ✅ Across all Spaces and virtual desktops
-   ✅ Even when NotchApp window is collapsed
-   ✅ Works system-wide without stealing focus

### Permissions

macOS requires **Accessibility permissions** for global keyboard shortcuts:

1. System Settings → **Privacy & Security** → **Accessibility**
2. Find **NotchApp** in the list
3. Toggle it **ON**

If NotchApp isn't listed, try:

-   Clicking the **"+"** button and manually adding NotchApp
-   Restarting NotchApp
-   Checking Console.app for permission errors

### Shortcut Storage

Your custom shortcuts are stored in:

```
~/Library/Preferences/com.mehedi.NotchApp.plist
```

They persist across:

-   ✅ App restarts
-   ✅ macOS updates
-   ✅ System reboots

To backup your shortcuts:

```bash
# Export shortcuts
defaults export com.mehedi.NotchApp ~/NotchApp-shortcuts.plist

# Import shortcuts
defaults import com.mehedi.NotchApp ~/NotchApp-shortcuts.plist
```

## 🐛 Troubleshooting

### Shortcuts Not Working?

**Check Accessibility Permissions:**

1. System Settings → Privacy & Security → Accessibility
2. Ensure NotchApp is enabled
3. Try removing and re-adding NotchApp

**Check if Shortcuts are Enabled:**

1. Open NotchApp Settings
2. Go to Shortcuts tab
3. Verify "Enable Keyboard Shortcuts" is ON

**Check for Conflicts:**

1. Your shortcut might conflict with another app
2. Try a different key combination
3. Check System Settings → Keyboard → Keyboard Shortcuts

**Still Not Working?**

1. Quit NotchApp completely
2. Restart your Mac
3. Reopen NotchApp
4. Check Console.app for errors (filter: "NotchApp")

### Shortcut Conflicts

If a shortcut doesn't work, it might conflict with:

-   System shortcuts (Mission Control, Spotlight, etc.)
-   Other apps' global shortcuts
-   Keyboard layout-specific keys

**Solution:** Choose unique combinations with multiple modifiers:

-   ✅ `⌘⇧⌥N` (Command + Shift + Option + N)
-   ✅ `⌃⌘→` (Control + Command + Right Arrow)
-   ❌ `⌘N` (Too common, likely used by other apps)

### Resetting Shortcuts

**Reset Individual Shortcut:**

1. Settings → Shortcuts
2. Click the shortcut recorder
3. Press `Delete` or `Backspace`
4. It will revert to default

**Reset All Shortcuts:**

1. Settings → Shortcuts
2. Scroll to bottom
3. Click **"Reset All"**
4. Confirm in dialog

**Nuclear Option (Clear All Settings):**

```bash
defaults delete com.mehedi.NotchApp
```

⚠️ This will reset ALL app settings, not just shortcuts!

## 🎨 Customization Examples

### Vim-Style Navigation

```
Switch to Nook: ⌘H
Switch to Tray: ⌘L
Previous Track: ⌘J
Next Track: ⌘K
```

### Arrow-Heavy Layout

```
Expand: ⌘⇧↑
Collapse: ⌘⇧↓
Previous: ⌘⇧←
Next: ⌘⇧→
```

### Minimalist Setup (Fewer Shortcuts)

```
Just use:
- Toggle Notch: ⌘⇧N
- Play/Pause: ⌘⇧P
- Open Settings: ⌘,
```

## 🔐 Privacy & Security

### What Data is Collected?

**None.** Keyboard shortcuts are:

-   ✅ Stored locally on your Mac
-   ✅ Never transmitted over the network
-   ✅ Not logged or tracked
-   ✅ Encrypted by macOS FileVault (if enabled)

### What Permissions are Needed?

**Accessibility Access:**

-   Required for global hotkey registration
-   Allows NotchApp to respond to keyboard events system-wide
-   Standard for all apps with global shortcuts (Alfred, Raycast, etc.)

**What We DON'T Access:**

-   ❌ Keylogging other apps
-   ❌ Password fields
-   ❌ Credit card forms
-   ❌ Secure input areas

We **only** listen for the exact key combinations you configure.

## 📚 Additional Resources

### Keyboard Shortcut Conventions

macOS has standard shortcut patterns:

| Pattern   | Typical Use                                   |
| --------- | --------------------------------------------- |
| `⌘` alone | Primary actions (New, Open, Close)            |
| `⌘⇧`      | Secondary actions (New Window, Save As)       |
| `⌘⌥`      | Tertiary actions (Advanced options, Settings) |
| `⌘,`      | Settings (system-wide, may conflict)          |
| `⌘Q`      | Quit (universal standard)                     |
| `⌘W`      | Close Window (universal standard)             |

### Useful Links

-   [KeyboardShortcuts Library](https://github.com/sindresorhus/KeyboardShortcuts) - The open-source library we use
-   [macOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos/user-interaction/keyboard/) - Apple's keyboard design guidelines
-   [NotchApp GitHub](https://github.com/mdmehedihassan/NotchApp) - Report issues or contribute

## 💡 Pro Tips

1. **Use Mnemonic Shortcuts:**

    - **N**otch = `⌘⇧N`
    - **P**lay = `⌘⇧P`
    - **E**xpand = `⌘⇧E`

2. **Keep Modifiers Consistent:**

    - All NotchApp shortcuts use `⌘⇧` by default
    - Easy to remember: "Command + Shift + [letter/arrow]"

3. **Learn Gradually:**

    - Start with 2-3 most-used shortcuts
    - Add more as you remember them
    - Print this guide or keep it in Notes.app

4. **Muscle Memory:**
    - Use shortcuts repeatedly for 1-2 weeks
    - They'll become automatic
    - Productivity boost is worth the learning curve

## 🤝 Contributing

Have ideas for new shortcuts? Found a bug?

1. Open an issue on [GitHub](https://github.com/mdmehedihassan/NotchApp/issues)
2. Submit a pull request with your improvements
3. Share your custom shortcut layouts with the community!

---

**Built with ❤️ by [Md Mehedi Hassan](https://github.com/mdmehedihassan)**

⭐ Star the repo if keyboard shortcuts make your workflow better!
