import SwiftUI

// MARK: - Playback Control Button
/// Reusable button component for media playback controls

struct PlaybackControlButton: View {

    // MARK: - Properties
    let icon: String
    let size: PlaybackButtonSize
    let action: () -> Void

    @State private var isPressed = false

    // MARK: - Size Configuration
    enum PlaybackButtonSize {
        case small
        case medium
        case large

        var iconSize: CGFloat {
            switch self {
            case .small: return 14
            case .medium: return 18
            case .large: return 24
            }
        }

        var hitArea: CGFloat {
            switch self {
            case .small: return 30
            case .medium: return 40
            case .large: return 50
            }
        }

        var opacity: Double {
            switch self {
            case .small, .medium: return 0.7
            case .large: return 1.0
            }
        }
    }

    // MARK: - Initialization
    init(
        icon: String,
        size: PlaybackButtonSize = .medium,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.action = action
    }

    // MARK: - Body
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isPressed = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                action()
            }
        }) {
            Image(systemName: icon)
                .font(.system(size: size.iconSize, weight: .medium))
                .foregroundColor(.white.opacity(size.opacity))
                .frame(width: size.hitArea, height: size.hitArea)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.9 : 1.0)
    }
}

// MARK: - Playback Controls Row
/// A horizontal row of playback controls (previous, play/pause, next)

struct PlaybackControlsRow: View {

    // MARK: - Properties
    let isPlaying: Bool
    let onPrevious: () -> Void
    let onPlayPause: () -> Void
    let onNext: () -> Void
    let spacing: CGFloat

    // MARK: - Initialization
    init(
        isPlaying: Bool,
        spacing: CGFloat = 24,
        onPrevious: @escaping () -> Void,
        onPlayPause: @escaping () -> Void,
        onNext: @escaping () -> Void
    ) {
        self.isPlaying = isPlaying
        self.spacing = spacing
        self.onPrevious = onPrevious
        self.onPlayPause = onPlayPause
        self.onNext = onNext
    }

    // MARK: - Body
    var body: some View {
        HStack(spacing: spacing) {
            PlaybackControlButton(
                icon: "backward.end.fill",
                size: .medium,
                action: onPrevious
            )

            PlaybackControlButton(
                icon: isPlaying ? "pause.fill" : "play.fill",
                size: .large,
                action: onPlayPause
            )

            PlaybackControlButton(
                icon: "forward.end.fill",
                size: .medium,
                action: onNext
            )
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 40) {
        HStack(spacing: 20) {
            PlaybackControlButton(icon: "backward.end.fill", size: .small) {}
            PlaybackControlButton(icon: "play.fill", size: .medium) {}
            PlaybackControlButton(icon: "forward.end.fill", size: .large) {}
        }

        PlaybackControlsRow(
            isPlaying: true,
            onPrevious: {},
            onPlayPause: {},
            onNext: {}
        )

        PlaybackControlsRow(
            isPlaying: false,
            onPrevious: {},
            onPlayPause: {},
            onNext: {}
        )
    }
    .padding()
    .background(Color.black)
}
