import SwiftUI

// MARK: - Album Artwork View
/// Reusable component for displaying album artwork with consistent styling
/// Handles both loaded artwork and placeholder states

struct AlbumArtworkView: View {

    // MARK: - Properties
    let artwork: NSImage?
    let size: CGFloat
    let cornerRadius: CGFloat
    let showOverlay: Bool

    // MARK: - Initialization
    init(
        artwork: NSImage?,
        size: CGFloat = 80,
        cornerRadius: CGFloat = 14,
        showOverlay: Bool = true
    ) {
        self.artwork = artwork
        self.size = size
        self.cornerRadius = cornerRadius
        self.showOverlay = showOverlay
    }

    // MARK: - Body
    var body: some View {
        Group {
            if let artwork = artwork {
                Image(nsImage: artwork)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                placeholderView
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(borderOverlay)
        .standardShadow()
    }

    // MARK: - Subviews
    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(AppTheme.Colors.placeholderGradient)
            .overlay(
                Image(systemName: "music.note")
                    .font(.system(size: size * 0.35, weight: .light))
                    .foregroundColor(.white.opacity(0.7))
            )
    }

    @ViewBuilder
    private var borderOverlay: some View {
        if showOverlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
        }
    }
}

// MARK: - Album Artwork with App Badge
/// Album artwork with an app icon badge overlay

struct AlbumArtworkWithBadge: View {

    // MARK: - Properties
    let artwork: NSImage?
    let size: CGFloat
    let badgeIcon: String
    let badgeGradient: LinearGradient

    // MARK: - Initialization
    init(
        artwork: NSImage?,
        size: CGFloat = 80,
        badgeIcon: String = "music.note",
        badgeGradient: LinearGradient = AppTheme.Colors.appleMusicGradient
    ) {
        self.artwork = artwork
        self.size = size
        self.badgeIcon = badgeIcon
        self.badgeGradient = badgeGradient
    }

    // MARK: - Computed Properties
    private var badgeSize: CGFloat { size * 0.3 }
    private var badgeOffset: CGFloat { size * 0.075 }
    private var badgeIconSize: CGFloat { badgeSize * 0.46 }
    private var badgeCornerRadius: CGFloat { badgeSize * 0.25 }

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AlbumArtworkView(artwork: artwork, size: size)

            // Badge overlay
            ZStack {
                RoundedRectangle(cornerRadius: badgeCornerRadius, style: .continuous)
                    .fill(badgeGradient)
                    .frame(width: badgeSize, height: badgeSize)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)

                Image(systemName: badgeIcon)
                    .font(.system(size: badgeIconSize, weight: .bold))
                    .foregroundColor(.white)
            }
            .offset(x: badgeOffset, y: badgeOffset)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 30) {
        HStack(spacing: 20) {
            AlbumArtworkView(artwork: nil, size: 60)
            AlbumArtworkView(artwork: nil, size: 80)
            AlbumArtworkView(artwork: nil, size: 100)
        }

        HStack(spacing: 20) {
            AlbumArtworkWithBadge(artwork: nil, size: 60)
            AlbumArtworkWithBadge(artwork: nil, size: 80)
            AlbumArtworkWithBadge(artwork: nil, size: 100)
        }
    }
    .padding()
    .background(Color.black)
}
