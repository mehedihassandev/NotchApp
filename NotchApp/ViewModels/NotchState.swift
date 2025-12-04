import SwiftUI
import Combine

// MARK: - Notch State
/// Observable state manager for the notch expansion state
/// Used to coordinate between the window and views

final class NotchState: ObservableObject {

    // MARK: - Singleton
    static let shared = NotchState()

    // MARK: - Published Properties
    @Published var isExpanded: Bool = false
    @Published var isHovering: Bool = false
    @Published var isDraggingFile: Bool = false
    @Published var shouldShowTray: Bool = false

    // MARK: - Initialization
    private init() {}

    // MARK: - Methods

    /// Expands the notch with animation
    func expand() {
        isExpanded = true
    }

    /// Collapses the notch with animation
    func collapse() {
        isExpanded = false
    }

    /// Toggles the notch state
    func toggle() {
        isExpanded.toggle()
    }

    /// Called when a file drag enters the notch area
    func fileDragEntered() {
        isDraggingFile = true
        shouldShowTray = true
    }

    /// Called when a file drag exits the notch area
    func fileDragExited() {
        isDraggingFile = false
    }

    /// Reset tray trigger after tab switch
    func resetTrayTrigger() {
        shouldShowTray = false
    }
}

// MARK: - Notch Tab
/// Available tabs in the expanded notch view

enum NotchTab: String, CaseIterable, TabItem {
    case nook = "Nook"
    case tray = "Tray"

    var id: String { rawValue }
    var title: String { rawValue }

    var icon: String {
        switch self {
        case .nook: return "arrow.up.forward"
        case .tray: return "archivebox"
        }
    }
}
