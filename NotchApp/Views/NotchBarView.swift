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
    @State private var isMouseInside = false

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
        .onChange(of: notchState.shouldShowTray) { _, shouldShow in
            if shouldShow {
                handleFileDrag()
            }
        }
        .onChange(of: notchState.isDraggingFile) { _, isDragging in
            if !isDragging && !isMouseInside {
                // File drag ended outside the notch, collapse after delay
                scheduleCollapse()
            }
        }
    }
}

// MARK: - Hover Handling
extension NotchBarView {

    private func handleHover(_ hovering: Bool) {
        isMouseInside = hovering
        closeTimer?.invalidate()
        closeTimer = nil

        if hovering {
            expandNotch()
        } else {
            // Don't collapse if dragging file
            if !notchState.isDraggingFile {
                scheduleCollapse()
            }
        }
    }

    private func handleFileDrag() {
        closeTimer?.invalidate()
        closeTimer = nil

        // Switch to Tray tab
        withAnimation(AppTheme.Animations.spring) {
            selectedTab = .tray
        }

        // Expand the notch if not already expanded
        if !showContent {
            expandNotch()
        }

        // Reset the trigger
        notchState.resetTrayTrigger()
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
        closeTimer?.invalidate()
        closeTimer = Timer.scheduledTimer(
            withTimeInterval: AppConstants.Animation.closeDelay,
            repeats: false
        ) { [self] _ in
            // Double-check mouse is still outside before collapsing
            if !isMouseInside && !notchState.isDraggingFile {
                collapseNotch()
            }
        }
    }

    private func collapseNotch() {
        // Cancel if mouse came back or file is being dragged
        guard !isMouseInside && !notchState.isDraggingFile else { return }

        // Smooth reverse animation sequence
        withAnimation(.easeOut(duration: 0.25)) {
            showContent = false
            notchState.isExpanded = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            guard !self.isMouseInside else { return }
            withAnimation(.easeOut(duration: 0.3)) {
                scaleProgress = 0.5
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            guard !self.isMouseInside else { return }
            withAnimation(.easeOut(duration: 0.35)) {
                isHovering = false
                glowIntensity = 0
            }
            // Keep selectedTab as-is so it remembers last tab
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
        .contentShape(NotchShape(topCornerRadius: 0, bottomCornerRadius: showContent ? 16 : 12))
        .offset(y: (isHovering || notchState.isDraggingFile) ? 0 : AppConstants.Window.collapsedOffset)
        .opacity((isHovering || notchState.isDraggingFile) ? 1.0 : 0.5)
        .animation(.easeInOut(duration: 0.3), value: isHovering)
        .animation(.easeInOut(duration: 0.3), value: notchState.isDraggingFile)
    }

    private var notchBackground: some View {
        ZStack {
            // Outer glow shadow effect - more diffused and spread out
            NotchShape(topCornerRadius: 0, bottomCornerRadius: showContent ? 16 : 12)
                .fill(
                    notchState.isDraggingFile ?
                    LinearGradient(
                        colors: [
                            AppTheme.Colors.accentBlue.opacity(0.5),
                            Color.cyan.opacity(0.4),
                            AppTheme.Colors.accentBlue.opacity(0.5)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ) :
                    LinearGradient(
                        colors: [
                            Color.purple.opacity(0.4 * glowIntensity),
                            Color.blue.opacity(0.5 * glowIntensity),
                            Color.indigo.opacity(0.4 * glowIntensity)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .blur(radius: notchState.isDraggingFile ? 40 : 35 * glowIntensity)
                .offset(y: notchState.isDraggingFile ? 20 : 18 * glowIntensity)
                .scaleEffect(x: 0.9, y: 1.3)
                .animation(AppTheme.Animations.spring, value: notchState.isDraggingFile)

            // Inner glow effect - more intense and closer
            NotchShape(topCornerRadius: 0, bottomCornerRadius: showContent ? 16 : 12)
                .fill(
                    notchState.isDraggingFile ?
                    LinearGradient(
                        colors: [
                            AppTheme.Colors.accentBlue.opacity(0.7),
                            Color.cyan.opacity(0.5),
                            AppTheme.Colors.accentBlue.opacity(0.6)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ) :
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
                .blur(radius: notchState.isDraggingFile ? 20 : 15 * glowIntensity)
                .offset(y: notchState.isDraggingFile ? 10 : 8 * glowIntensity)
                .scaleEffect(x: 0.95, y: 1.1)
                .animation(AppTheme.Animations.spring, value: notchState.isDraggingFile)

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
            // Show file drop indicator when dragging files
            if notchState.isDraggingFile {
                collapsedDropIndicator
            } else if mediaManager.currentMedia.hasContent {
                // Only show content when media is playing
                collapsedMediaContent
            }
        }
        .padding(.horizontal, (mediaManager.currentMedia.hasContent || notchState.isDraggingFile) ? 18 : 0)
        .padding(.vertical, 10)
        .frame(minWidth: 180, minHeight: 36)
    }

    private var collapsedDropIndicator: some View {
        HStack(spacing: 8) {
            Image(systemName: "tray.and.arrow.down.fill")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.Colors.accentBlue)
                .symbolEffect(.bounce, options: .repeating, value: notchState.isDraggingFile)

            Text("Drop Files")
                .font(AppTheme.Typography.body())
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
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
                SettingsWindowOpener.open()
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
