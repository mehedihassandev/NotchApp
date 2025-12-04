import Foundation
import SwiftUI

// MARK: - App Constants
/// Centralized configuration values for the NotchApp
/// This makes it easy to adjust values without hunting through code

enum AppConstants {

    // MARK: - Window Configuration
    enum Window {
        static let width: CGFloat = 580
        static let height: CGFloat = 400
        static let collapsedOffset: CGFloat = -22
        static let trackingAreaHeight: CGFloat = 50
    }

    // MARK: - Animation Durations
    enum Animation {
        static let glowDuration: TimeInterval = 0.35
        static let scaleDuration: TimeInterval = 0.4
        static let contentDelay: TimeInterval = 0.25
        static let scaleDelay: TimeInterval = 0.1
        static let closeDelay: TimeInterval = 0.5
        static let hoverFeedback: TimeInterval = 0.15
        static let springResponse: Double = 0.35
        static let springDamping: Double = 0.8
    }

    // MARK: - Media Player
    enum MediaPlayer {
        static let pollingInterval: TimeInterval = 0.5
        static let pollingTolerance: TimeInterval = 0.1
        static let commandDelay: TimeInterval = 0.1
    }

    // MARK: - Layout
    enum Layout {
        static let cornerRadius: CGFloat = 14
        static let smallCornerRadius: CGFloat = 8
        static let iconSize: CGFloat = 80
        static let smallIconSize: CGFloat = 32
        static let spacing: CGFloat = 16
        static let smallSpacing: CGFloat = 8
        static let padding: CGFloat = 16
        static let smallPadding: CGFloat = 8
    }

    // MARK: - Opacity Values
    enum Opacity {
        static let primary: Double = 1.0
        static let secondary: Double = 0.7
        static let tertiary: Double = 0.5
        static let quaternary: Double = 0.4
        static let subtle: Double = 0.2
        static let faint: Double = 0.1
        static let veryFaint: Double = 0.06
    }
}
