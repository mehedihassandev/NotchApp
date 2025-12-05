import Combine
import LaunchAtLogin
import SwiftUI

// MARK: - Launch At Login Manager
/// Manages the app's launch at login behavior
/// Provides easy toggle and status checking

final class LaunchAtLoginManager: ObservableObject {

    // MARK: - Singleton
    static let shared = LaunchAtLoginManager()

    // MARK: - Published Properties
    @Published var isEnabled: Bool {
        didSet {
            updateLaunchAtLogin()
        }
    }

    // MARK: - Initialization
    private init() {
        // Load current state from LaunchAtLogin
        isEnabled = LaunchAtLogin.isEnabled

        logInfo("LaunchAtLoginManager initialized (enabled: \(isEnabled))", category: .general)
    }

    // MARK: - Public Methods

    /// Toggle launch at login on/off
    func toggle() {
        isEnabled.toggle()
    }

    /// Enable launch at login
    func enable() {
        isEnabled = true
    }

    /// Disable launch at login
    func disable() {
        isEnabled = false
    }

    /// Check if launch at login is enabled
    var status: Bool {
        LaunchAtLogin.isEnabled
    }

    // MARK: - Private Methods

    private func updateLaunchAtLogin() {
        LaunchAtLogin.isEnabled = isEnabled

        let status = isEnabled ? "enabled" : "disabled"
        logInfo("Launch at login \(status)", category: .general)

        // Show notification to user
        showNotification(isEnabled: isEnabled)
    }

    private func showNotification(isEnabled: Bool) {
        NotificationManager.shared.notifyLaunchAtLoginChanged(enabled: isEnabled)
    }
}

// MARK: - SwiftUI Integration
/// Observable wrapper for LaunchAtLogin to use in SwiftUI views
@propertyWrapper
struct LaunchAtLoginToggle: DynamicProperty {
    @ObservedObject private var manager = LaunchAtLoginManager.shared

    var wrappedValue: Bool {
        get { manager.isEnabled }
        nonmutating set { manager.isEnabled = newValue }
    }

    var projectedValue: Binding<Bool> {
        Binding(
            get: { manager.isEnabled },
            set: { manager.isEnabled = $0 }
        )
    }
}
