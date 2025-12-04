import SwiftUI

struct DashboardView: View {
    @ObservedObject var mediaManager: MediaPlayerManager

    var body: some View {
        HStack(spacing: 0) {
            // Left: Media Player Section
            mediaPlayerSection

            Spacer()

            // Right: Quick Action Buttons
            VStack(spacing: 8) {
                QuickActionPill(icon: "sparkles", title: "Spotify", iconColor: .green) {
                    openSpotify()
                }

                QuickActionPill(icon: "sparkles", title: "Ring Laís", iconColor: .yellow) {
                    // Custom action
                }
            }
            .frame(width: 120)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var mediaPlayerSection: some View {
        HStack(spacing: 16) {
            // Album Artwork with App Icon overlay
            ZStack(alignment: .bottomTrailing) {
                if let artwork = mediaManager.currentMedia.artwork {
                    Image(nsImage: artwork)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                } else {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.7), Color.brown.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "music.note")
                                .font(.system(size: 28, weight: .light))
                                .foregroundColor(.white.opacity(0.7))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                }

                // Apple Music icon overlay
                ZStack {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 1, green: 0.2, blue: 0.4), Color(red: 1, green: 0.4, blue: 0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 24, height: 24)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)

                    Image(systemName: "music.note")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                }
                .offset(x: 6, y: 6)
            }

            // Song Info and Controls
            VStack(alignment: .leading, spacing: 3) {
                Text(mediaManager.currentMedia.title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)

                if let album = mediaManager.currentMedia.album, !album.isEmpty {
                    Text(album)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                        .lineLimit(1)
                }

                Text(mediaManager.currentMedia.artist)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))
                    .lineLimit(1)

                Spacer()
                    .frame(height: 8)

                // Playback Controls
                HStack(spacing: 24) {
                    Button(action: { mediaManager.previousTrack() }) {
                        Image(systemName: "backward.end.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())

                    Button(action: { mediaManager.togglePlayPause() }) {
                        Image(systemName: mediaManager.currentMedia.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())

                    Button(action: { mediaManager.nextTrack() }) {
                        Image(systemName: "forward.end.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                }
            }
        }
    }

    private func openSpotify() {
        if let url = URL(string: "spotify://") {
            if NSWorkspace.shared.urlForApplication(toOpen: url) != nil {
                NSWorkspace.shared.open(url)
            } else if let webURL = URL(string: "https://open.spotify.com") {
                NSWorkspace.shared.open(webURL)
            }
        }
    }
}

// Quick Action Pill Button
struct QuickActionPill: View {
    let icon: String
    let title: String
    let iconColor: Color
    let action: () -> Void

    @State private var isPressed = false
    @State private var isHovering = false

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
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(iconColor)

                Text(title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(isHovering ? 0.12 : 0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.12),
                                Color.white.opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}
