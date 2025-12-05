import SwiftUI
import LaunchAtLogin
import Sparkle

// MARK: - Advanced Settings View
/// Settings view for Launch at Login and Auto-Updates

struct AdvancedSettingsView: View {

    // MARK: - State Properties
    @ObservedObject private var launchManager = LaunchAtLoginManager.shared
    @ObservedObject private var updateManager = UpdateManager.shared
    @ObservedObject private var notificationManager = NotificationManager.shared
    @State private var isCheckingForUpdates = false
    @State private var enableFileNotifications = true
    @State private var enableAirDropNotifications = true
    @State private var enableTrayNotifications = true
    @State private var enableMediaNotifications = false
    @State private var enableSystemNotifications = true
    @State private var enableUpdateNotifications = true

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                headerSection

                Divider()

                // Notifications Section
                notificationsSection

                Divider()

                // Launch at Login Section
                launchAtLoginSection

                Divider()

                // Auto-Update Section
                autoUpdateSection

                Divider()

                // Update Check Section
                updateCheckSection
            }
            .padding(24)
        }
        .frame(width: 550, height: 650)
        .onAppear {
            loadNotificationPreferences()
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Advanced Settings", systemImage: "gearshape.2")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)

            Text("Configure app startup behavior, notifications, and automatic updates.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Notifications Section
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "Notifications",
                icon: "bell.badge",
                description: "Control which notifications you receive"
            )

            VStack(spacing: 12) {
                // Notification Authorization Status
                if !notificationManager.isAuthorized {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 16))

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notifications Disabled")
                                .font(.system(size: 14, weight: .medium))

                            Text("Enable notifications in System Settings to receive alerts")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Button("Open Settings") {
                            openSystemNotificationSettings()
                        }
                        .buttonStyle(.bordered)
                        .font(.system(size: 12))
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.orange.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                    )
                }

                // File Operations
                notificationToggle(
                    title: "File Operations",
                    description: "Notify when files are saved or deleted",
                    icon: "doc",
                    isOn: $enableFileNotifications
                )

                // AirDrop
                notificationToggle(
                    title: "AirDrop",
                    description: "Notify when sharing files via AirDrop",
                    icon: "wifi.circle",
                    isOn: $enableAirDropNotifications
                )

                // Tray Operations
                notificationToggle(
                    title: "Tray Operations",
                    description: "Notify when items are added or removed from tray",
                    icon: "tray",
                    isOn: $enableTrayNotifications
                )

                // Media Controls
                notificationToggle(
                    title: "Media Controls",
                    description: "Notify when controlling media playback",
                    icon: "play.circle",
                    isOn: $enableMediaNotifications
                )

                // System Events
                notificationToggle(
                    title: "System Events",
                    description: "Notify about app settings and system changes",
                    icon: "gear",
                    isOn: $enableSystemNotifications
                )

                // Updates
                notificationToggle(
                    title: "Updates",
                    description: "Notify when app updates are available",
                    icon: "arrow.down.circle",
                    isOn: $enableUpdateNotifications
                )
            }
        }
    }

    private func notificationToggle(title: String, description: String, icon: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.system(size: 16))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))

                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .onChange(of: isOn.wrappedValue) { _, newValue in
                    saveNotificationPreferences()
                }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .opacity(notificationManager.isAuthorized ? 1.0 : 0.5)
        .disabled(!notificationManager.isAuthorized)
    }

    // MARK: - Launch at Login Section
    private var launchAtLoginSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "Startup",
                icon: "power.circle",
                description: "Control when NotchApp starts"
            )

            // Launch at Login Toggle
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Launch at Login")
                        .font(.system(size: 14, weight: .medium))

                    Text("Automatically start NotchApp when you log in to your Mac")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Toggle("", isOn: $launchManager.isEnabled)
                    .labelsHidden()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )

            // Status Info
            if launchManager.isEnabled {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 12))

                    Text("NotchApp will start automatically when you log in")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 4)
            }
        }
    }

    // MARK: - Auto-Update Section
    private var autoUpdateSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "Automatic Updates",
                icon: "arrow.triangle.2.circlepath.circle",
                description: "Keep NotchApp up to date automatically"
            )

            VStack(spacing: 12) {
                // Auto Check for Updates
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Check for Updates Automatically")
                            .font(.system(size: 14, weight: .medium))

                        Text("Periodically check for new versions in the background")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Toggle("", isOn: $updateManager.automaticallyChecksForUpdates)
                        .labelsHidden()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(nsColor: .controlBackgroundColor))
                )

                // Auto Download Updates
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Download Updates Automatically")
                            .font(.system(size: 14, weight: .medium))

                        Text("Download new versions in the background (requires manual install)")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Toggle("", isOn: $updateManager.automaticallyDownloadsUpdates)
                        .labelsHidden()
                        .disabled(!updateManager.automaticallyChecksForUpdates)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(nsColor: .controlBackgroundColor))
                )
                .opacity(updateManager.automaticallyChecksForUpdates ? 1.0 : 0.5)
            }

            // Update Interval Picker
            if updateManager.automaticallyChecksForUpdates {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Check Interval")
                            .font(.system(size: 14, weight: .medium))

                        Text("How often to check for updates")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Picker("", selection: Binding(
                        get: { updateManager.currentCheckInterval },
                        set: { updateManager.setCheckInterval($0) }
                    )) {
                        ForEach(UpdateManager.CheckInterval.allCases) { interval in
                            Text(interval.displayName).tag(interval)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 120)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(nsColor: .controlBackgroundColor))
                )
            }
        }
    }

    // MARK: - Update Check Section
    private var updateCheckSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "Update Status",
                icon: "info.circle",
                description: "Check for updates and view version info"
            )

            VStack(spacing: 12) {
                // Last Check Info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Last Checked")
                            .font(.system(size: 14, weight: .medium))

                        Text(updateManager.lastUpdateCheckDateString)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    // Check for Updates Button
                    Button(action: {
                        checkForUpdates()
                    }) {
                        HStack(spacing: 6) {
                            if isCheckingForUpdates {
                                ProgressView()
                                    .scaleEffect(0.7)
                                    .frame(width: 14, height: 14)
                            } else {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 12))
                            }

                            Text("Check Now")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.bordered)
                    .disabled(isCheckingForUpdates || !updateManager.canCheckForUpdates)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(nsColor: .controlBackgroundColor))
                )

                // Version Info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Version")
                            .font(.system(size: 14, weight: .medium))

                        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                            Text("Version \(version) (Build \(build))")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        } else {
                            Text("Version information unavailable")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 20))
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(nsColor: .controlBackgroundColor))
                )
            }
        }
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

    // MARK: - Actions

    private func checkForUpdates() {
        isCheckingForUpdates = true
        updateManager.checkForUpdates()

        // Reset checking state after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isCheckingForUpdates = false
        }
    }

    private func openSystemNotificationSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
            NSWorkspace.shared.open(url)
        }
    }

    private func loadNotificationPreferences() {
        enableFileNotifications = UserDefaults.standard.bool(forKey: "notifications.fileOperations", defaultValue: true)
        enableAirDropNotifications = UserDefaults.standard.bool(forKey: "notifications.airDrop", defaultValue: true)
        enableTrayNotifications = UserDefaults.standard.bool(forKey: "notifications.tray", defaultValue: true)
        enableMediaNotifications = UserDefaults.standard.bool(forKey: "notifications.media", defaultValue: false)
        enableSystemNotifications = UserDefaults.standard.bool(forKey: "notifications.system", defaultValue: true)
        enableUpdateNotifications = UserDefaults.standard.bool(forKey: "notifications.updates", defaultValue: true)
    }

    private func saveNotificationPreferences() {
        UserDefaults.standard.set(enableFileNotifications, forKey: "notifications.fileOperations")
        UserDefaults.standard.set(enableAirDropNotifications, forKey: "notifications.airDrop")
        UserDefaults.standard.set(enableTrayNotifications, forKey: "notifications.tray")
        UserDefaults.standard.set(enableMediaNotifications, forKey: "notifications.media")
        UserDefaults.standard.set(enableSystemNotifications, forKey: "notifications.system")
        UserDefaults.standard.set(enableUpdateNotifications, forKey: "notifications.updates")
    }
}

// MARK: - UserDefaults Extension
extension UserDefaults {
    func bool(forKey key: String, defaultValue: Bool) -> Bool {
        if object(forKey: key) == nil {
            return defaultValue
        }
        return bool(forKey: key)
    }
}

// MARK: - Preview
#Preview {
    AdvancedSettingsView()
}
