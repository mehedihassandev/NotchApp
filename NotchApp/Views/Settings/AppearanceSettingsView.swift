import SwiftUI

// MARK: - Appearance Settings View
/// Theme and visual customization settings

struct AppearanceSettingsView: View {

    // MARK: - Properties
    @ObservedObject var settings: SettingsManager

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Accent Color Section
            SettingsSection(title: "Accent Color", icon: "paintpalette.fill") {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Choose your accent color")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary.opacity(0.8))

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 5), spacing: 14) {
                        ForEach(AccentColorOption.allCases) { color in
                            colorButton(for: color)
                        }
                    }
                }
            }

            // Notch Size Section
            SettingsSection(title: "Notch Size", icon: "arrow.up.left.and.arrow.down.right") {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Adjust the size of the expanded notch")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary.opacity(0.8))

                    HStack(spacing: 12) {
                        ForEach(NotchSizeOption.allCases) { size in
                            sizeButton(for: size)
                        }
                    }
                }
            }

            // Visual Effects Section
            SettingsSection(title: "Visual Effects", icon: "sparkles.rectangle.stack.fill") {
                VStack(spacing: 4) {
                    SettingsToggleRow(
                        title: "Glow Effect",
                        subtitle: "Show glow effect on hover",
                        icon: "light.max",
                        iconColor: settings.accentColor.color,
                        isOn: $settings.enableGlowEffect
                    )

                    if settings.enableGlowEffect {
                        SettingsDivider()

                        SettingsSliderRow(
                            title: "Glow Intensity",
                            subtitle: "Brightness of the glow effect",
                            value: $settings.glowIntensity,
                            range: 0.2...1.0,
                            unit: ""
                        )
                    }

                    SettingsDivider()

                    SettingsToggleRow(
                        title: "Blur Effect",
                        subtitle: "Enable background blur",
                        icon: "aqi.medium",
                        iconColor: .cyan,
                        isOn: $settings.enableBlur
                    )
                }
            }

            // Corner Radius Section
            SettingsSection(title: "Corner Radius", icon: "square.on.square") {
                VStack(spacing: 16) {
                    SettingsSliderRow(
                        title: "Corner Roundness",
                        subtitle: "Adjust the corner radius of elements",
                        value: $settings.cornerRadius,
                        range: 8...24,
                        unit: "px"
                    )

                    // Preview
                    HStack {
                        Spacer()

                        ZStack {
                            RoundedRectangle(cornerRadius: settings.cornerRadius, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            settings.accentColor.color.opacity(0.4),
                                            settings.accentColor.color.opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 60)

                            RoundedRectangle(cornerRadius: settings.cornerRadius, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            settings.accentColor.color,
                                            settings.accentColor.color.opacity(0.5)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                                .frame(width: 100, height: 60)
                        }
                        .shadow(color: settings.accentColor.color.opacity(0.3), radius: 10, y: 4)

                        Spacer()
                    }
                }
            }

            Spacer(minLength: 20)
        }
    }

    // MARK: - Color Button
    private func colorButton(for color: AccentColorOption) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                settings.accentColor = color
            }
        }) {
            ZStack {
                // Outer ring for selection
                Circle()
                    .stroke(
                        settings.accentColor == color ? Color.white.opacity(0.8) : Color.clear,
                        lineWidth: 2.5
                    )
                    .frame(width: 44, height: 44)

                // Color circle with gradient
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.color, color.color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)
                    .shadow(color: color.color.opacity(0.5), radius: settings.accentColor == color ? 8 : 0, y: 2)

                if settings.accentColor == color {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                }
            }
            .frame(width: 48, height: 48)
            .scaleEffect(settings.accentColor == color ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Size Button
    private func sizeButton(for size: NotchSizeOption) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                settings.notchSize = size
            }
        }) {
            VStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(
                        settings.notchSize == size ?
                        LinearGradient(
                            colors: [settings.accentColor.color, settings.accentColor.color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.secondary.opacity(0.3), Color.secondary.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40 * size.scaleFactor, height: 24 * size.scaleFactor)

                Text(size.displayName)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(settings.notchSize == size ? settings.accentColor.color : .secondary)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(settings.notchSize == size ? settings.accentColor.color.opacity(0.12) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        settings.notchSize == size ?
                        settings.accentColor.color.opacity(0.4) :
                        Color.secondary.opacity(0.15),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    AppearanceSettingsView(settings: SettingsManager.shared)
        .padding()
        .frame(width: 480, height: 600)
        .background(Color(NSColor.windowBackgroundColor))
        .preferredColorScheme(.dark)
}
