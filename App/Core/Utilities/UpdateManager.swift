import Combine
import Foundation
import Sparkle

// MARK: - Update Manager
/// Manages automatic updates using Sparkle framework
/// Provides check for updates, automatic updates, and update notifications

final class UpdateManager: ObservableObject {

    // MARK: - Singleton
    static let shared = UpdateManager()

    // MARK: - Properties
    private let updaterController: SPUStandardUpdaterController

    @Published var canCheckForUpdates: Bool = false
    @Published var automaticallyChecksForUpdates: Bool = true {
        didSet {
            updaterController.updater.automaticallyChecksForUpdates = automaticallyChecksForUpdates
            UserDefaults.standard.set(automaticallyChecksForUpdates, forKey: "automaticallyChecksForUpdates")
        }
    }

    @Published var automaticallyDownloadsUpdates: Bool = true {
        didSet {
            updaterController.updater.automaticallyDownloadsUpdates = automaticallyDownloadsUpdates
            UserDefaults.standard.set(automaticallyDownloadsUpdates, forKey: "automaticallyDownloadsUpdates")
        }
    }

    // MARK: - Initialization
    private init() {
        // Initialize Sparkle updater
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )

        // Load saved preferences
        if let savedAutoCheck = UserDefaults.standard.object(forKey: "automaticallyChecksForUpdates") as? Bool {
            automaticallyChecksForUpdates = savedAutoCheck
        }

        if let savedAutoDownload = UserDefaults.standard.object(forKey: "automaticallyDownloadsUpdates") as? Bool {
            automaticallyDownloadsUpdates = savedAutoDownload
        }

        // Apply preferences
        updaterController.updater.automaticallyChecksForUpdates = automaticallyChecksForUpdates
        updaterController.updater.automaticallyDownloadsUpdates = automaticallyDownloadsUpdates

        // Update can check status
        canCheckForUpdates = updaterController.updater.canCheckForUpdates

        logInfo("UpdateManager initialized (auto-check: \(automaticallyChecksForUpdates), auto-download: \(automaticallyDownloadsUpdates))", category: .general)
    }

    // MARK: - Public Methods

    /// Manually check for updates
    func checkForUpdates() {
        guard canCheckForUpdates else {
            logWarning("Cannot check for updates at this time", category: .general)
            return
        }

        logInfo("Checking for updates manually", category: .general)
        updaterController.checkForUpdates(nil)
    }

    /// Get the updater for menu item binding
    var updater: SPUUpdater {
        updaterController.updater
    }

    /// Get last update check date
    var lastUpdateCheckDate: Date? {
        updaterController.updater.lastUpdateCheckDate
    }

    /// Get formatted last check date
    var lastUpdateCheckDateString: String {
        guard let date = lastUpdateCheckDate else {
            return "Never"
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    /// Enable automatic update checks
    func enableAutomaticChecks() {
        automaticallyChecksForUpdates = true
        logInfo("Automatic update checks enabled", category: .general)
    }

    /// Disable automatic update checks
    func disableAutomaticChecks() {
        automaticallyChecksForUpdates = false
        logInfo("Automatic update checks disabled", category: .general)
    }

    /// Enable automatic update downloads
    func enableAutomaticDownloads() {
        automaticallyDownloadsUpdates = true
        logInfo("Automatic update downloads enabled", category: .general)
    }

    /// Disable automatic update downloads
    func disableAutomaticDownloads() {
        automaticallyDownloadsUpdates = false
        logInfo("Automatic update downloads disabled", category: .general)
    }
}

// MARK: - Update Check Interval Extension
extension UpdateManager {

    /// Update check intervals
    enum CheckInterval: TimeInterval, CaseIterable, Identifiable {
        case hourly = 3600          // 1 hour
        case daily = 86400          // 24 hours
        case weekly = 604800        // 7 days

        var id: TimeInterval { rawValue }

        var displayName: String {
            switch self {
            case .hourly: return "Every Hour"
            case .daily: return "Daily"
            case .weekly: return "Weekly"
            }
        }
    }

    /// Set update check interval
    func setCheckInterval(_ interval: CheckInterval) {
        updaterController.updater.updateCheckInterval = interval.rawValue
        UserDefaults.standard.set(interval.rawValue, forKey: "updateCheckInterval")
        logInfo("Update check interval set to: \(interval.displayName)", category: .general)
    }

    /// Get current check interval
    var currentCheckInterval: CheckInterval {
        let interval = updaterController.updater.updateCheckInterval
        return CheckInterval(rawValue: interval) ?? .daily
    }
}
