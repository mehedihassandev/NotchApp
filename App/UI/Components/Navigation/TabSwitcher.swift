import SwiftUI

// MARK: - Tab Switcher
/// A segmented tab switcher with animated selection indicator

struct TabSwitcher<Tab: TabItem>: View {

    // MARK: - Properties
    @Binding var selectedTab: Tab
    let tabs: [Tab]

    @Namespace private var tabNamespace

    // MARK: - Initialization
    init(selectedTab: Binding<Tab>, tabs: [Tab]) {
        self._selectedTab = selectedTab
        self.tabs = tabs
    }

    // MARK: - Body
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.id) { tab in
                tabButton(for: tab)
            }
        }
        .padding(4)
        .glassStyle()
    }

    // MARK: - Subviews
    private func tabButton(for tab: Tab) -> some View {
        HStack(spacing: 6) {
            Image(systemName: tab.icon)
                .font(.system(size: 11, weight: .semibold))

            Text(tab.title)
                .font(AppTheme.Typography.body())
        }
        .foregroundColor(selectedTab.id == tab.id ? .white : .white.opacity(0.4))
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            ZStack {
                if selectedTab.id == tab.id {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.white.opacity(0.12))
                        .matchedGeometryEffect(id: "tab", in: tabNamespace)
                }
            }
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(AppTheme.Animations.spring) {
                selectedTab = tab
            }
        }
    }
}

// MARK: - Tab Item Protocol
/// Protocol for tab items used in TabSwitcher

protocol TabItem: Hashable, Identifiable {
    var id: String { get }
    var title: String { get }
    var icon: String { get }
}

// MARK: - Default Implementation
extension TabItem where Self: RawRepresentable, RawValue == String {
    var id: String { rawValue }
    var title: String { rawValue }
}

// MARK: - Preview
private enum PreviewTab: String, TabItem, CaseIterable {
    case home = "Home"
    case settings = "Settings"

    var id: String { rawValue }
    var title: String { rawValue }
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var selectedTab: PreviewTab = .home

        var body: some View {
            TabSwitcher(selectedTab: $selectedTab, tabs: PreviewTab.allCases)
                .padding()
                .background(Color.black)
        }
    }

    return PreviewWrapper()
}
