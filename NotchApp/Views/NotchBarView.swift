import SwiftUI

// MARK: - Notch Bar View
/// The main notch interface that displays collapsed and expanded states
/// Handles hover interactions and animations

struct NotchBarView: View {

    // MARK: - State Objects
    @StateObject private var mediaManager = MediaPlayerManager()
    @StateObject private var notchState = NotchState.shared

    // MARK: - State Properties
    @State private var isHovering = false
    @State private var showContent = false
    @State private var glowIntensity: CGFloat = 0
    @State private var scaleProgress: CGFloat = 0.5
    @State private var closeTimer: Timer?
    @State private var selectedTab: NotchTab = .nook

    @Namespace private var tabNamespace

    // MARK: - Animation Constants
    private let glowAnimation = Animation.easeInOut(duration: AppConstants.Animation.glowDuration)
    private let scaleAnimation = Animation.spring(
        response: AppConstants.Animation.scaleDuration,
        dampingFraction: 0.8
    )
    private let contentAnimation = Animation.spring(
        response: AppConstants.Animation.springResponse,
        dampingFraction: AppConstants.Animation.springDamping
    )

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                notchContainer
                    .onHover { hovering in
                        handleHover(hovering)
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

// MARK: - Hover Handling
extension NotchBarView {

    private func handleHover(_ hovering: Bool) {
        closeTimer?.invalidate()
        closeTimer = nil

        if hovering {
            expandNotch()
        } else {
            scheduleCollapse()
        }
    }

    private func expandNotch() {
        // Phase 1: Show glow effect
        withAnimation(glowAnimation) {
            isHovering = true
            glowIntensity = 1
        }

        // Phase 2: Scale to 100% after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.Animation.scaleDelay) {
            withAnimation(scaleAnimation) {
                scaleProgress = 1.0
            }
        }

        // Phase 3: Show content after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.Animation.contentDelay) {
            withAnimation(contentAnimation) {
                showContent = true
                notchState.isExpanded = true
            }
        }
    }

    private func scheduleCollapse() {
        closeTimer = Timer.scheduledTimer(
            withTimeInterval: AppConstants.Animation.closeDelay,
            repeats: false
        ) { _ in
            collapseNotch()
        }
    }

    private func collapseNotch() {
        // Reverse animation sequence
        withAnimation(contentAnimation) {
            showContent = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(scaleAnimation) {
                scaleProgress = 0.5
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(glowAnimation) {
                isHovering = false
                glowIntensity = 0
                notchState.isExpanded = false
            }
        }
    }
}

// MARK: - Notch Container
extension NotchBarView {

    private var notchContainer: some View {
        VStack(spacing: 0) {
            if showContent {
                expandedContent
                    .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .top)))
            } else {
                collapsedNotch
                    .transition(.opacity)
            }
        }
        .scaleEffect(x: scaleProgress, y: 1, anchor: .center)
        .background(notchBackground)
        .overlay(notchBorder)
        .clipShape(NotchShape(topCornerRadius: 0, bottomCornerRadius: showContent ? 16 : 12))
        .offset(y: isHovering ? 0 : AppConstants.Window.collapsedOffset)
        .opacity(isHovering ? 1.0 : 0.5)
    }

    private var notchBackground: some View {
        ZStack {
            // Glow effect
            NotchShape(topCornerRadius: 0, bottomCornerRadius: showContent ? 16 : 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.purple.opacity(0.6 * glowIntensity),
                            Color.blue.opacity(0.7 * glowIntensity),
                            Color.indigo.opacity(0.5 * glowIntensity)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .blur(radius: 15 * glowIntensity)
                .offset(y: 8 * glowIntensity)
                .scaleEffect(x: 0.95, y: 1.1)

            // Main black background
            NotchShape(topCornerRadius: 0, bottomCornerRadius: showContent ? 16 : 12)
                .fill(AppTheme.Colors.background)
        }
    }

    private var notchBorder: some View {
        NotchShape(topCornerRadius: 0, bottomCornerRadius: showContent ? 16 : 12)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.purple.opacity(0.4 * glowIntensity),
                        Color.blue.opacity(0.5 * glowIntensity),
                        Color.purple.opacity(0.4 * glowIntensity),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: 1.5
            )
    }
}

// MARK: - Collapsed State
extension NotchBarView {

    private var collapsedNotch: some View {
        HStack(spacing: 12) {
            // Only show content when media is playing
            if mediaManager.currentMedia.hasContent {
                collapsedMediaContent
            }
        }
        .padding(.horizontal, mediaManager.currentMedia.hasContent ? 18 : 0)
        .padding(.vertical, 10)
        .frame(minWidth: 180, minHeight: 36)
    }

    private var collapsedMediaContent: some View {
        Group {
            // Album artwork (small)
            AlbumArtworkView(
                artwork: mediaManager.currentMedia.artwork,
                size: AppConstants.Layout.smallIconSize,
                cornerRadius: AppConstants.Layout.smallCornerRadius
            )

            // Song info
            VStack(alignment: .leading, spacing: 2) {
                Text(mediaManager.currentMedia.title)
                    .font(AppTheme.Typography.body())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .lineLimit(1)

                Text(mediaManager.currentMedia.artist)
                    .font(AppTheme.Typography.caption())
                    .foregroundColor(AppTheme.Colors.textTertiary)
                    .lineLimit(1)
            }
            .frame(maxWidth: 150, alignment: .leading)

            // Music bars when playing
            if mediaManager.currentMedia.isPlaying {
                MusicBarsView(isPlaying: mediaManager.currentMedia.isPlaying)
                    .padding(.leading, 8)
            }
        }
    }
}

// MARK: - Expanded State
extension NotchBarView {

    private var expandedContent: some View {
        VStack(spacing: 0) {
            // Header with tab switcher
            expandedHeader

            // Tab content
            Group {
                switch selectedTab {
                case .nook:
                    DashboardView(mediaManager: mediaManager)
                case .tray:
                    TrayView()
                }
            }
            .padding(.bottom, 18)
        }
        .padding(.horizontal, 4)
    }

    private var expandedHeader: some View {
        HStack {
            // Tab Switcher
            tabSwitcher

            Spacer()

            // Settings button
            IconButton(icon: "gearshape.fill") {
                // Settings action
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 14)
    }

    private var tabSwitcher: some View {
        HStack(spacing: 0) {
            ForEach(NotchTab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(4)
        .glassStyle()
    }

    private func tabButton(for tab: NotchTab) -> some View {
        HStack(spacing: 6) {
            Image(systemName: tab.icon)
                .font(.system(size: 11, weight: .semibold))

            Text(tab.rawValue)
                .font(AppTheme.Typography.body())
        }
        .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.4))
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            ZStack {
                if selectedTab == tab {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.white.opacity(0.12))
                        .matchedGeometryEffect(id: "tab", in: tabNamespace)
                }
            }
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(AppTheme.Animations.spring) {
                selectedTab = tab
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NotchBarView()
        .frame(width: 400, height: 300)
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
}
