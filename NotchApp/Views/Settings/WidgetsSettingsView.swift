import SwiftUI

// MARK: - Widgets Settings View
/// Configure which widgets are shown in the notch

struct WidgetsSettingsView: View {

    // MARK: - Properties
    @ObservedObject var settings: SettingsManager
    @State private var widgetOrder: [WidgetItem] = WidgetItem.allCases

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Available Widgets Section
            SettingsSection(title: "Available Widgets", icon: "square.grid.2x2.fill") {
                VStack(spacing: 4) {
                    WidgetToggleRow(
                        widget: .mediaPlayer,
                        isEnabled: $settings.showMediaPlayer,
                        accentColor: settings.accentColor.color
                    )

                    SettingsDivider()

                    WidgetToggleRow(
                        widget: .shortcuts,
                        isEnabled: $settings.showShortcuts,
                        accentColor: settings.accentColor.color
                    )

                    SettingsDivider()

                    WidgetToggleRow(
                        widget: .calendar,
                        isEnabled: .constant(false),
                        accentColor: settings.accentColor.color,
                        isComingSoon: true
                    )

                    SettingsDivider()

                    WidgetToggleRow(
                        widget: .weather,
                        isEnabled: .constant(false),
                        accentColor: settings.accentColor.color,
                        isComingSoon: true
                    )

                    SettingsDivider()

                    WidgetToggleRow(
                        widget: .notes,
                        isEnabled: .constant(false),
                        accentColor: settings.accentColor.color,
                        isComingSoon: true
                    )
                }
            }

            // Widget Layout Section
            SettingsSection(title: "Layout", icon: "rectangle.3.group.fill") {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Drag to reorder widgets (coming soon)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary.opacity(0.8))

                    VStack(spacing: 10) {
                        ForEach(widgetOrder) { widget in
                            HStack(spacing: 12) {
                                Image(systemName: "line.3.horizontal")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary.opacity(0.6))

                                ZStack {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [widget.color.opacity(0.25), widget.color.opacity(0.15)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 28, height: 28)

                                    Image(systemName: widget.icon)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(widget.color)
                                }

                                Text(widget.title)
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))

                                Spacer()

                                Text(widget.subtitle)
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary.opacity(0.7))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color.secondary.opacity(0.1))
                                    )
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(.ultraThinMaterial)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                            )
                        }
                    }
                }
            }

            Spacer(minLength: 20)
        }
    }
}

// MARK: - Widget Item
enum WidgetItem: String, CaseIterable, Identifiable {
    case mediaPlayer
    case shortcuts
    case calendar
    case weather
    case notes

    var id: String { rawValue }

    var title: String {
        switch self {
        case .mediaPlayer: return "Media Player"
        case .shortcuts: return "Shortcuts"
        case .calendar: return "Calendar"
        case .weather: return "Weather"
        case .notes: return "Notes"
        }
    }

    var subtitle: String {
        switch self {
        case .mediaPlayer: return "4 cells"
        case .shortcuts: return "2 cells"
        case .calendar: return "2 cells"
        case .weather: return "1 cell"
        case .notes: return "2 cells"
        }
    }

    var icon: String {
        switch self {
        case .mediaPlayer: return "music.note"
        case .shortcuts: return "command.square.fill"
        case .calendar: return "calendar"
        case .weather: return "cloud.sun.fill"
        case .notes: return "note.text"
        }
    }

    var color: Color {
        switch self {
        case .mediaPlayer: return .pink
        case .shortcuts: return .blue
        case .calendar: return .red
        case .weather: return .cyan
        case .notes: return .yellow
        }
    }
}

// MARK: - Widget Toggle Row
struct WidgetToggleRow: View {
    let widget: WidgetItem
    @Binding var isEnabled: Bool
    let accentColor: Color
    var isComingSoon: Bool = false

    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 14) {
            // Widget Icon
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [widget.color.opacity(0.25), widget.color.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)

                Image(systemName: widget.icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(widget.color)
            }

            // Widget Info
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text(widget.title)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))

                    if isComingSoon {
                        Text("Coming Soon")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [.orange, .orange.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                    }
                }

                Text(widget.subtitle)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary.opacity(0.8))
            }

            Spacer()

            // Toggle
            Toggle("", isOn: $isEnabled)
                .toggleStyle(SwitchToggleStyle(tint: accentColor))
                .labelsHidden()
                .scaleEffect(0.9)
                .disabled(isComingSoon)
                .opacity(isComingSoon ? 0.5 : 1)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isHovering ? Color.primary.opacity(0.04) : Color.clear)
        )
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - Preview
#Preview {
    WidgetsSettingsView(settings: SettingsManager.shared)
        .padding()
        .frame(width: 480, height: 600)
        .background(Color(NSColor.windowBackgroundColor))
        .preferredColorScheme(.dark)
}
