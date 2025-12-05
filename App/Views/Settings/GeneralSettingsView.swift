import SwiftUI

// MARK: - General Settings View
/// General app settings like launch at login, haptics, animations - Modern glassmorphism design

struct GeneralSettingsView: View {

    // MARK: - Properties
    @ObservedObject var settings: SettingsManager
    @State private var isHoveringReset = false
    @State private var expandedSetting: String? = nil

    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {
            // Notch Customization Section
            notchCustomizationSection

            Spacer()

            // Reset Button
            resetButton
        }
    }

    // MARK: - Notch Customization Section
    private var notchCustomizationSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section Header
            sectionHeader(
                icon: "rectangle.topthird.inset.filled",
                title: "Notch Customization",
                iconColor: .primary
            )
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)

            // Divider
            Divider()
                .background(Color.primary.opacity(0.1))
                .padding(.horizontal, 20)

            // Settings Content
            VStack(spacing: 16) {
                // Enable Notch Toggle
                settingToggle(
                    icon: "switch.2",
                    title: "Enable Notch",
                    subtitle: "Show the notch interface",
                    binding: $settings.enableNotch,
                    settingID: "enableNotch"
                )

                // Notch Size Picker
                settingWithPicker(
                    icon: "ruler",
                    title: "Notch Size",
                    subtitle: "Adjust the notch dimensions",
                    settingID: "notchSize"
                )

                // Glow Effect Toggle
                settingToggle(
                    icon: "sparkles",
                    title: "Glow Effect",
                    subtitle: "Add ambient lighting",
                    binding: $settings.enableGlowEffect,
                    settingID: "glowEffect"
                )

                // Glow Intensity Slider
                if settings.enableGlowEffect {
                    settingWithSlider(
                        icon: "light.max",
                        title: "Glow Intensity",
                        subtitle: "Control glow brightness",
                        value: $settings.glowIntensity,
                        range: 0.0...1.0,
                        settingID: "glowIntensity"
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95).combined(with: .move(edge: .top))),
                        removal: .opacity.combined(with: .scale(scale: 0.95).combined(with: .move(edge: .top)))
                    ))
                }

                // Corner Radius Slider
                settingWithSlider(
                    icon: "circle.circle",
                    title: "Corner Radius",
                    subtitle: "Round the corners",
                    value: $settings.cornerRadius,
                    range: 0.0...30.0,
                    settingID: "cornerRadius"
                )

                // Blur Effect Toggle
                settingToggle(
                    icon: "aqi.medium",
                    title: "Blur Effect",
                    subtitle: "Apply background blur",
                    binding: $settings.enableBlur,
                    settingID: "blurEffect"
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 12, y: 4)
        )
    }

    // MARK: - Section Header
    private func sectionHeader(icon: String, title: String, iconColor: Color) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(iconColor)
            }

            Text(title)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
        }
    }

    // MARK: - Setting Toggle
    private func settingToggle(
        icon: String,
        title: String,
        subtitle: String,
        binding: Binding<Bool>,
        settingID: String
    ) -> some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.accentColor.opacity(expandedSetting == settingID ? 0.16 : 0.12))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.accentColor)
                    .symbolEffect(.bounce, value: binding.wrappedValue)
            }

            // Title and subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Toggle
            Toggle("", isOn: binding)
                .toggleStyle(ModernToggleStyle())
                .labelsHidden()
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(expandedSetting == settingID ? Color.accentColor.opacity(0.04) : Color.clear)
        )
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                expandedSetting = hovering ? settingID : nil
            }
        }
    }

    // MARK: - Setting with Picker
    private func settingWithPicker(
        icon: String,
        title: String,
        subtitle: String,
        settingID: String
    ) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.accentColor.opacity(expandedSetting == settingID ? 0.16 : 0.12))
                        .frame(width: 36, height: 36)

                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.accentColor)
                        .symbolEffect(.bounce, value: settings.notchSize)
                }

                // Title and subtitle
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            // Picker
            Picker("", selection: $settings.notchSize) {
                ForEach(NotchSizeOption.allCases) { option in
                    Text(option.displayName)
                        .tag(option)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(expandedSetting == settingID ? Color.accentColor.opacity(0.04) : Color.clear)
        )
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                expandedSetting = hovering ? settingID : nil
            }
        }
    }

    // MARK: - Setting with Slider
    private func settingWithSlider(
        icon: String,
        title: String,
        subtitle: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        settingID: String
    ) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.accentColor.opacity(expandedSetting == settingID ? 0.16 : 0.12))
                        .frame(width: 36, height: 36)

                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.accentColor)
                }

                // Title and subtitle
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Value display
                Text(String(format: "%.0f%%", value.wrappedValue * (range.upperBound > 1 ? 100.0 / range.upperBound : 100.0)))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
                    .monospacedDigit()
                    .frame(minWidth: 45, alignment: .trailing)
            }

            // Slider
            Slider(value: value, in: range)
                .tint(.accentColor)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(expandedSetting == settingID ? Color.accentColor.opacity(0.04) : Color.clear)
        )
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                expandedSetting = hovering ? settingID : nil
            }
        }
    }

    // MARK: - Reset Button
    private var resetButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                settings.resetToDefaults()
            }

            // Haptic feedback simulation with visual feedback
            withAnimation(.easeInOut(duration: 0.1)) {
                isHoveringReset = false
            }
        }) {
            HStack(spacing: 10) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 12, weight: .medium))

                Text("Reset to Defaults")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
            }
            .foregroundColor(isHoveringReset ? .accentColor : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(
                                isHoveringReset ? Color.accentColor.opacity(0.4) : Color.secondary.opacity(0.2),
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(isHoveringReset ? 1.02 : 1.0)
            .shadow(
                color: isHoveringReset ? Color.accentColor.opacity(0.2) : Color.clear,
                radius: 10,
                y: 4
            )
            .shadow(
                color: isHoveringReset ? Color.accentColor.opacity(0.1) : Color.clear,
                radius: 4,
                y: 2
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHoveringReset = hovering
            }
        }
    }
}

// MARK: - Modern Toggle Style
struct ModernToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                configuration.label
                Spacer()
                ZStack {
                    // Background
                    Capsule()
                        .fill(configuration.isOn ? Color.accentColor : Color.secondary.opacity(0.3))
                        .frame(width: 44, height: 26)

                    // Thumb
                    Circle()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 1)
                        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 0.5)
                        .frame(width: 22, height: 22)
                        .offset(x: configuration.isOn ? 9 : -9)
                        .scaleEffect(configuration.isOn ? 1.0 : 0.95)
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isOn)
    }
}

// MARK: - Preview
#Preview {
    GeneralSettingsView(settings: SettingsManager.shared)
        .padding()
        .frame(width: 480, height: 520)
        .background(Color(NSColor.windowBackgroundColor))
        .preferredColorScheme(.dark)
}
