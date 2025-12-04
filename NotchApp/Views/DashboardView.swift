import SwiftUI

// MARK: - Dashboard View
/// The main dashboard view displayed in the expanded notch
/// Shows media player controls and quick action buttons

struct DashboardView: View {

    // MARK: - Properties
    @ObservedObject var mediaManager: MediaPlayerManager

    // MARK: - Body
    var body: some View {
        HStack(spacing: 0) {
            // Left: Media Player Section
            mediaPlayerSection

            Spacer()

            // Right: Quick Action Buttons
            quickActionsSection
        }
        .padding(.horizontal, AppConstants.Layout.padding)
        .padding(.vertical, AppConstants.Layout.padding - 2)
    }

    // MARK: - Media Player Section
    private var mediaPlayerSection: some View {
        HStack(spacing: AppConstants.Layout.spacing) {
            // Album Artwork with App Icon overlay
            AlbumArtworkWithBadge(
                artwork: mediaManager.currentMedia.artwork,
                size: AppConstants.Layout.iconSize,
                badgeIcon: "music.note",
                badgeGradient: AppTheme.Colors.appleMusicGradient
            )

            // Song Info and Controls
            songInfoAndControls
        }
    }

    // MARK: - Song Info and Controls
    private var songInfoAndControls: some View {
        VStack(alignment: .leading, spacing: 3) {
            // Song title
            Text(mediaManager.currentMedia.title)
                .font(AppTheme.Typography.title())
                .foregroundColor(AppTheme.Colors.textPrimary)
                .lineLimit(1)

            // Album name (if available)
            if let album = mediaManager.currentMedia.album, !album.isEmpty {
                Text(album)
                    .font(AppTheme.Typography.body())
                    .foregroundColor(AppTheme.Colors.textTertiary)
                    .lineLimit(1)
            }

            // Artist name
            Text(mediaManager.currentMedia.artist)
                .font(AppTheme.Typography.body())
                .foregroundColor(AppTheme.Colors.textQuaternary)
                .lineLimit(1)

            Spacer()
                .frame(height: AppConstants.Layout.smallSpacing)

            // Playback Controls
            PlaybackControlsRow(
                isPlaying: mediaManager.currentMedia.isPlaying,
                onPrevious: { mediaManager.previousTrack() },
                onPlayPause: { mediaManager.togglePlayPause() },
                onNext: { mediaManager.nextTrack() }
            )
        }
    }

    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(spacing: AppConstants.Layout.smallSpacing) {
            QuickActionPill(
                icon: "sparkles",
                title: "Spotify",
                iconColor: AppTheme.Colors.accentGreen
            ) {
                openSpotify()
            }

            QuickActionPill(
                icon: "sparkles",
                title: "Ring Laís",
                iconColor: AppTheme.Colors.accentYellow
            ) {
                // Custom action placeholder
            }
        }
        .frame(width: 120)
    }

    // MARK: - Actions

    private func openSpotify() {
        guard let url = URL(string: "spotify://") else { return }

        if NSWorkspace.shared.urlForApplication(toOpen: url) != nil {
            NSWorkspace.shared.open(url)
        } else if let webURL = URL(string: "https://open.spotify.com") {
            NSWorkspace.shared.open(webURL)
        }
    }
}

// MARK: - Preview
#Preview {
    DashboardView(mediaManager: MediaPlayerManager())
        .frame(width: 500, height: 120)
        .background(Color.black)
}
