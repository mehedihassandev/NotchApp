import AppKit

// MARK: - Haptic Manager
/// Centralized haptic feedback management for the app
/// Note: macOS haptics are limited compared to iOS

final class HapticManager {

    // MARK: - Singleton
    static let shared = HapticManager()

    private init() {}

    // MARK: - Feedback Types
    enum FeedbackType {
        case selection
        case success
        case warning
        case error
    }

    // MARK: - Public Methods

    /// Triggers haptic feedback if available
    /// - Parameter type: The type of feedback to trigger
    func trigger(_ type: FeedbackType) {
        // macOS doesn't have built-in haptic feedback API like iOS
        // On supported devices (MacBooks with Force Touch), the system
        // handles haptics automatically for standard controls

        // For custom haptics, we could potentially use:
        // - NSHapticFeedbackManager (limited availability)

        #if DEBUG
        print("🎯 Haptic feedback: \(type)")
        #endif
    }

    /// Triggers selection haptic
    func selection() {
        trigger(.selection)
    }

    /// Triggers success haptic
    func success() {
        trigger(.success)
    }

    /// Triggers warning haptic
    func warning() {
        trigger(.warning)
    }

    /// Triggers error haptic
    func error() {
        trigger(.error)
    }
}
