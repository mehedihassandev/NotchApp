import SwiftUI

// MARK: - Settings View
/// Main settings modal view with multiple tabs

struct SettingsView: View {

    // MARK: - State
    @StateObject private var settings = SettingsManager.shared
    @State private var selectedTab: SettingsTab = .general
    @Namespace private var tabNamespace

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Header
            settingsHeader

            // Tab Bar
            tabBar
                .padding(.top, 8)

            // Content
            ScrollView(.vertical, showsIndicators: false) {
                tabContent
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
            }
        }
        .frame(width: 540, height: 620)
        .background(
            ZStack {
                // Base color
                Color(NSColor.windowBackgroundColor)

                // Subtle gradient overlay
                LinearGradient(
                    colors: [
                        settings.accentColor.color.opacity(0.03),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
    }

    // MARK: - Header
    private var settingsHeader: some View {
        HStack {
            Text("Settings")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.primary, .primary.opacity(0.7)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 8)
    }

    // MARK: - Tab Bar
    private var tabBar: some View {
        HStack(spacing: 6) {
            ForEach(SettingsTab.allCases) { tab in
                tabButton(for: tab)
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
        )
        .padding(.horizontal, 24)
    }

    private func tabButton(for tab: SettingsTab) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selectedTab = tab
            }
        }) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(selectedTab == tab ? settings.accentColor.color : Color.clear)
                        .frame(width: 36, height: 36)

                    Image(systemName: tab.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(selectedTab == tab ? .white : .secondary)
                }

                Text(tab.title)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(selectedTab == tab ? settings.accentColor.color : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    if selectedTab == tab {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(settings.accentColor.color.opacity(0.1))
                            .matchedGeometryEffect(id: "settingsTab", in: tabNamespace)
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Tab Content
    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .general:
            GeneralSettingsView(settings: settings)
        case .appearance:
            AppearanceSettingsView(settings: settings)
        case .widgets:
            WidgetsSettingsView(settings: settings)
        case .shortcuts:
            ShortcutsSettingsView(settings: settings)
        case .about:
            AboutSettingsView()
        }
    }
}

// MARK: - Settings Tab Enum
enum SettingsTab: String, CaseIterable, Identifiable {
    case general
    case appearance
    case widgets
    case shortcuts
    case about

    var id: String { rawValue }

    var title: String {
        switch self {
        case .general: return "General"
        case .appearance: return "Appearance"
        case .widgets: return "Widgets"
        case .shortcuts: return "Shortcuts"
        case .about: return "About"
        }
    }

    var icon: String {
        switch self {
        case .general: return "gearshape.fill"
        case .appearance: return "paintbrush.fill"
        case .widgets: return "square.grid.2x2.fill"
        case .shortcuts: return "keyboard.fill"
        case .about: return "info.circle.fill"
        }
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}
