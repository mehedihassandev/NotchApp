import SwiftUI

// MARK: - Shortcuts Settings View
/// Configure keyboard shortcuts

struct ShortcutsSettingsView: View {

    // MARK: - Properties
    @ObservedObject var settings: SettingsManager

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Global Shortcuts Section
            SettingsSection(title: "Global Shortcuts", icon: "command") {
                VStack(spacing: 4) {
                    ShortcutRow(
                        title: "Toggle Notch",
                        subtitle: "Show or hide the notch panel",
                        shortcut: "⌘ + ⌥ + N",
                        accentColor: settings.accentColor.color
                    )

                    SettingsDivider()

                    ShortcutRow(
                        title: "Play/Pause Media",
                        subtitle: "Toggle media playback",
                        shortcut: "⌘ + ⌥ + Space",
                        accentColor: settings.accentColor.color
                    )

                    SettingsDivider()

                    ShortcutRow(
                        title: "Next Track",
                        subtitle: "Skip to next track",
                        shortcut: "⌘ + ⌥ + →",
                        accentColor: settings.accentColor.color
                    )

                    SettingsDivider()

                    ShortcutRow(
                        title: "Previous Track",
                        subtitle: "Go to previous track",
                        shortcut: "⌘ + ⌥ + ←",
                        accentColor: settings.accentColor.color
                    )

                    SettingsDivider()

                    ShortcutRow(
                        title: "Open Settings",
                        subtitle: "Open the settings panel",
                        shortcut: "⌘ + ,",
                        accentColor: settings.accentColor.color
                    )
                }
            }

            // Quick Actions Section
            SettingsSection(title: "Quick Actions", icon: "bolt.fill") {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Configure custom shortcuts for quick actions")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary.opacity(0.8))

                    // Placeholder for custom shortcuts
                    Button(action: {}) {
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(settings.accentColor.color.opacity(0.15))
                                    .frame(width: 28, height: 28)

                                Image(systemName: "plus")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(settings.accentColor.color)
                            }

                            Text("Add Custom Shortcut")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(settings.accentColor.color)

                            Spacer()
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(settings.accentColor.color.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            // Info Section
            SettingsSection(title: "Tips", icon: "lightbulb.fill") {
                VStack(alignment: .leading, spacing: 12) {
                    TipRow(
                        icon: "hand.tap.fill",
                        text: "Hover over the notch area to expand it",
                        color: .blue
                    )

                    TipRow(
                        icon: "arrow.down.doc.fill",
                        text: "Drag files to the notch to use the file tray",
                        color: .green
                    )

                    TipRow(
                        icon: "hand.draw.fill",
                        text: "Scroll on the notch to switch tabs",
                        color: .orange
                    )
                }
            }

            Spacer(minLength: 20)
        }
    }
}

// MARK: - Shortcut Row
struct ShortcutRow: View {
    let title: String
    let subtitle: String
    let shortcut: String
    let accentColor: Color

    @State private var isHovering = false
    @State private var isEditing = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))

                Text(subtitle)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary.opacity(0.8))
            }

            Spacer()

            // Shortcut Badge
            Button(action: { isEditing.toggle() }) {
                Text(shortcut)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(isHovering ? accentColor : .secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(isHovering ? accentColor.opacity(0.1) : Color.secondary.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(isHovering ? accentColor.opacity(0.4) : Color.clear, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.15)) {
                    isHovering = hovering
                }
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isHovering ? Color.primary.opacity(0.03) : Color.clear)
        )
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - Tip Row
struct TipRow: View {
    let icon: String
    let text: String
    var color: Color = .secondary

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 26, height: 26)

                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(color)
            }

            Text(text)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary.opacity(0.9))
        }
    }
}

// MARK: - Preview
#Preview {
    ShortcutsSettingsView(settings: SettingsManager.shared)
        .padding()
        .frame(width: 480, height: 600)
        .background(Color(NSColor.windowBackgroundColor))
        .preferredColorScheme(.dark)
}
