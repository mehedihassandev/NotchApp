import Combine
import SwiftUI

// MARK: - Menu Bar Manager
/// Manages the menu bar icon and status display
/// Provides dynamic icon updates based on app state

final class MenuBarManager: ObservableObject {

    // MARK: - Singleton
    static let shared = MenuBarManager()

    // MARK: - Published Properties
    @Published var iconName: String = "macbook"
    @Published var badgeCount: Int = 0
    @Published var statusText: String = ""
    @Published var isPlaying: Bool = false

    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let notchState = NotchState.shared
    private let mediaManager = MediaPlayerManager()
    private let trayStorage = TrayStorageManager.shared

    // MARK: - Initialization
    private init() {
        setupObservers()
        updateStatus()
        logInfo("MenuBarManager initialized", category: .general)
    }

    // MARK: - Setup

    private func setupObservers() {
        // Observe media state
        mediaManager.$currentMedia
            .sink { [weak self] media in
                self?.isPlaying = !media.title.isEmpty && media.title != "Not Playing"
                self?.updateStatus()
            }
            .store(in: &cancellables)

        // Observe tray items
        trayStorage.$items
            .sink { [weak self] items in
                self?.badgeCount = items.count
                self?.updateStatus()
            }
            .store(in: &cancellables)

        // Observe notch state
        notchState.$isExpanded
            .sink { [weak self] _ in
                self?.updateStatus()
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods

    /// Update menu bar status based on app state
    func updateStatus() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Update icon based on state
            if self.isPlaying {
                self.iconName = "music.note"
                self.statusText = "Playing: \(self.mediaManager.currentMedia.title)"
            } else if !self.trayStorage.items.isEmpty {
                self.iconName = "tray.fill"
                self.statusText = "\(self.trayStorage.items.count) items in tray"
            } else if self.notchState.isExpanded {
                self.iconName = "macbook"
                self.statusText = "Notch expanded"
            } else {
                self.iconName = "macbook"
                self.statusText = "Ready"
            }

            logDebug("Menu bar status updated: \(self.statusText)", category: .general)
        }
    }

    /// Get current status summary
    var statusSummary: String {
        var components: [String] = []

        if isPlaying {
            components.append("🎵 Playing")
        }

        if !trayStorage.items.isEmpty {
            components.append("📎 \(trayStorage.items.count)")
        }

        if notchState.isExpanded {
            components.append("📱 Expanded")
        }

        return components.isEmpty ? "Ready" : components.joined(separator: " • ")
    }

    /// Get icon for current state
    var currentIcon: String {
        if isPlaying {
            return "music.note"
        } else if !trayStorage.items.isEmpty {
            return "tray.fill"
        } else if notchState.isExpanded {
            return "circle.fill"
        } else {
            return "circle"
        }
    }

    /// Get icon color for current state
    var iconColor: Color {
        if isPlaying {
            return .blue
        } else if !trayStorage.items.isEmpty {
            return .purple
        } else if notchState.isExpanded {
            return .green
        } else {
            return .gray
        }
    }
}

// MARK: - Menu Bar Icon View
/// Custom view for menu bar icon with badge
struct MenuBarIconView: View {

    @ObservedObject private var manager = MenuBarManager.shared

    var body: some View {
        HStack(spacing: 4) {
            // Main icon
            Image(systemName: manager.currentIcon)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(manager.iconColor)

            // Badge count as text (simpler and more compatible)
            if manager.badgeCount > 0 {
                Text("\(manager.badgeCount)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Menu Bar Status View
/// Detailed status view for menu bar tooltip
struct MenuBarStatusView: View {

    @ObservedObject private var manager = MenuBarManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("NotchApp")
                .font(.system(size: 11, weight: .semibold))

            if manager.isPlaying {
                HStack(spacing: 4) {
                    Image(systemName: "music.note")
                        .font(.system(size: 9))
                    Text(manager.statusText)
                        .font(.system(size: 10))
                        .lineLimit(1)
                }
            }

            if manager.badgeCount > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "tray.fill")
                        .font(.system(size: 9))
                    Text("\(manager.badgeCount) \(manager.badgeCount == 1 ? "item" : "items")")
                        .font(.system(size: 10))
                }
            }
        }
        .padding(6)
    }
}
