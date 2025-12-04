import SwiftUI

// MARK: - View Extensions
/// Reusable view modifiers for consistent styling across the app

extension View {

    // MARK: - Card Style
    /// Applies a standard card background with optional hover state
    func cardStyle(
        isHovering: Bool = false,
        cornerRadius: CGFloat = AppConstants.Layout.cornerRadius
    ) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(isHovering ? AppTheme.Colors.cardBackgroundHover : AppTheme.Colors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        AppTheme.Colors.borderGradient,
                        lineWidth: 0.5
                    )
            )
    }

    // MARK: - Glass Style
    /// Applies a glassmorphism effect
    func glassStyle(cornerRadius: CGFloat = AppConstants.Layout.cornerRadius) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                    )
            )
    }

    // MARK: - Hover Scale Effect
    /// Adds a subtle scale effect on hover
    func hoverScale(_ isHovering: Bool, scale: CGFloat = 1.02) -> some View {
        self
            .scaleEffect(isHovering ? scale : 1.0)
            .animation(AppTheme.Animations.springFast, value: isHovering)
    }

    // MARK: - Press Effect
    /// Adds a press/tap effect
    func pressEffect(_ isPressed: Bool, scale: CGFloat = 0.96) -> some View {
        self
            .scaleEffect(isPressed ? scale : 1.0)
    }

    // MARK: - Standard Shadow
    /// Applies the standard card shadow
    func standardShadow() -> some View {
        self.shadow(
            color: AppTheme.Shadows.card.color,
            radius: AppTheme.Shadows.card.radius,
            x: AppTheme.Shadows.card.x,
            y: AppTheme.Shadows.card.y
        )
    }

    // MARK: - Conditional Modifier
    /// Applies a modifier only when a condition is true
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    // MARK: - On First Appear
    /// Executes an action only on the first appear
    func onFirstAppear(_ action: @escaping () -> Void) -> some View {
        modifier(FirstAppearModifier(action: action))
    }
}

// MARK: - First Appear Modifier
private struct FirstAppearModifier: ViewModifier {
    let action: () -> Void
    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        content.onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            action()
        }
    }
}

// MARK: - Rounded Corner Extension
extension View {
    /// Clips view with specific rounded corners
    func cornerRadius(_ radius: CGFloat, corners: RectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - RectCorner
struct RectCorner: OptionSet, Sendable {
    let rawValue: Int

    init(rawValue: Int) {
        self.rawValue = rawValue
    }

    static let topLeft = RectCorner(rawValue: 1 << 0)
    static let topRight = RectCorner(rawValue: 1 << 1)
    static let bottomLeft = RectCorner(rawValue: 1 << 2)
    static let bottomRight = RectCorner(rawValue: 1 << 3)
    static let top: RectCorner = [.topLeft, .topRight]
    static let bottom: RectCorner = [.bottomLeft, .bottomRight]
    static let all: RectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
}

// MARK: - Rounded Corner Shape
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: RectCorner = .all

    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()

        // Use raw values directly to avoid MainActor isolation issues
        let topLeftRadius = corners.rawValue & (1 << 0) != 0 ? radius : 0
        let topRightRadius = corners.rawValue & (1 << 1) != 0 ? radius : 0
        let bottomLeftRadius = corners.rawValue & (1 << 2) != 0 ? radius : 0
        let bottomRightRadius = corners.rawValue & (1 << 3) != 0 ? radius : 0

        path.move(to: CGPoint(x: rect.minX + topLeftRadius, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - topRightRadius, y: rect.minY))
        path.addArc(
            center: CGPoint(x: rect.maxX - topRightRadius, y: rect.minY + topRightRadius),
            radius: topRightRadius,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRightRadius))
        path.addArc(
            center: CGPoint(x: rect.maxX - bottomRightRadius, y: rect.maxY - bottomRightRadius),
            radius: bottomRightRadius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.minX + bottomLeftRadius, y: rect.maxY))
        path.addArc(
            center: CGPoint(x: rect.minX + bottomLeftRadius, y: rect.maxY - bottomLeftRadius),
            radius: bottomLeftRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeftRadius))
        path.addArc(
            center: CGPoint(x: rect.minX + topLeftRadius, y: rect.minY + topLeftRadius),
            radius: topLeftRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )

        return path
    }
}
