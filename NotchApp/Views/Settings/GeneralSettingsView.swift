import SwiftUI

// MARK: - General Settings View
/// General app settings like launch at login, haptics, animations

struct GeneralSettingsView: View {

    // MARK: - Properties
    @ObservedObject var settings: SettingsManager

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Behavior Section
            SettingsSection(title: "Behavior", icon: "slider.horizontal.3") {
                VStack(spacing: 4) {
                    SettingsToggleRow(
                        title: "Launch at Login",
                        subtitle: "Start NotchApp when you log in",
                        icon: "power.circle.fill",
                        iconColor: .green,
                        isOn: $settings.launchAtLogin
                    )

                    SettingsDivider()

                    SettingsToggleRow(
                        title: "Show in Menu Bar",
                        subtitle: "Display a menu bar icon",
                        icon: "menubar.rectangle",
                        iconColor: .blue,
                        isOn: $settings.showInMenuBar
                    )
                }
            }

            // Feedback Section
            SettingsSection(title: "Feedback", icon: "hand.tap.fill") {
                VStack(spacing: 4) {
                    SettingsToggleRow(
                        title: "Haptic Feedback",
                        subtitle: "Vibration feedback on interactions",
                        icon: "waveform",
                        iconColor: .purple,
                        isOn: $settings.enableHaptics
                    )

                    SettingsDivider()

                    SettingsToggleRow(
                        title: "Sound Effects",
                        subtitle: "Play sounds on actions",
                        icon: "speaker.wave.2.fill",
                        iconColor: .orange,
                        isOn: $settings.enableSoundEffects
                    )

                    SettingsDivider()

                    SettingsToggleRow(
                        title: "Animations",
                        subtitle: "Enable smooth animations",
                        icon: "sparkles",
                        iconColor: .yellow,
                        isOn: $settings.enableAnimations
                    )
                }
            }

            // Timing Section
            SettingsSection(title: "Timing", icon: "clock.fill") {
                SettingsSliderRow(
                    title: "Auto-hide Delay",
                    subtitle: "Time before notch collapses",
                    value: $settings.autoHideDelay,
                    range: 0.2...2.0,
                    unit: "s"
                )
            }

            Spacer(minLength: 20)

            // Reset Button
            HStack {
                Spacer()

                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        settings.resetToDefaults()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Reset to Defaults")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                Spacer()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    GeneralSettingsView(settings: SettingsManager.shared)
        .padding()
        .frame(width: 480, height: 500)
        .background(Color(NSColor.windowBackgroundColor))
        .preferredColorScheme(.dark)
}
