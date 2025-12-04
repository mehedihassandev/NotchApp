import SwiftUI

// MARK: - App Theme
/// Centralized design tokens for consistent UI across the app
/// Following Apple's design guidelines for macOS

enum AppTheme {

    // MARK: - Colors
    enum Colors {
        // Primary colors
        static let primary = Color.white
        static let background = Color.black

        // Text colors
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.7)
        static let textTertiary = Color.white.opacity(0.5)
        static let textQuaternary = Color.white.opacity(0.4)

        // Accent colors
        static let accentPurple = Color.purple
        static let accentBlue = Color.blue
        static let accentIndigo = Color.indigo
        static let accentCyan = Color.cyan
        static let accentGreen = Color.green
        static let accentOrange = Color.orange
        static let accentYellow = Color.yellow

        // UI element colors
        static let cardBackground = Color.white.opacity(0.06)
        static let cardBackgroundHover = Color.white.opacity(0.12)
        static let borderColor = Color.white.opacity(0.1)
        static let borderColorHover = Color.white.opacity(0.2)

        // Gradients
        static var glowGradient: LinearGradient {
            LinearGradient(
                colors: [
                    accentPurple.opacity(0.6),
                    accentBlue.opacity(0.7),
                    accentIndigo.opacity(0.5)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        }

        static var borderGradient: LinearGradient {
            LinearGradient(
                colors: [
                    Color.white.opacity(0.12),
                    Color.white.opacity(0.04)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        static var musicGradient: LinearGradient {
            LinearGradient(
                colors: [accentCyan, accentPurple],
                startPoint: .bottom,
                endPoint: .top
            )
        }

        static var appleMusicGradient: LinearGradient {
            LinearGradient(
                colors: [Color(red: 1, green: 0.2, blue: 0.4), Color(red: 1, green: 0.4, blue: 0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        static var placeholderGradient: LinearGradient {
            LinearGradient(
                colors: [Color.orange.opacity(0.7), Color.brown.opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        static var airDropGradient: LinearGradient {
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.18, blue: 0.32),
                    Color(red: 0.08, green: 0.12, blue: 0.28)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    // MARK: - Typography
    enum Typography {
        static func title(_ size: CGFloat = 17) -> Font {
            .system(size: size, weight: .bold, design: .rounded)
        }

        static func headline(_ size: CGFloat = 14) -> Font {
            .system(size: size, weight: .semibold, design: .rounded)
        }

        static func body(_ size: CGFloat = 12) -> Font {
            .system(size: size, weight: .medium, design: .rounded)
        }

        static func caption(_ size: CGFloat = 10) -> Font {
            .system(size: size, weight: .medium, design: .rounded)
        }

        static func icon(_ size: CGFloat = 14) -> Font {
            .system(size: size, weight: .medium)
        }
    }

    // MARK: - Shadows
    enum Shadows {
        static let card = Shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        static let glow = Shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
    }

    // MARK: - Animations
    enum Animations {
        static var spring: SwiftUI.Animation {
            .spring(response: AppConstants.Animation.springResponse, dampingFraction: AppConstants.Animation.springDamping)
        }

        static var springFast: SwiftUI.Animation {
            .spring(response: 0.3, dampingFraction: 0.7)
        }

        static var easeOut: SwiftUI.Animation {
            .easeOut(duration: AppConstants.Animation.glowDuration)
        }

        static var hover: SwiftUI.Animation {
            .easeInOut(duration: AppConstants.Animation.hoverFeedback)
        }
    }
}

// MARK: - Shadow Helper
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}
