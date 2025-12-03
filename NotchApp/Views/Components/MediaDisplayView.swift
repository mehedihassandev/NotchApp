import SwiftUI

struct MediaDisplayView: View {
    let mediaInfo: MediaInfo
    let onPlayPause: () -> Void
    var onPrevious: (() -> Void)?
    var onNext: (() -> Void)?

    @State private var isHoveringPlayButton = false
    @State private var buttonScale: CGFloat = 1.0

    var body: some View {
        HStack(spacing: 16) {
            // Artwork with glassmorphism shadow
            artworkView

            // Media Info
            VStack(alignment: .leading, spacing: 8) {
                // Title with gradient shimmer effect
                Text(mediaInfo.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.primary, .primary.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(mediaInfo.artist)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Spacer()
                    .frame(height: 4)

                // Progress Bar with modern design
                progressBarView
            }
            .frame(maxWidth: .infinity)

            // Media Control Buttons
            mediaControls
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.black.opacity(0.25))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    private var artworkView: some View {
        Group {
            if let artwork = mediaInfo.artwork {
                Image(nsImage: artwork)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.25), radius: 10, y: 5)
            } else {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.gray.opacity(0.3),
                                Color.gray.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                    .overlay(
                        Image(systemName: "music.note")
                            .font(.system(size: 28, weight: .light))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white.opacity(0.6), .white.opacity(0.3)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            }
        }
    }

    private var progressBarView: some View {
        VStack(spacing: 6) {
            // Modern progress bar with glow
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 5)

                    // Progress fill with gradient
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.accentColor,
                                    Color.accentColor.opacity(0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * mediaInfo.progress, height: 5)
                        .shadow(color: Color.accentColor.opacity(0.5), radius: 4, y: 0)

                    // Progress indicator dot
                    Circle()
                        .fill(Color.white)
                        .frame(width: 10, height: 10)
                        .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                        .offset(x: geometry.size.width * mediaInfo.progress - 5)
                }
            }
            .frame(height: 5)

            // Time labels with better styling
            HStack {
                Text(mediaInfo.formattedCurrentTime)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary.opacity(0.8))
                    .monospacedDigit()

                Spacer()

                Text(mediaInfo.formattedDuration)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary.opacity(0.8))
                    .monospacedDigit()
            }
        }
    }

    private var mediaControls: some View {
        HStack(spacing: 12) {
            // Previous button
            if let onPrevious = onPrevious {
                MediaControlButton(icon: "backward.fill", size: 32) {
                    onPrevious()
                }
            }

            // Play/Pause Button with NotchNook-style animation
            playPauseButton

            // Next button
            if let onNext = onNext {
                MediaControlButton(icon: "forward.fill", size: 32) {
                    onNext()
                }
            }
        }
    }

    private var playPauseButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                buttonScale = 0.85
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    buttonScale = 1.0
                }
            }
            onPlayPause()
        }) {
            ZStack {
                // Glow effect when playing
                if mediaInfo.isPlaying {
                    Circle()
                        .fill(Color.accentColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                        .blur(radius: 8)
                }

                // Button background
                Circle()
                    .fill(Color.black.opacity(0.25))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.15), radius: 8, y: 4)

                // Icon
                Image(systemName: mediaInfo.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .offset(x: mediaInfo.isPlaying ? 0 : 1.5) // Center play icon
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isHoveringPlayButton ? 1.1 : buttonScale)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHoveringPlayButton)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: buttonScale)
        .onHover { hovering in
            isHoveringPlayButton = hovering
        }
        .help(mediaInfo.isPlaying ? "Pause" : "Play")
    }
}

struct MediaControlButton: View {
    let icon: String
    let size: CGFloat
    let action: () -> Void

    @State private var isHovering = false
    @State private var isPressed = false

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
                .font(.system(size: size * 0.4, weight: .medium))
                .foregroundColor(.white.opacity(isHovering ? 1.0 : 0.7))
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(Color.white.opacity(isHovering ? 0.15 : 0.05))
                )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        // Playing state
        MediaDisplayView(
            mediaInfo: MediaInfo(
                title: "Blinding Lights",
                artist: "The Weeknd",
                album: "After Hours",
                artwork: nil,
                isPlaying: true,
                duration: 240,
                currentTime: 120
            ),
            onPlayPause: {},
            onPrevious: {},
            onNext: {}
        )
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
        )

        // Paused state
        MediaDisplayView(
            mediaInfo: MediaInfo(
                title: "As It Was",
                artist: "Harry Styles",
                album: "Harry's House",
                artwork: nil,
                isPlaying: false,
                duration: 167,
                currentTime: 45
            ),
            onPlayPause: {},
            onPrevious: {},
            onNext: {}
        )
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
        )
    }
    .padding(40)
    .frame(width: 500)
    .background(
        LinearGradient(
            colors: [Color.blue.opacity(0.4), Color.purple.opacity(0.4)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
