import SwiftUI

// MARK: - Quick Action Pill Button
/// A stylized pill-shaped button for quick actions

struct QuickActionPill: View {

    // MARK: - Properties
    let icon: String
    let title: String
    let iconColor: Color
    let action: () -> Void

    @State private var isPressed = false
    @State private var isHovering = false

    // MARK: - Initialization
    init(
        icon: String,
        title: String,
        iconColor: Color = .white,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.iconColor = iconColor
        self.action = action
    }

    // MARK: - Body
    var body: some View {
        Button(action: handleTap) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(iconColor)

                Text(title)
                    .font(AppTheme.Typography.body())
                    .foregroundColor(AppTheme.Colors.textPrimary.opacity(0.9))
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .cardStyle(isHovering: isHovering)
        }
        .buttonStyle(.plain)
        .pressEffect(isPressed)
        .onHover { hovering in
            withAnimation(AppTheme.Animations.hover) {
                isHovering = hovering
            }
        }
    }

    // MARK: - Actions
    private func handleTap() {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
            isPressed = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isPressed = false
            action()
        }
    }
}

// MARK: - Icon Button
/// A circular icon button with hover effects

struct IconButton: View {

    // MARK: - Properties
    let icon: String
    let size: CGFloat
    let action: () -> Void

    @State private var isHovering = false

    // MARK: - Initialization
    init(
        icon: String,
        size: CGFloat = 14,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.action = action
    }

    // MARK: - Body
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size, weight: .medium))
                .foregroundColor(AppTheme.Colors.textTertiary)
                .padding(10)
                .background(
                    Circle()
                        .fill(isHovering ? AppTheme.Colors.cardBackgroundHover : AppTheme.Colors.cardBackground)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                        )
                )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(AppTheme.Animations.hover) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        QuickActionPill(icon: "sparkles", title: "Spotify", iconColor: .green) {}
        QuickActionPill(icon: "phone.fill", title: "Ring Laís", iconColor: .yellow) {}

        HStack(spacing: 10) {
            IconButton(icon: "gearshape.fill") {}
            IconButton(icon: "xmark") {}
            IconButton(icon: "plus") {}
        }
    }
    .padding()
    .background(Color.black)
}
