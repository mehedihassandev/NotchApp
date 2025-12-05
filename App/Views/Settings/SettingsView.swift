import SwiftUI

// MARK: - Settings View
/// Main settings modal view with multiple tabs - Modern glassmorphism design

struct SettingsView: View {

    // MARK: - State
    @StateObject private var settings = SettingsManager.shared
    @State private var selectedTab: SettingsTab = .general
    @Namespace private var tabNamespace
    @State private var isHoveringTab: SettingsTab? = nil

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Tab Bar
            tabBar
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

            // Content
            ScrollView(.vertical, showsIndicators: false) {
                tabContent
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
        }
        .frame(width: 580, height: 620)
        .background(Color(NSColor.windowBackgroundColor))
    }

    // MARK: - Tab Bar
    private var tabBar: some View {
        HStack(spacing: 6) {
            ForEach(SettingsTab.allCases) { tab in
                tabButton(for: tab)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.06), radius: 10, y: 3)
                .shadow(color: .black.opacity(0.03), radius: 2, y: 1)
        )
    }

    private func tabButton(for tab: SettingsTab) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                selectedTab = tab
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: tab.icon)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(selectedTab == tab ? .white : (isHoveringTab == tab ? .primary : .secondary))
                    .symbolEffect(.bounce, value: selectedTab == tab)

                Text(tab.title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(selectedTab == tab ? .white : (isHoveringTab == tab ? .primary : .secondary))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 7)
            .padding(.horizontal, 12)
            .background(
                ZStack {
                    if selectedTab == tab {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.accentColor)
                            .shadow(color: Color.accentColor.opacity(0.3), radius: 6, y: 2)
                            .matchedGeometryEffect(id: "settingsTab", in: tabNamespace)
                    } else if isHoveringTab == tab {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.primary.opacity(0.06))
                    }
                }
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHoveringTab = hovering ? tab : nil
            }
        }
    }

    // MARK: - Tab Content
    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .general:
            GeneralSettingsView(settings: settings)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.96).combined(with: .move(edge: .trailing))),
                    removal: .opacity.combined(with: .scale(scale: 0.96).combined(with: .move(edge: .leading)))
                ))
                .id("general")
        case .keyboardShortcuts:
            KeyboardShortcutsSettingsView()
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.96).combined(with: .move(edge: .trailing))),
                    removal: .opacity.combined(with: .scale(scale: 0.96).combined(with: .move(edge: .leading)))
                ))
                .id("keyboardShortcuts")
        case .advanced:
            AdvancedSettingsView()
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.96).combined(with: .move(edge: .trailing))),
                    removal: .opacity.combined(with: .scale(scale: 0.96).combined(with: .move(edge: .leading)))
                ))
                .id("advanced")
        case .about:
            AboutSettingsView()
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.96).combined(with: .move(edge: .trailing))),
                    removal: .opacity.combined(with: .scale(scale: 0.96).combined(with: .move(edge: .leading)))
                ))
                .id("about")
        }
    }
}

// MARK: - Settings Tab Enum
enum SettingsTab: String, CaseIterable, Identifiable {
    case general
    case keyboardShortcuts
    case advanced
    case about

    var id: String { rawValue }

    var title: String {
        switch self {
        case .general: return "General"
        case .keyboardShortcuts: return "Shortcuts"
        case .advanced: return "Advanced"
        case .about: return "About"
        }
    }

    var icon: String {
        switch self {
        case .general: return "gearshape.fill"
        case .keyboardShortcuts: return "keyboard"
        case .advanced: return "gearshape.2.fill"
        case .about: return "info.circle.fill"
        }
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}
