import SwiftUI
import Combine

// MARK: - Settings Manager
/// Manages all app settings with persistence using UserDefaults

final class SettingsManager: ObservableObject {

    // MARK: - Singleton
    static let shared = SettingsManager()

    // MARK: - UserDefaults Keys
    private enum Keys {
        static let accentColor = "accentColor"
        static let enableHaptics = "enableHaptics"
        static let enableAnimations = "enableAnimations"
        static let autoHideDelay = "autoHideDelay"
        static let showMediaPlayer = "showMediaPlayer"
        static let showShortcuts = "showShortcuts"
        static let enableGlowEffect = "enableGlowEffect"
        static let glowIntensity = "glowIntensity"
        static let cornerRadius = "cornerRadius"
        static let launchAtLogin = "launchAtLogin"
        static let enableSoundEffects = "enableSoundEffects"
        static let notchSize = "notchSize"
        static let enableBlur = "enableBlur"
        static let showInMenuBar = "showInMenuBar"
    }

    // MARK: - Appearance Settings
    @Published var accentColor: AccentColorOption {
        didSet { UserDefaults.standard.set(accentColor.rawValue, forKey: Keys.accentColor) }
    }

    @Published var enableGlowEffect: Bool {
        didSet { UserDefaults.standard.set(enableGlowEffect, forKey: Keys.enableGlowEffect) }
    }

    @Published var glowIntensity: Double {
        didSet { UserDefaults.standard.set(glowIntensity, forKey: Keys.glowIntensity) }
    }

    @Published var cornerRadius: Double {
        didSet { UserDefaults.standard.set(cornerRadius, forKey: Keys.cornerRadius) }
    }

    @Published var enableBlur: Bool {
        didSet { UserDefaults.standard.set(enableBlur, forKey: Keys.enableBlur) }
    }

    @Published var notchSize: NotchSizeOption {
        didSet { UserDefaults.standard.set(notchSize.rawValue, forKey: Keys.notchSize) }
    }

    // MARK: - General Settings
    @Published var enableHaptics: Bool {
        didSet { UserDefaults.standard.set(enableHaptics, forKey: Keys.enableHaptics) }
    }

    @Published var enableAnimations: Bool {
        didSet { UserDefaults.standard.set(enableAnimations, forKey: Keys.enableAnimations) }
    }

    @Published var enableSoundEffects: Bool {
        didSet { UserDefaults.standard.set(enableSoundEffects, forKey: Keys.enableSoundEffects) }
    }

    @Published var autoHideDelay: Double {
        didSet { UserDefaults.standard.set(autoHideDelay, forKey: Keys.autoHideDelay) }
    }

    @Published var launchAtLogin: Bool {
        didSet { UserDefaults.standard.set(launchAtLogin, forKey: Keys.launchAtLogin) }
    }

    @Published var showInMenuBar: Bool {
        didSet { UserDefaults.standard.set(showInMenuBar, forKey: Keys.showInMenuBar) }
    }

    // MARK: - Widget Settings
    @Published var showMediaPlayer: Bool {
        didSet { UserDefaults.standard.set(showMediaPlayer, forKey: Keys.showMediaPlayer) }
    }

    @Published var showShortcuts: Bool {
        didSet { UserDefaults.standard.set(showShortcuts, forKey: Keys.showShortcuts) }
    }

    // MARK: - Initialization
    private init() {
        // Load saved settings or use defaults
        let defaults = UserDefaults.standard

        // Appearance
        self.accentColor = AccentColorOption(rawValue: defaults.string(forKey: Keys.accentColor) ?? "") ?? .purple
        self.enableGlowEffect = defaults.object(forKey: Keys.enableGlowEffect) as? Bool ?? true
        self.glowIntensity = defaults.object(forKey: Keys.glowIntensity) as? Double ?? 0.7
        self.cornerRadius = defaults.object(forKey: Keys.cornerRadius) as? Double ?? 14
        self.enableBlur = defaults.object(forKey: Keys.enableBlur) as? Bool ?? true
        self.notchSize = NotchSizeOption(rawValue: defaults.string(forKey: Keys.notchSize) ?? "") ?? .medium

        // General
        self.enableHaptics = defaults.object(forKey: Keys.enableHaptics) as? Bool ?? true
        self.enableAnimations = defaults.object(forKey: Keys.enableAnimations) as? Bool ?? true
        self.enableSoundEffects = defaults.object(forKey: Keys.enableSoundEffects) as? Bool ?? false
        self.autoHideDelay = defaults.object(forKey: Keys.autoHideDelay) as? Double ?? 0.5
        self.launchAtLogin = defaults.object(forKey: Keys.launchAtLogin) as? Bool ?? false
        self.showInMenuBar = defaults.object(forKey: Keys.showInMenuBar) as? Bool ?? false

        // Widgets
        self.showMediaPlayer = defaults.object(forKey: Keys.showMediaPlayer) as? Bool ?? true
        self.showShortcuts = defaults.object(forKey: Keys.showShortcuts) as? Bool ?? true
    }

    // MARK: - Methods
    func resetToDefaults() {
        accentColor = .purple
        enableGlowEffect = true
        glowIntensity = 0.7
        cornerRadius = 14
        enableBlur = true
        notchSize = .medium
        enableHaptics = true
        enableAnimations = true
        enableSoundEffects = false
        autoHideDelay = 0.5
        launchAtLogin = false
        showInMenuBar = false
        showMediaPlayer = true
        showShortcuts = true
    }
}

// MARK: - Accent Color Options
enum AccentColorOption: String, CaseIterable, Identifiable {
    case purple = "purple"
    case blue = "blue"
    case cyan = "cyan"
    case green = "green"
    case orange = "orange"
    case pink = "pink"
    case red = "red"
    case yellow = "yellow"
    case indigo = "indigo"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .purple: return .purple
        case .blue: return .blue
        case .cyan: return .cyan
        case .green: return .green
        case .orange: return .orange
        case .pink: return .pink
        case .red: return .red
        case .yellow: return .yellow
        case .indigo: return .indigo
        }
    }

    var displayName: String {
        rawValue.capitalized
    }
}

// MARK: - Notch Size Options
enum NotchSizeOption: String, CaseIterable, Identifiable {
    case small = "small"
    case medium = "medium"
    case large = "large"

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }

    var scaleFactor: CGFloat {
        switch self {
        case .small: return 0.85
        case .medium: return 1.0
        case .large: return 1.15
        }
    }
}
