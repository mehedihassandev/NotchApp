import AppKit
import SwiftUI

// MARK: - Settings Window Opener
/// Opens settings window programmatically (for notifications and system callbacks)
///
/// ## Usage in SwiftUI Views
/// Use `SettingsLink` directly in your views:
/// ```swift
/// SettingsLink {
///     Label("Settings", systemImage: "gearshape.fill")
/// }
/// ```
///
/// ## Keyboard Shortcut
/// **⌘,** - Native macOS shortcut (automatically handled by Settings scene)
///
/// ## Programmatic Access
/// For non-SwiftUI contexts (notifications, system callbacks):
/// ```swift
/// SettingsWindowOpener.open()
/// ```

struct SettingsWindowOpener {

    /// Opens the Settings window
    static func open() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    /// Closes the Settings window
    static func close() {
        NSApp.windows
            .filter { $0.title.contains("Settings") || $0.title.contains("Preferences") }
            .forEach { $0.close() }
    }
}
