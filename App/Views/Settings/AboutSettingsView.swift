import SwiftUI

// MARK: - About Settings View
/// App information, version, and credits - Modern glassmorphism design

struct AboutSettingsView: View {

    // MARK: - Properties
    @StateObject private var settings = SettingsManager.shared
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    @State private var iconScale: CGFloat = 1.0
    @State private var iconRotation: Double = 0

    // MARK: - Body
    var body: some View {
        VStack(spacing: 24) {
            // App Icon and Info Card
            appInfoCard
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        iconScale = 1.0
                    }
                }

            // Description
            descriptionSection

            // Links Section
            linksSection

            Spacer()

            // Footer
            footerSection
        }
    }

    // MARK: - App Info Card
    private var appInfoCard: some View {
        VStack(spacing: 20) {
            // App Icon with Glow
            ZStack {
                // Animated Glow
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.accentColor.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .blur(radius: 16)
                    .scaleEffect(iconScale * 1.05)

                // Main icon
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.accentColor)
                    .frame(width: 72, height: 72)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color.accentColor.opacity(0.4), radius: 8, y: 4)
                    .scaleEffect(iconScale)

                // Icon symbol
                Image(systemName: "rectangle.inset.topright.filled")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                    .shadow(color: .black.opacity(0.1), radius: 1, y: 1)
                    .rotationEffect(.degrees(iconRotation))
            }
            .onAppear {
                iconScale = 0.8
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                    iconScale = 1.0
                }
            }

            // App Name and Version
            VStack(spacing: 8) {
                Text("NotchApp")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                HStack(spacing: 6) {
                    Text("Version \(appVersion)")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)

                    Text("•")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary.opacity(0.5))

                    Text("Build \(buildNumber)")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                        )
                )
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
                .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
        )
    }

    // MARK: - Description Section
    private var descriptionSection: some View {
        Text("A beautiful companion app for your MacBook notch.\nControl media, access quick actions, and more.")
            .font(.system(size: 12, weight: .regular, design: .rounded))
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .lineSpacing(3)
            .padding(.horizontal, 12)
    }

    // MARK: - Links Section
    private var linksSection: some View {
        VStack(spacing: 10) {
            AboutLinkRow(
                icon: "globe",
                title: "Website",
                subtitle: "Visit our website",
                color: .blue
            ) {
                openURL("https://github.com")
            }

            AboutLinkRow(
                icon: "star.fill",
                title: "Rate on App Store",
                subtitle: "Share your feedback",
                color: .yellow
            ) {
                // Open App Store
            }

            AboutLinkRow(
                icon: "envelope.fill",
                title: "Contact Support",
                subtitle: "Get help with issues",
                color: .green
            ) {
                openURL("mailto:support@notchapp.com")
            }

            AboutLinkRow(
                icon: "lock.shield.fill",
                title: "Privacy Policy",
                subtitle: "Read our privacy policy",
                color: .purple
            ) {
                openURL("https://github.com")
            }
        }
    }

    // MARK: - Footer Section
    private var footerSection: some View {
        VStack(spacing: 16) {
            // Credits
            VStack(spacing: 6) {
                Text("Made with")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary.opacity(0.8))
                + Text(" ❤️ ")
                    .font(.system(size: 14))
                + Text("for macOS")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary.opacity(0.8))

                Text("© 2024 NotchApp. All rights reserved.")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary.opacity(0.6))
            }

            // Social Links
            HStack(spacing: 12) {
                SocialButton(
                    icon: "link",
                    name: "GitHub",
                    accentColor: .purple
                ) {
                    openURL("https://github.com")
                }

                SocialButton(
                    icon: "at",
                    name: "Twitter",
                    accentColor: .blue
                ) {
                    openURL("https://twitter.com")
                }
            }
        }
    }

    // MARK: - Methods
    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - About Link Row
struct AboutLinkRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    @State private var isHovering = false
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
            action()
        }) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(color.opacity(isHovering ? 0.16 : 0.12))
                        .frame(width: 38, height: 38)

                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(color)
                        .symbolEffect(.bounce, value: isHovering)
                }

                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        isHovering
                            ? Color.primary.opacity(0.06)
                            : Color.primary.opacity(0.03)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(
                                isHovering
                                    ? Color.primary.opacity(0.12)
                                    : Color.primary.opacity(0.06),
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(isPressed ? 0.97 : (isHovering ? 1.01 : 1.0))
            .shadow(
                color: isHovering ? .black.opacity(0.08) : .black.opacity(0.02),
                radius: isHovering ? 8 : 4,
                y: isHovering ? 3 : 1
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - Social Button
struct SocialButton: View {
    let icon: String
    let name: String
    let accentColor: Color
    let action: () -> Void

    @State private var isHovering = false
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
            action()
        }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .medium))

                Text(name)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
            }
            .foregroundColor(isHovering ? accentColor : .secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(
                                isHovering
                                    ? accentColor.opacity(0.4)
                                    : Color.secondary.opacity(0.15),
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(isPressed ? 0.95 : (isHovering ? 1.03 : 1.0))
            .shadow(
                color: isHovering ? accentColor.opacity(0.2) : .clear,
                radius: 8,
                y: 3
            )
            .shadow(
                color: isHovering ? accentColor.opacity(0.1) : .clear,
                radius: 4,
                y: 1
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - Preview
#Preview {
    AboutSettingsView()
        .padding()
        .frame(width: 480, height: 520)
        .background(Color(NSColor.windowBackgroundColor))
        .preferredColorScheme(.dark)
}
