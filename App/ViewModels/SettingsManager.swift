import SwiftUI
import Combine

// MARK: - Settings Manager
/// Manages all app settings with persistence using UserDefaults

final class SettingsManager: ObservableObject {

    // MARK: - Singleton
    static let shared = SettingsManager()

    // MARK: - UserDefaults Keys
    private enum Keys {
        static let enableNotch = "enableNotch"
        static let notchSize = "notchSize"
        static let enableGlowEffect = "enableGlowEffect"
        static let glowIntensity = "glowIntensity"
        static let cornerRadius = "cornerRadius"
        static let enableBlur = "enableBlur"
    }

    // MARK: - Notch Customization Settings
    @Published var enableNotch: Bool {
        didSet { UserDefaults.standard.set(enableNotch, forKey: Keys.enableNotch) }
    }

    @Published var notchSize: NotchSizeOption {
        didSet { UserDefaults.standard.set(notchSize.rawValue, forKey: Keys.notchSize) }
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

    // MARK: - Initialization
    private init() {
        // Load saved settings or use defaults
        let defaults = UserDefaults.standard
        self.enableNotch = defaults.object(forKey: Keys.enableNotch) as? Bool ?? true
        self.notchSize = NotchSizeOption(rawValue: defaults.string(forKey: Keys.notchSize) ?? "") ?? .medium
        self.enableGlowEffect = defaults.object(forKey: Keys.enableGlowEffect) as? Bool ?? true
        self.glowIntensity = defaults.object(forKey: Keys.glowIntensity) as? Double ?? 0.7
        self.cornerRadius = defaults.object(forKey: Keys.cornerRadius) as? Double ?? 14
        self.enableBlur = defaults.object(forKey: Keys.enableBlur) as? Bool ?? true
    }

    // MARK: - Methods
    func resetToDefaults() {
        enableNotch = true
        notchSize = .medium
        enableGlowEffect = true
        glowIntensity = 0.7
        cornerRadius = 14
        enableBlur = true
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
enum NotchSizeOption: String, CaseIterable, Identifiable, CustomStringConvertible {
        var description: String {
            displayName
        }
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
