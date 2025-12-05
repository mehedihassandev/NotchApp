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
        case light
        case medium
        case heavy
    }

    // MARK: - Public Methods

    /// Triggers haptic feedback if available
    /// - Parameter type: The type of feedback to trigger
    func trigger(_ type: FeedbackType) {
        // macOS doesn't have built-in haptic feedback API like iOS
        // On supported devices (MacBooks with Force Touch), the system
        // handles haptics automatically for standard controls

        // Use NSHapticFeedbackManager for Force Touch trackpads
        let performer = NSHapticFeedbackManager.defaultPerformer

        switch type {
        case .selection, .light:
            performer.perform(.alignment, performanceTime: .default)
        case .success, .medium:
            performer.perform(.levelChange, performanceTime: .default)
        case .warning, .heavy:
            performer.perform(.generic, performanceTime: .default)
        case .error:
            performer.perform(.generic, performanceTime: .default)
        }

        #if DEBUG
        print("🎯 Haptic feedback: \(type)")
        #endif
    }

    /// Play feedback with intensity level
    /// - Parameter type: The intensity type of feedback
    func playFeedback(_ type: FeedbackType) {
        trigger(type)
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
