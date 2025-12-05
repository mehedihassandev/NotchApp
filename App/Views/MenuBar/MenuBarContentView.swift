import SwiftUI
import KeyboardShortcuts

// MARK: - Menu Bar Content View
/// Main content view for the MenuBarExtra dropdown menu
/// Provides quick access to media controls, tray, settings, and app functions

struct MenuBarContentView: View {

    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss

    // MARK: - State Properties
    @ObservedObject private var notchState = NotchState.shared
    @StateObject private var mediaManager = MediaPlayerManager()
    @ObservedObject private var trayStorage = TrayStorageManager.shared
    @ObservedObject private var updateManager = UpdateManager.shared

    @State private var isCheckingForUpdates = false
    @State private var hoveredButton: String?

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Header Section
            headerSection

            Divider()

            // Media Section (if playing)
            if !mediaManager.currentMedia.title.isEmpty && mediaManager.currentMedia.title != "Not Playing" {
                mediaSection
                Divider()
            }

            // Tray Section (if items exist)
            if !trayStorage.items.isEmpty {
                traySection
                Divider()
            }

            // Quick Actions
            quickActionsSection

            Divider()

            // Settings & About
            settingsSection

            Divider()

            // Quit Button
            quitSection
        }
        .frame(width: 280)
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "macbook")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)

                VStack(alignment: .leading, spacing: 2) {
                    Text("NotchApp")
                        .font(.system(size: 14, weight: .semibold))

                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                        Text("Version \(version)")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Status indicator
                Circle()
                    .fill(notchState.isExpanded ? Color.green : Color.gray)
                    .frame(width: 8, height: 8)
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 8)
        }
    }

    // MARK: - Media Section
    private var mediaSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "music.note")
                    .font(.system(size: 12))
                    .foregroundColor(.blue)

                Text("Now Playing")
                    .font(.system(size: 12, weight: .medium))

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)

            // Track Info
            VStack(alignment: .leading, spacing: 4) {
                Text(mediaManager.currentMedia.title)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)

                Text(mediaManager.currentMedia.artist)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)

            // Media Controls
            HStack(spacing: 16) {
                Button {
                    performMediaAction {
                        NotificationCenter.default.post(name: .mediaPreviousTrack, object: nil)
                        HapticManager.shared.playFeedback(.light)
                    }
                } label: {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                }
                .buttonStyle(.plain)
                .help("Previous Track")

                Button {
                    performMediaAction {
                        NotificationCenter.default.post(name: .mediaTogglePlayPause, object: nil)
                        HapticManager.shared.playFeedback(.medium)
                    }
                } label: {
                    Image(systemName: "playpause.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.primary)
                }
                .buttonStyle(.plain)
                .help("Play/Pause")

                Button {
                    performMediaAction {
                        NotificationCenter.default.post(name: .mediaNextTrack, object: nil)
                        HapticManager.shared.playFeedback(.light)
                    }
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                }
                .buttonStyle(.plain)
                .help("Next Track")
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
    }

    // MARK: - Tray Section
    private var traySection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "tray.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.blue)

                Text("Tray")
                    .font(.system(size: 12, weight: .medium))

                Spacer()

                Text("\(trayStorage.items.count)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.blue)
                    )
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)

            // Tray Items (show first 3)
            VStack(spacing: 4) {
                ForEach(trayStorage.items.prefix(3)) { item in
                    HStack(spacing: 8) {
                        Image(systemName: "doc.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)

                        Text(item.url.lastPathComponent)
                            .font(.system(size: 11))
                            .lineLimit(1)

                        Spacer()
                    }
                    .padding(.horizontal, 12)
                }

                if trayStorage.items.count > 3 {
                    HStack {
                        Text("+ \(trayStorage.items.count - 3) more")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                }
            }

            // Tray Actions
            HStack(spacing: 8) {
                Button {
                    performAction {
                        notchState.selectedTab = .tray
                        notchState.isExpanded = true
                        HapticManager.shared.playFeedback(.light)
                    }
                } label: {
                    Label("Open Tray", systemImage: "tray")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)

                Spacer()

                if !trayStorage.items.isEmpty {
                    Button {
                        performAction {
                            NotificationCenter.default.post(name: .clearTray, object: nil)
                            HapticManager.shared.playFeedback(.heavy)
                        }
                    } label: {
                        Label("Clear", systemImage: "trash")
                            .font(.system(size: 11))
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
    }

    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(spacing: 4) {
            Text("Quick Actions")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.top, 8)

            // Collapse/Expand Notch
            Button {
                performAction {
                    withAnimation(AppTheme.Animations.springFast) {
                        notchState.isExpanded.toggle()
                    }
                    HapticManager.shared.playFeedback(.medium)
                }
            } label: {
                HStack {
                    Image(systemName: notchState.isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                    Text(notchState.isExpanded ? "Collapse Notch" : "Expand Notch")
                        .font(.system(size: 13))
                        .foregroundColor(.primary)
                    Spacer()
                    Text(notchState.isExpanded ? "⌘⇧C" : "⌘⇧E")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    hoveredButton == "collapse" ? Color.gray.opacity(0.15) : Color.clear
                )
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                hoveredButton = hovering ? "collapse" : nil
            }

            // Media Player
            Button {
                performAction {
                    notchState.selectedTab = .nook
                    if !notchState.isExpanded {
                        withAnimation(AppTheme.Animations.springFast) {
                            notchState.isExpanded = true
                        }
                    }
                    HapticManager.shared.playFeedback(.light)
                }
            } label: {
                HStack {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                    Text("Media Player")
                        .font(.system(size: 13))
                        .foregroundColor(.primary)
                    Spacer()
                    Text("⌘⇧1")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    hoveredButton == "media" ? Color.gray.opacity(0.15) : Color.clear
                )
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                hoveredButton = hovering ? "media" : nil
            }

            // File Tray
            Button {
                performAction {
                    notchState.selectedTab = .tray
                    if !notchState.isExpanded {
                        withAnimation(AppTheme.Animations.springFast) {
                            notchState.isExpanded = true
                        }
                    }
                    HapticManager.shared.playFeedback(.light)
                }
            } label: {
                HStack {
                    Image(systemName: "tray.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                    Text("File Tray")
                        .font(.system(size: 13))
                        .foregroundColor(.primary)
                    Spacer()
                    Text("⌘⇧2")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    hoveredButton == "tray" ? Color.gray.opacity(0.15) : Color.clear
                )
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                hoveredButton = hovering ? "tray" : nil
            }
            .padding(.bottom, 4)
        }
    }

    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(spacing: 4) {
            // Settings
            SettingsLink {
                HStack {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                    Text("Settings...")
                        .font(.system(size: 13))
                        .foregroundColor(.primary)
                    Spacer()
                    Text("⌘,")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    hoveredButton == "settings" ? Color.gray.opacity(0.15) : Color.clear
                )
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                hoveredButton = hovering ? "settings" : nil
            }
            .padding(.top, 4)

            // Check for Updates
            Button {
                performAction {
                    checkForUpdates()
                }
            } label: {
                HStack {
                    if isCheckingForUpdates {
                        ProgressView()
                            .scaleEffect(0.7)
                            .frame(width: 14, height: 14)
                    } else {
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                    }
                    Text("Check for Updates")
                        .font(.system(size: 13))
                        .foregroundColor(.primary)
                    Spacer()
                }
                .contentShape(Rectangle())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    hoveredButton == "updates" ? Color.gray.opacity(0.15) : Color.clear
                )
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                hoveredButton = hovering ? "updates" : nil
            }
            .disabled(isCheckingForUpdates)

            // About
            Button {
                performAction {
                    openAbout()
                }
            } label: {
                HStack {
                    Image(systemName: "info.circle")
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                    Text("About NotchApp")
                        .font(.system(size: 13))
                        .foregroundColor(.primary)
                    Spacer()
                }
                .contentShape(Rectangle())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    hoveredButton == "about" ? Color.gray.opacity(0.15) : Color.clear
                )
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                hoveredButton = hovering ? "about" : nil
            }
            .padding(.bottom, 4)
        }
    }

    // MARK: - Quit Section
    private var quitSection: some View {
        Button {
            NSApplication.shared.terminate(nil)
        } label: {
            HStack {
                Image(systemName: "power")
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                Text("Quit NotchApp")
                    .font(.system(size: 13))
                    .foregroundColor(.red)
                Spacer()
                Text("⌘Q")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                hoveredButton == "quit" ? Color.red.opacity(0.1) : Color.clear
            )
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            hoveredButton = hovering ? "quit" : nil
        }
    }

    // MARK: - Helper Methods

    /// Perform action and dismiss menu bar
    private func performAction(_ action: @escaping () -> Void) {
        // Execute action on main thread
        DispatchQueue.main.async {
            action()
        }
        // Dismiss the menu bar after a short delay to ensure action completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            dismiss()
        }
    }

    /// Perform media action without dismissing menu bar
    private func performMediaAction(_ action: @escaping () -> Void) {
        // Execute action on main thread without dismissing
        DispatchQueue.main.async {
            action()
        }
    }

    // MARK: - Actions

    private func checkForUpdates() {
        isCheckingForUpdates = true
        updateManager.checkForUpdates()

        // Reset state after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isCheckingForUpdates = false
        }
    }

    private func openAbout() {
        // Close menu bar first
        dismiss()

        // Open about panel after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NSApp.activate(ignoringOtherApps: true)
            NSApp.orderFrontStandardAboutPanel(nil)
        }
    }
}

// MARK: - Preview
#Preview {
    MenuBarContentView()
        .frame(width: 280)
}
