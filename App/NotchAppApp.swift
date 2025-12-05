import SwiftUI
import CoreData
import AppKit

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
        Settings {
            EmptyView()
        }
    }
}

// MARK: - App Delegate
/// Handles app lifecycle events and window management

final class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Properties
    private var notchWindowController: NotchWindowController?

    // MARK: - Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        configureAppBehavior()
        setupNotchWindow()

        logInfo("NotchApp launched successfully", category: .general)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
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
}

// MARK: - Notification Names
extension Notification.Name {
    /// Posted when a new notch instance should be created
    static let createNewNotch = Notification.Name("createNewNotch")
}
