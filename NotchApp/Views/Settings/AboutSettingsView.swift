import SwiftUI

// MARK: - About Settings View
/// App information, version, and credits

struct AboutSettingsView: View {

    // MARK: - Properties
    @StateObject private var settings = SettingsManager.shared
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    // MARK: - Body
    var body: some View {
        VStack(spacing: 28) {
            // App Icon and Name
            VStack(spacing: 16) {
                ZStack {
                    // Glow effect
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [settings.accentColor.color, .blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 88, height: 88)
                        .blur(radius: 20)
                        .opacity(0.5)

                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [settings.accentColor.color, .blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )

                    Image(systemName: "rectangle.inset.topright.filled")
                        .font(.system(size: 38, weight: .semibold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                }

                VStack(spacing: 6) {
                    Text("NotchApp")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.primary, .primary.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("Version \(appVersion) (\(buildNumber))")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary.opacity(0.8))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.secondary.opacity(0.1))
                        )
                }
            }
            .padding(.top, 10)

            // Description
            Text("A beautiful companion app for your MacBook notch.\nControl media, access quick actions, and more.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.secondary.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineSpacing(5)

            // Links Section
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
                    color: settings.accentColor.color
                ) {
                    openURL("https://github.com")
                }
            }

            Spacer(minLength: 10)

            // Credits
            VStack(spacing: 10) {
                Text("Made with ❤️ for macOS")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)

                Text("© 2024 NotchApp. All rights reserved.")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary.opacity(0.6))
            }

            // Social Links
            HStack(spacing: 14) {
                SocialButton(icon: "link", name: "GitHub", accentColor: settings.accentColor.color) {
                    openURL("https://github.com")
                }

                SocialButton(icon: "at", name: "Twitter", accentColor: settings.accentColor.color) {
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

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.25), color.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)

                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(color)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary.opacity(0.8))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isHovering ? Color.primary.opacity(0.06) : Color.primary.opacity(0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.primary.opacity(isHovering ? 0.1 : 0.05), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
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

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))

                Text(name)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
            .foregroundColor(isHovering ? accentColor : .secondary)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                Capsule()
                    .stroke(isHovering ? accentColor.opacity(0.3) : Color.secondary.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - Preview
#Preview {
    AboutSettingsView()
        .padding()
        .frame(width: 480, height: 600)
        .background(Color(NSColor.windowBackgroundColor))
        .preferredColorScheme(.dark)
}
