import KeyboardShortcuts
import SwiftUI

// MARK: - Keyboard Shortcuts Settings View
/// Settings view for customizing global keyboard shortcuts

struct KeyboardShortcutsSettingsView: View {

    // MARK: - State Properties
    @ObservedObject private var shortcutsManager = KeyboardShortcutsManager.shared
    @State private var showResetConfirmation = false

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                headerSection

                // Enable/Disable Toggle
                enableToggleSection

                if shortcutsManager.isEnabled {
                    Divider()

                    // Notch Control Shortcuts
                    notchControlSection

                    Divider()

                    // Tab Navigation Shortcuts
                    tabNavigationSection

                    Divider()

                    // Media Control Shortcuts
                    mediaControlSection

                    Divider()

                    // App Control Shortcuts
                    appControlSection

                    Divider()

                    // Reset to Defaults
                    resetSection
                }
            }
            .padding(24)
        }
        .frame(width: 550, height: 600)
        .alert("Reset Keyboard Shortcuts?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetAllShortcuts()
            }
        } message: {
            Text("This will reset all keyboard shortcuts to their default values.")
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Keyboard Shortcuts", systemImage: "keyboard")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)

            Text("Customize global keyboard shortcuts for quick access to NotchApp features.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Enable Toggle Section
    private var enableToggleSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Enable Keyboard Shortcuts")
                    .font(.system(size: 14, weight: .medium))

                Text("Allow global keyboard shortcuts to control NotchApp")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Toggle("", isOn: $shortcutsManager.isEnabled)
                .labelsHidden()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }

    // MARK: - Notch Control Section
    private var notchControlSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "Notch Control",
                icon: "macwindow",
                description: "Control notch expansion and collapse"
            )

            VStack(spacing: 12) {
                shortcutRow(
                    title: "Toggle Notch",
                    description: "Show or hide the notch interface",
                    shortcut: .toggleNotch
                )

                shortcutRow(
                    title: "Expand Notch",
                    description: "Always expand the notch",
                    shortcut: .expandNotch
                )

                shortcutRow(
                    title: "Collapse Notch",
                    description: "Always collapse the notch",
                    shortcut: .collapseNotch
                )
            }
        }
    }

    // MARK: - Tab Navigation Section
    private var tabNavigationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "Tab Navigation",
                icon: "rectangle.split.2x1",
                description: "Quickly switch between Nook and Tray"
            )

            VStack(spacing: 12) {
                shortcutRow(
                    title: "Switch to Nook",
                    description: "Open Nook tab (media player)",
                    shortcut: .switchToNook
                )

                shortcutRow(
                    title: "Switch to Tray",
                    description: "Open Tray tab (file storage)",
                    shortcut: .switchToTray
                )
            }
        }
    }

    // MARK: - Media Control Section
    private var mediaControlSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "Media Control",
                icon: "music.note",
                description: "Control media playback from anywhere"
            )

            VStack(spacing: 12) {
                shortcutRow(
                    title: "Play/Pause",
                    description: "Toggle media playback",
                    shortcut: .togglePlayPause
                )

                shortcutRow(
                    title: "Next Track",
                    description: "Skip to next track",
                    shortcut: .nextTrack
                )

                shortcutRow(
                    title: "Previous Track",
                    description: "Go to previous track",
                    shortcut: .previousTrack
                )
            }
        }
    }

    // MARK: - App Control Section
    private var appControlSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "App Control",
                icon: "gearshape",
                description: "Manage app settings and tray"
            )

            VStack(spacing: 12) {
                // Note about native settings shortcut
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                    Text("Use ⌘, to open Settings (native macOS shortcut)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)

                shortcutRow(
                    title: "Clear Tray",
                    description: "Remove all files from tray",
                    shortcut: .clearTray
                )
            }
        }
    }

    // MARK: - Reset Section
    private var resetSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Reset to Defaults")
                    .font(.system(size: 14, weight: .medium))

                Text("Restore all keyboard shortcuts to their default values")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button("Reset All") {
                showResetConfirmation = true
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }

    // MARK: - Helper Views

    private func sectionHeader(title: String, icon: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primary)

            Text(description)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
    }

    private func shortcutRow(title: String, description: String, shortcut: KeyboardShortcuts.Name) -> some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))

                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer()

            KeyboardShortcuts.Recorder(for: shortcut) {
                Text("Record Shortcut")
                    .font(.system(size: 11))
            }
            .frame(width: 180)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        )
    }

    // MARK: - Actions

    private func resetAllShortcuts() {
        // Reset all shortcuts to defaults
        KeyboardShortcuts.reset(.toggleNotch)
        KeyboardShortcuts.reset(.expandNotch)
        KeyboardShortcuts.reset(.collapseNotch)
        KeyboardShortcuts.reset(.switchToNook)
        KeyboardShortcuts.reset(.switchToTray)
        KeyboardShortcuts.reset(.togglePlayPause)
        KeyboardShortcuts.reset(.nextTrack)
        KeyboardShortcuts.reset(.previousTrack)
        KeyboardShortcuts.reset(.clearTray)

        HapticManager.shared.success()
        logInfo("All keyboard shortcuts reset to defaults", category: .general)
    }
}

// MARK: - Preview
#Preview {
    KeyboardShortcutsSettingsView()
}
