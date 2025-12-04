import SwiftUI

struct NotchBarView: View {
    @StateObject private var mediaManager = MediaPlayerManager()
    @StateObject private var notchState = NotchState.shared
    @State private var isHovering = false
    @State private var showContent = false
    @State private var glowIntensity: CGFloat = 0
    @State private var scaleProgress: CGFloat = 0.5
    @State private var closeTimer: Timer?
    @State private var selectedTab: NotchTab = .nook

    // Smooth animations
    private let glowAnimation = Animation.easeInOut(duration: 0.4)
    private let scaleAnimation = Animation.spring(response: 0.5, dampingFraction: 0.8)
    private let contentAnimation = Animation.spring(response: 0.4, dampingFraction: 0.85)

    enum NotchTab: String, CaseIterable {
        case nook = "Nook"
        case tray = "Tray"

        var icon: String {
            switch self {
            case .nook: return "arrow.up.forward"
            case .tray: return "archivebox"
            }
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Main notch container
                notchContainer
                    .onHover { hovering in
                        handleHover(hovering)
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    private func handleHover(_ hovering: Bool) {
        closeTimer?.invalidate()
        closeTimer = nil

        if hovering {
            // Phase 1: Show glow effect
            withAnimation(glowAnimation) {
                isHovering = true
                glowIntensity = 1
            }

            // Phase 2: Scale to 100% after 150ms
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(scaleAnimation) {
                    scaleProgress = 1.0
                }
            }

            // Phase 3: Show content after 350ms
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                withAnimation(contentAnimation) {
                    showContent = true
                    notchState.isExpanded = true
                }
            }
        } else {
            // Delay closing
            closeTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { _ in
                // Reverse animation
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
    }

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
        .background(
            ZStack {
                // Drop shadow gradient effect at bottom
                MacNotchShape(topCornerRadius: 0, bottomCornerRadius: showContent ? 16 : 12)
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

                // Main black notch shape
                MacNotchShape(topCornerRadius: 0, bottomCornerRadius: showContent ? 16 : 12)
                    .fill(Color.black)
            }
        )
        .overlay(
            // Gradient border - bottom and sides only
            MacNotchShape(topCornerRadius: 0, bottomCornerRadius: showContent ? 16 : 12)
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
        )
        .clipShape(MacNotchShape(topCornerRadius: 0, bottomCornerRadius: showContent ? 16 : 12))
        // Half visible when not hovering, full when hovering
        .offset(y: isHovering ? 0 : -22)
        .opacity(isHovering ? 1.0 : 0.5)
    }

    private var collapsedNotch: some View {
        HStack(spacing: 12) {
            // Only show content when media is playing
            if mediaManager.currentMedia.title != "No Media Playing" {
                // Album artwork
                Group {
                    if let artwork = mediaManager.currentMedia.artwork {
                        Image(nsImage: artwork)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 32, height: 32)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "music.note")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.5))
                            )
                    }
                }

                // Song info
                VStack(alignment: .leading, spacing: 2) {
                    Text(mediaManager.currentMedia.title)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text(mediaManager.currentMedia.artist)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                        .lineLimit(1)
                }
                .frame(maxWidth: 150, alignment: .leading)

                // Music bars when playing
                if mediaManager.currentMedia.isPlaying {
                    HStack(spacing: 2.5) {
                        ForEach(0..<3, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.cyan, Color.purple],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .frame(width: 3, height: animatedBarHeight(index: index))
                        }
                    }
                    .padding(.leading, 8)
                }
            }
        }
        .padding(.horizontal, mediaManager.currentMedia.title != "No Media Playing" ? 18 : 0)
        .padding(.vertical, 10)
        .frame(minWidth: 180, minHeight: 36)
    }

    private var expandedContent: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                // Tab Switcher
                HStack(spacing: 0) {
                    ForEach(NotchTab.allCases, id: \.self) { tab in
                        HStack(spacing: 6) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 11, weight: .semibold))
                            Text(tab.rawValue)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
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
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                selectedTab = tab
                            }
                        }
                    }
                }
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                        )
                )

                Spacer()

                // Settings
                Button(action: {}) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(10)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.06))
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                                )
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 14)

            // Content
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

    @Namespace private var tabNamespace

    private func animatedBarHeight(index: Int) -> CGFloat {
        let base: CGFloat = 6
        let maxHeight: CGFloat = 16
        if !mediaManager.currentMedia.isPlaying {
            return base
        }
        let offset = sin(Date().timeIntervalSinceReferenceDate * 3 + Double(index) * 0.8) * 0.5 + 0.5
        return base + (maxHeight - base) * offset
    }
}

// Custom MacBook-style notch shape with sharp top corners and rounded bottom corners
struct MacNotchShape: Shape {
    var topCornerRadius: CGFloat = 0
    var bottomCornerRadius: CGFloat = 16

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height
        let bottomRadius = bottomCornerRadius

        // Start from top-left (sharp corner)
        path.move(to: CGPoint(x: 0, y: 0))

        // Top edge (straight line, sharp corners)
        path.addLine(to: CGPoint(x: width, y: 0))

        // Right edge down to bottom corner
        path.addLine(to: CGPoint(x: width, y: height - bottomRadius))

        // Bottom-right corner (rounded)
        path.addArc(
            center: CGPoint(x: width - bottomRadius, y: height - bottomRadius),
            radius: bottomRadius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )

        // Bottom edge
        path.addLine(to: CGPoint(x: bottomRadius, y: height))

        // Bottom-left corner (rounded)
        path.addArc(
            center: CGPoint(x: bottomRadius, y: height - bottomRadius),
            radius: bottomRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )

        // Left edge up to top (sharp corner)
        path.addLine(to: CGPoint(x: 0, y: 0))

        path.closeSubpath()

        return path
    }
}

// Legacy shape for backwards compatibility
struct NotchShape: Shape {
    func path(in rect: CGRect) -> Path {
        return MacNotchShape(topCornerRadius: 6, bottomCornerRadius: 16).path(in: rect)
    }
}

struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

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
