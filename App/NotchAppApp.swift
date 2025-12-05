import SwiftUI
import CoreData
import AppKit
import KeyboardShortcuts
import LaunchAtLogin
import Sparkle

// MARK: - Main App Entry Point
/// NotchApp - A macOS menu bar companion app for the MacBook notch
/// Provides media controls, quick actions, and file tray functionality

@main
struct NotchAppApp: App {

    // MARK: - Properties
    let persistenceController = PersistenceController.shared
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // MARK: - Body
    var body: some Scene {
        // MenuBarExtra - Main menu bar interface
        MenuBarExtra {
            MenuBarContentView()
        } label: {
            MenuBarIconView()
        }
        .menuBarExtraStyle(.window)

        // Settings scene (accessed via Cmd+, or menu bar)
        Settings {
            SettingsView()
                .preferredColorScheme(.dark)
                .frame(width: 540, height: 620)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

// MARK: - App Delegate
/// Handles app lifecycle events and window management

final class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Properties
    private var notchWindowController: NotchWindowController?
    private var observers: [NSObjectProtocol] = []

    // MARK: - Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        configureAppBehavior()
        setupNotchWindow()
        setupKeyboardShortcuts()
        setupLaunchAtLogin()
        setupUpdateManager()
        setupNotificationManager()
        setupMenuBar()
        setupNotificationObservers()

        logInfo("NotchApp launched successfully", category: .general)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Clean up observers
        observers.forEach { NotificationCenter.default.removeObserver($0) }
    }

    // MARK: - Setup

    private func configureAppBehavior() {
        // Hide the app from dock - runs as accessory app
        NSApp.setActivationPolicy(.accessory)
    }

    private func setupNotchWindow() {
        notchWindowController = NotchWindowController()
        notchWindowController?.showWindow(nil)

        // Keep the window always on top
        notchWindowController?.window?.level = .statusBar
    }

    private func setupKeyboardShortcuts() {
        // Initialize keyboard shortcuts manager
        _ = KeyboardShortcutsManager.shared
        logInfo("Keyboard shortcuts initialized", category: .general)
    }

    private func setupLaunchAtLogin() {
        // Initialize launch at login manager
        _ = LaunchAtLoginManager.shared
        logInfo("Launch at login manager initialized", category: .general)
    }

    private func setupUpdateManager() {
        // Initialize update manager
        _ = UpdateManager.shared
        logInfo("Update manager initialized", category: .general)
    }

    private func setupNotificationManager() {
        // Initialize notification manager and request permissions
        let notificationManager = NotificationManager.shared
        notificationManager.requestAuthorization { granted in
            if granted {
                logInfo("Notification permissions granted", category: .general)
            } else {
                logWarning("Notification permissions denied", category: .general)
            }
        }
    }

    private func setupMenuBar() {
        // Initialize menu bar manager
        _ = MenuBarManager.shared
        logInfo("Menu bar manager initialized", category: .general)
    }

    private func setupNotificationObservers() {
        // Observe settings open request
        let settingsObserver = NotificationCenter.default.addObserver(
            forName: .openSettings,
            object: nil,
            queue: .main
        ) { _ in
            SettingsWindowOpener.open()
        }
        observers.append(settingsObserver)

        logInfo("Notification observers initialized", category: .general)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    /// Posted when a new notch instance should be created
    static let createNewNotch = Notification.Name("createNewNotch")
}
