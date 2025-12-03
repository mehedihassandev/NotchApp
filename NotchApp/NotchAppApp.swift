import SwiftUI
import CoreData
import AppKit

@main
struct NotchAppApp: App {
    let persistenceController = PersistenceController.shared
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var notchWindowController: NotchWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide the app from dock
        NSApp.setActivationPolicy(.accessory)

        // Create and show the notch window
        notchWindowController = NotchWindowController()
        notchWindowController?.showWindow(nil)

        // Keep the window always on top
        notchWindowController?.window?.level = .statusBar
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}

extension Notification.Name {
    static let createNewNotch = Notification.Name("createNewNotch")
}
