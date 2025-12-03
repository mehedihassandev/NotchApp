import SwiftUI

struct NotchBarView: View {
    @StateObject private var mediaManager = MediaPlayerManager()
    @StateObject private var notchState = NotchState.shared
    @State private var isExpanded = false
    @State private var isHovering = false
    @State private var expandProgress: CGFloat = 0
    @State private var closeTimer: Timer?
    @State private var selectedTab: NotchTab = .nook

    // NotchNook-style smooth animations
    private let expandAnimation = Animation.spring(response: 0.6, dampingFraction: 0.75, blendDuration: 0.3)
    private let hoverAnimation = Animation.spring(response: 0.3, dampingFraction: 0.7)

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
                // Invisible hover trigger at the very top
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .onHover { hovering in
                        handleHover(hovering)
                    }
                    .zIndex(10)

                // Expanded content with slide-down animation
                if isExpanded {
                    expandedContent
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                        .zIndex(1)
                } else {
                    // Collapsed notch integrated into the "notch" area
                    collapsedNotch
                        .transition(.opacity)
                        .zIndex(2)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(
                isExpanded ? Color.black.opacity(0.3).edgesIgnoringSafeArea(.all) : Color.clear.edgesIgnoringSafeArea(.all)
            )
        }
    }

    private func handleHover(_ hovering: Bool) {
        // Cancel any pending close timer
        closeTimer?.invalidate()
        closeTimer = nil

        if hovering {
            // Immediately expand on hover
            withAnimation(expandAnimation) {
                isHovering = true
                isExpanded = true
                expandProgress = 1
                notchState.isExpanded = true
            }
        } else {
            // Delay closing by 1 second after mouse leaves
            closeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                withAnimation(expandAnimation) {
                    isHovering = false
                    isExpanded = false
                    expandProgress = 0
                    notchState.isExpanded = false
                }
            }
        }
    }

    private var collapsedNotch: some View {
        HStack(spacing: 0) {
            // Seamless notch-like appearance with dynamic width
            HStack(spacing: 8) {
                // Album artwork thumbnail (only when media is playing)
                if mediaManager.currentMedia.title != "No Media Playing" {
                    Group {
                        if let artwork = mediaManager.currentMedia.artwork {
                            Image(nsImage: artwork)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 24, height: 24)
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                                )
                        } else {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Image(systemName: "music.note")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.white.opacity(0.5))
                                )
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                VStack(alignment: .leading, spacing: 2) {
                    // Song title
                    if mediaManager.currentMedia.title != "No Media Playing" {
                        Text(mediaManager.currentMedia.title)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(1)
                            .frame(maxWidth: notchWidth - 80)

                        Text(mediaManager.currentMedia.artist)
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                            .lineLimit(1)
                            .frame(maxWidth: notchWidth - 80)
                    } else {
                        // When no music is playing
                        HStack(spacing: 4) {
                            Image(systemName: "music.note")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white.opacity(0.5))
                            Text("No Media")
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }

                Spacer()

                // Music indicator (animated bars when playing)
                if mediaManager.currentMedia.isPlaying {
                    HStack(spacing: 2.5) {
                        ForEach(0..<3) { index in
                            RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                                .fill(Color.green.opacity(0.8))
                                .frame(width: 2.5, height: animatedBarHeight(index: index))
                                .animation(
                                    Animation.easeInOut(duration: 0.5)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.15),
                                    value: mediaManager.currentMedia.isPlaying
                                )
                        }
                    }
                    .padding(.trailing, 4)
                }
            }
            .padding(.horizontal, 10)
            .frame(width: notchWidth, height: 32)
            .background(
                VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                    .clipShape(NotchShape())
            )
            .scaleEffect(isHovering ? 1.01 : 1.0)
            .animation(hoverAnimation, value: isHovering)
        }
        .frame(height: 32)
    }

    // Dynamic notch width based on content
    private var notchWidth: CGFloat {
        if mediaManager.currentMedia.title != "No Media Playing" {
            return 280
        }
        return 150
    }

    private var expandedContent: some View {
        VStack(spacing: 0) {
            // Top notch connector for seamless integration
            VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                .frame(height: 32)
                .clipShape(NotchShape())

            VStack {
                // Tab Switcher (Nook / Tray)
                HStack(spacing: 0) {
                    ForEach(NotchTab.allCases, id: \.self) { tab in
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                selectedTab = tab
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: tab.icon)
                                    .font(.system(size: 13, weight: .semibold))
                                Text(tab.rawValue)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.5))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                ZStack {
                                    if selectedTab == tab {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(Color.white.opacity(0.15))
                                            .matchedGeometryEffect(id: "tab", in: tabNamespace)
                                    }
                                }
                            )
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.black.opacity(0.25))
                )
                .padding(.horizontal, 20)
                .padding(.top, -10)

                // Main content card
                Group {
                    switch selectedTab {
                    case .nook:
                        DashboardView(mediaManager: mediaManager)
                    case .tray:
                        TrayView()
                    }
                }
                .padding(.top, 10)
            }
            .padding(12)
            .background(
                VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            )
            .padding(.horizontal, 12)
        }
        .offset(y: isExpanded ? 0 : -100)
        .opacity(isExpanded ? 1 : 0)
    }

    @Namespace private var tabNamespace

    private func animatedBarHeight(index: Int) -> CGFloat {
        if !mediaManager.currentMedia.isPlaying {
            return 4
        }
        let base: CGFloat = 4
        let max: CGFloat = 12
        let offset = sin(Date().timeIntervalSinceReferenceDate * 2 + Double(index) * 0.5) * 0.5 + 0.5
        return base + (max - base) * offset
    }
}

// Custom notch shape for seamless MacBook notch integration
struct NotchShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height
        let cornerRadius: CGFloat = 16

        // Start from top-left
        path.move(to: CGPoint(x: 0, y: 0))

        // Top edge to right corner
        path.addLine(to: CGPoint(x: width, y: 0))

        // Right edge down
        path.addLine(to: CGPoint(x: width, y: height - cornerRadius))

        // Bottom-right corner
        path.addQuadCurve(
            to: CGPoint(x: width - cornerRadius, y: height),
            control: CGPoint(x: width, y: height)
        )

        // Bottom edge
        path.addLine(to: CGPoint(x: cornerRadius, y: height))

        // Bottom-left corner
        path.addQuadCurve(
            to: CGPoint(x: 0, y: height - cornerRadius),
            control: CGPoint(x: 0, y: height)
        )

        // Left edge back to start
        path.addLine(to: CGPoint(x: 0, y: 0))

        return path
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
