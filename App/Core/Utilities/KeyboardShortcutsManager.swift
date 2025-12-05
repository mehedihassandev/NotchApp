import Foundation
import Combine
import AppKit
import KeyboardShortcuts

// MARK: - Keyboard Shortcuts Manager
/// Centralized management of global keyboard shortcuts for NotchApp
/// Provides easy-to-use shortcuts for common actions

extension KeyboardShortcuts.Name {

    // MARK: - Notch Control Shortcuts

    /// Toggle notch expansion/collapse (Default: ⌘⇧N)
    static let toggleNotch = Self("toggleNotch", default: .init(.n, modifiers: [.command, .shift]))

    /// Expand notch (Default: ⌘⇧E)
    static let expandNotch = Self("expandNotch", default: .init(.e, modifiers: [.command, .shift]))

    /// Collapse notch (Default: ⌘⇧C)
    static let collapseNotch = Self("collapseNotch", default: .init(.c, modifiers: [.command, .shift]))

    // MARK: - Tab Navigation Shortcuts

    /// Switch to Nook tab (Default: ⌘⇧1)
    static let switchToNook = Self("switchToNook", default: .init(.one, modifiers: [.command, .shift]))

    /// Switch to Tray tab (Default: ⌘⇧2)
    static let switchToTray = Self("switchToTray", default: .init(.two, modifiers: [.command, .shift]))

    // MARK: - Media Control Shortcuts

    /// Toggle play/pause (Default: ⌘⇧P)
    static let togglePlayPause = Self("togglePlayPause", default: .init(.p, modifiers: [.command, .shift]))

    /// Next track (Default: ⌘⇧→)
    static let nextTrack = Self("nextTrack", default: .init(.rightArrow, modifiers: [.command, .shift]))

    /// Previous track (Default: ⌘⇧←)
    static let previousTrack = Self("previousTrack", default: .init(.leftArrow, modifiers: [.command, .shift]))

    // MARK: - App Control Shortcuts

    /// Clear tray (Default: ⌘⇧K)
    static let clearTray = Self("clearTray", default: .init(.k, modifiers: [.command, .shift]))
}

// MARK: - Keyboard Shortcuts Manager
/// Singleton manager to register and handle all keyboard shortcuts

final class KeyboardShortcutsManager: ObservableObject {

    // MARK: - Singleton
    static let shared = KeyboardShortcutsManager()

    // MARK: - Published Properties
    @Published var isEnabled: Bool {
        willSet {
            objectWillChange.send()
        }
    }

    // MARK: - Private Properties
    private var registeredShortcuts: [KeyboardShortcuts.Name] = []

    // MARK: - Initialization
    private init() {
        // Load enabled state from UserDefaults
        self.isEnabled = UserDefaults.standard.object(forKey: "keyboardShortcutsEnabled") as? Bool ?? true

        if isEnabled {
            registerAllShortcuts()
        }

        logInfo("KeyboardShortcutsManager initialized (enabled: \(isEnabled))", category: .general)

        // Observe changes to isEnabled
        setupObservers()
    }

    private func setupObservers() {
        // React to isEnabled changes
        $isEnabled.sink { [weak self] enabled in
            guard let self = self else { return }
            UserDefaults.standard.set(enabled, forKey: "keyboardShortcutsEnabled")
            if enabled {
                self.registerAllShortcuts()
            } else {
                self.unregisterAllShortcuts()
            }
        }
        .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Public Methods

    /// Register all keyboard shortcuts
    func registerAllShortcuts() {
        registerNotchControlShortcuts()
        registerTabNavigationShortcuts()
        registerMediaControlShortcuts()
        registerAppControlShortcuts()

        logInfo("Registered \(registeredShortcuts.count) keyboard shortcuts", category: .general)
    }

    /// Unregister all keyboard shortcuts
    func unregisterAllShortcuts() {
        // KeyboardShortcuts library handles this automatically when removing observers
        registeredShortcuts.removeAll()
        logInfo("Unregistered all keyboard shortcuts", category: .general)
    }

    // MARK: - Private Methods - Registration

    private func registerNotchControlShortcuts() {
        // Toggle notch
        KeyboardShortcuts.onKeyUp(for: .toggleNotch) { [weak self] in
            self?.handleToggleNotch()
        }
        registeredShortcuts.append(.toggleNotch)

        // Expand notch
        KeyboardShortcuts.onKeyUp(for: .expandNotch) { [weak self] in
            self?.handleExpandNotch()
        }
        registeredShortcuts.append(.expandNotch)

        // Collapse notch
        KeyboardShortcuts.onKeyUp(for: .collapseNotch) { [weak self] in
            self?.handleCollapseNotch()
        }
        registeredShortcuts.append(.collapseNotch)
    }

    private func registerTabNavigationShortcuts() {
        // Switch to Nook
        KeyboardShortcuts.onKeyUp(for: .switchToNook) { [weak self] in
            self?.handleSwitchToNook()
        }
        registeredShortcuts.append(.switchToNook)

        // Switch to Tray
        KeyboardShortcuts.onKeyUp(for: .switchToTray) { [weak self] in
            self?.handleSwitchToTray()
        }
        registeredShortcuts.append(.switchToTray)
    }

    private func registerMediaControlShortcuts() {
        // Toggle play/pause
        KeyboardShortcuts.onKeyUp(for: .togglePlayPause) { [weak self] in
            self?.handleTogglePlayPause()
        }
        registeredShortcuts.append(.togglePlayPause)

        // Next track
        KeyboardShortcuts.onKeyUp(for: .nextTrack) { [weak self] in
            self?.handleNextTrack()
        }
        registeredShortcuts.append(.nextTrack)

        // Previous track
        KeyboardShortcuts.onKeyUp(for: .previousTrack) { [weak self] in
            self?.handlePreviousTrack()
        }
        registeredShortcuts.append(.previousTrack)
    }

    private func registerAppControlShortcuts() {
        // Clear tray
        KeyboardShortcuts.onKeyUp(for: .clearTray) { [weak self] in
            self?.handleClearTray()
        }
        registeredShortcuts.append(.clearTray)
    }

    // MARK: - Private Methods - Handlers

    private func handleToggleNotch() {
        logDebug("Keyboard shortcut: Toggle notch", category: .general)
        HapticManager.shared.selection()

        DispatchQueue.main.async {
            NotchState.shared.toggle()
        }
    }

    private func handleExpandNotch() {
        logDebug("Keyboard shortcut: Expand notch", category: .general)
        HapticManager.shared.selection()

        DispatchQueue.main.async {
            NotchState.shared.expand()
        }
    }

    private func handleCollapseNotch() {
        logDebug("Keyboard shortcut: Collapse notch", category: .general)
        HapticManager.shared.selection()

        DispatchQueue.main.async {
            NotchState.shared.collapse()
        }
    }

    private func handleSwitchToNook() {
        logDebug("Keyboard shortcut: Switch to Nook", category: .general)
        HapticManager.shared.selection()

        DispatchQueue.main.async {
            NotchState.shared.selectedTab = .nook
            NotchState.shared.expand()
        }
    }

    private func handleSwitchToTray() {
        logDebug("Keyboard shortcut: Switch to Tray", category: .general)
        HapticManager.shared.selection()

        DispatchQueue.main.async {
            NotchState.shared.selectedTab = .tray
            NotchState.shared.expand()
        }
    }

    private func handleTogglePlayPause() {
        logDebug("Keyboard shortcut: Toggle play/pause", category: .general)
        HapticManager.shared.selection()

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .mediaTogglePlayPause, object: nil)
        }
    }

    private func handleNextTrack() {
        logDebug("Keyboard shortcut: Next track", category: .general)
        HapticManager.shared.selection()

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .mediaNextTrack, object: nil)
        }
    }

    private func handlePreviousTrack() {
        logDebug("Keyboard shortcut: Previous track", category: .general)
        HapticManager.shared.selection()

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .mediaPreviousTrack, object: nil)
        }
    }

    private func handleClearTray() {
        logDebug("Keyboard shortcut: Clear tray", category: .general)
        HapticManager.shared.warning()

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .clearTray, object: nil)
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let mediaTogglePlayPause = Notification.Name("mediaTogglePlayPause")
    static let mediaNextTrack = Notification.Name("mediaNextTrack")
    static let mediaPreviousTrack = Notification.Name("mediaPreviousTrack")
    static let clearTray = Notification.Name("clearTray")
}
