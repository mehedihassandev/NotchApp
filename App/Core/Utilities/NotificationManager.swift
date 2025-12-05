import Combine
import Foundation
import UserNotifications

// MARK: - Notification Manager
/// Manages user notifications using the modern UserNotifications framework
/// Provides feedback for file operations, AirDrop, media actions, and system events

final class NotificationManager: NSObject, ObservableObject {

    // MARK: - Singleton
    static let shared = NotificationManager()

    // MARK: - Properties
    private let center = UNUserNotificationCenter.current()
    @Published var isAuthorized = false
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined

    // MARK: - Notification Categories
    enum NotificationCategory: String {
        case fileOperation = "FILE_OPERATION"
        case airDrop = "AIRDROP"
        case media = "MEDIA"
        case tray = "TRAY"
        case system = "SYSTEM"
        case update = "UPDATE"
    }

    // MARK: - Initialization
    private override init() {
        super.init()
        center.delegate = self
        checkAuthorizationStatus()
        logInfo("NotificationManager initialized", category: .general)
    }

    // MARK: - Authorization

    /// Request notification permissions
    func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
                if let error = error {
                    logError("Notification authorization error: \(error.localizedDescription)", category: .general)
                }
                logInfo("Notification authorization: \(granted ? "granted" : "denied")", category: .general)
                completion?(granted)
            }
        }
    }

    /// Check current authorization status
    func checkAuthorizationStatus() {
        center.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.authorizationStatus = settings.authorizationStatus
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    // MARK: - Send Notifications

    /// Check if notifications are enabled for a specific category
    private func isNotificationEnabled(for category: NotificationCategory) -> Bool {
        let key: String
        switch category {
        case .fileOperation:
            key = "notifications.fileOperations"
        case .airDrop:
            key = "notifications.airDrop"
        case .tray:
            key = "notifications.tray"
        case .media:
            key = "notifications.media"
        case .system:
            key = "notifications.system"
        case .update:
            key = "notifications.updates"
        }

        // Default to true if not set
        if UserDefaults.standard.object(forKey: key) == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: key)
    }

    /// Send a notification with title and body
    private func sendNotification(
        title: String,
        body: String,
        category: NotificationCategory,
        sound: UNNotificationSound? = .default,
        identifier: String? = nil
    ) {
        // Check if notifications are enabled for this category
        guard isNotificationEnabled(for: category) else {
            logDebug("Notification skipped (disabled): \(title)", category: .general)
            return
        }

        guard isAuthorized else {
            // Auto-request authorization on first use
            requestAuthorization { [weak self] granted in
                if granted {
                    self?.sendNotification(title: title, body: body, category: category, sound: sound, identifier: identifier)
                }
            }
            return
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound
        content.categoryIdentifier = category.rawValue

        let notificationIdentifier = identifier ?? UUID().uuidString
        let request = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: content,
            trigger: nil // Deliver immediately
        )

        center.add(request) { error in
            if let error = error {
                logError("Failed to send notification: \(error.localizedDescription)", category: .general)
            } else {
                logDebug("Notification sent: \(title)", category: .general)
            }
        }
    }

    // MARK: - File Operations

    /// Notify when file is saved
    func notifyFileSaved(fileName: String) {
        sendNotification(
            title: "File Saved",
            body: "✓ \(fileName) has been saved",
            category: .fileOperation,
            sound: .default
        )
    }

    /// Notify when file is deleted
    func notifyFileDeleted(fileName: String) {
        sendNotification(
            title: "File Deleted",
            body: "🗑️ \(fileName) has been removed",
            category: .fileOperation,
            sound: .default
        )
    }

    /// Notify when file operation fails
    func notifyFileOperationFailed(fileName: String, error: String) {
        sendNotification(
            title: "File Operation Failed",
            body: "❌ \(fileName): \(error)",
            category: .fileOperation,
            sound: .defaultCritical
        )
    }

    // MARK: - AirDrop Notifications

    /// Notify when AirDrop sharing starts
    func notifyAirDropStarted(fileCount: Int) {
        let filesText = fileCount == 1 ? "file" : "files"
        sendNotification(
            title: "Sharing via AirDrop",
            body: "📡 Sharing \(fileCount) \(filesText)...",
            category: .airDrop,
            sound: nil,
            identifier: "airdrop-sharing"
        )
    }

    /// Notify when AirDrop sharing completes
    func notifyAirDropCompleted(fileCount: Int) {
        let filesText = fileCount == 1 ? "file" : "files"
        sendNotification(
            title: "AirDrop Complete",
            body: "✓ Successfully shared \(fileCount) \(filesText)",
            category: .airDrop,
            sound: .default,
            identifier: "airdrop-complete"
        )
    }

    /// Notify when AirDrop fails
    func notifyAirDropFailed() {
        sendNotification(
            title: "AirDrop Failed",
            body: "❌ Unable to share files via AirDrop",
            category: .airDrop,
            sound: .defaultCritical
        )
    }

    // MARK: - Tray Operations

    /// Notify when tray is cleared
    func notifyTrayCleared(itemCount: Int) {
        sendNotification(
            title: "Tray Cleared",
            body: "🗑️ Removed \(itemCount) \(itemCount == 1 ? "item" : "items") from tray",
            category: .tray,
            sound: .default
        )
    }

    /// Notify when item is added to tray
    func notifyItemAddedToTray(fileName: String) {
        sendNotification(
            title: "Added to Tray",
            body: "📎 \(fileName)",
            category: .tray,
            sound: nil
        )
    }

    /// Notify when item is removed from tray
    func notifyItemRemovedFromTray(fileName: String) {
        sendNotification(
            title: "Removed from Tray",
            body: "🗑️ \(fileName)",
            category: .tray,
            sound: nil
        )
    }

    // MARK: - Media Notifications

    /// Notify when media playback starts
    func notifyMediaPlaying(trackName: String, artist: String) {
        sendNotification(
            title: "▶️ Now Playing",
            body: "\(trackName) - \(artist)",
            category: .media,
            sound: nil
        )
    }

    /// Notify when media is paused
    func notifyMediaPaused() {
        sendNotification(
            title: "⏸️ Paused",
            body: "Media playback paused",
            category: .media,
            sound: nil
        )
    }

    /// Notify when switching tracks
    func notifyTrackChanged(trackName: String, artist: String, direction: TrackChangeDirection) {
        let emoji = direction == .next ? "⏭️" : "⏮️"
        sendNotification(
            title: "\(emoji) Track Changed",
            body: "\(trackName) - \(artist)",
            category: .media,
            sound: nil
        )
    }

    enum TrackChangeDirection {
        case next
        case previous
    }

    // MARK: - System Notifications

    /// Notify when launch at login is toggled
    func notifyLaunchAtLoginChanged(enabled: Bool) {
        sendNotification(
            title: "Launch at Login",
            body: enabled
                ? "✓ NotchApp will start automatically when you log in"
                : "NotchApp will not start automatically",
            category: .system,
            sound: nil
        )
    }

    /// Notify when keyboard shortcut is triggered
    func notifyShortcutTriggered(shortcutName: String) {
        sendNotification(
            title: "Shortcut Triggered",
            body: "⌨️ \(shortcutName)",
            category: .system,
            sound: nil
        )
    }

    /// Notify when accessibility permission is needed
    func notifyAccessibilityPermissionNeeded() {
        sendNotification(
            title: "Permission Required",
            body: "⚠️ Enable Accessibility access for keyboard shortcuts",
            category: .system,
            sound: .defaultCritical
        )
    }

    // MARK: - Update Notifications

    /// Notify when update check starts
    func notifyUpdateCheckStarted() {
        sendNotification(
            title: "Checking for Updates",
            body: "🔍 Looking for new versions...",
            category: .update,
            sound: nil,
            identifier: "update-check"
        )
    }

    /// Notify when update is available
    func notifyUpdateAvailable(version: String) {
        sendNotification(
            title: "Update Available",
            body: "🎉 Version \(version) is ready to install",
            category: .update,
            sound: .default
        )
    }

    /// Notify when app is up to date
    func notifyAppUpToDate() {
        sendNotification(
            title: "You're Up to Date",
            body: "✓ NotchApp is running the latest version",
            category: .update,
            sound: nil
        )
    }

    /// Notify when update download starts
    func notifyUpdateDownloading(version: String) {
        sendNotification(
            title: "Downloading Update",
            body: "⬇️ Downloading version \(version)...",
            category: .update,
            sound: nil,
            identifier: "update-download"
        )
    }

    /// Notify when update is ready to install
    func notifyUpdateReadyToInstall(version: String) {
        sendNotification(
            title: "Update Ready",
            body: "✓ Version \(version) is ready. Restart to install",
            category: .update,
            sound: .default
        )
    }

    // MARK: - Clear Notifications

    /// Remove all delivered notifications
    func clearAllNotifications() {
        center.removeAllDeliveredNotifications()
        logDebug("All notifications cleared", category: .general)
    }

    /// Remove specific notification by identifier
    func clearNotification(identifier: String) {
        center.removeDeliveredNotifications(withIdentifiers: [identifier])
        logDebug("Notification cleared: \(identifier)", category: .general)
    }

    /// Remove notifications by category
    func clearNotifications(category: NotificationCategory) {
        center.getDeliveredNotifications { notifications in
            let identifiers = notifications
                .filter { $0.request.content.categoryIdentifier == category.rawValue }
                .map { $0.request.identifier }

            self.center.removeDeliveredNotifications(withIdentifiers: identifiers)
            logDebug("Notifications cleared for category: \(category.rawValue)", category: .general)
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {

    /// Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound])
    }

    /// Handle notification response (when user clicks on notification)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let categoryIdentifier = response.notification.request.content.categoryIdentifier
        logDebug("Notification clicked: \(categoryIdentifier)", category: .general)

        // Handle different notification actions based on category
        switch categoryIdentifier {
        case NotificationCategory.update.rawValue:
            // Open settings to updates section
            NotificationCenter.default.post(name: .openSettings, object: nil)

        case NotificationCategory.system.rawValue:
            // Open settings
            NotificationCenter.default.post(name: .openSettings, object: nil)

        default:
            break
        }

        completionHandler()
    }
}

// MARK: - Notification Names Extension
extension Notification.Name {
    static let openSettings = Notification.Name("openSettings")
}
