import SwiftUI
import AppKit

// MARK: - Settings Window Controller
/// A dedicated window controller for the settings panel

final class SettingsWindowController: NSWindowController {

    // MARK: - Singleton
    static let shared = SettingsWindowController()

    // MARK: - Initialization
    convenience init() {
        let settingsView = SettingsView()
            .preferredColorScheme(.dark)
        let hostingController = NSHostingController(rootView: settingsView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 540, height: 620),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        window.title = "Settings"
        window.contentViewController = hostingController
        window.center()
        window.isReleasedWhenClosed = false
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .visible
        window.backgroundColor = NSColor.windowBackgroundColor
        window.isMovableByWindowBackground = true
        window.toolbar = nil

        // Hide minimize and zoom buttons
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true

        self.init(window: window)
    }

    // MARK: - Methods
    func show() {
        window?.center()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func hide() {
        window?.close()
    }

    func toggle() {
        if window?.isVisible == true {
            hide()
        } else {
            show()
        }
    }
}

// MARK: - Settings Window Opener
/// Helper to open settings window from anywhere

struct SettingsWindowOpener {
    static func open() {
        SettingsWindowController.shared.show()
    }

    static func close() {
        SettingsWindowController.shared.hide()
    }
}
