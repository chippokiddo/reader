import SwiftUI

// MARK: - Preferences Tabs
enum PrefTab: String, CaseIterable {
    case general     = "General"
    case manageData  = "Manage Data"
    case about       = "About"
    
    var systemImage: String {
        switch self {
        case .general:     return "gear"
        case .manageData:  return "icloud"
        case .about:       return "info"
        }
    }
}

// MARK: - Preferences View
struct PreferencesView: View {
    @State private var selectedTab: PrefTab = .general
    @State private var hoveredTab: PrefTab? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            tabBar
            Divider()
            content
        }
        .onAppear {
            if let window = NSApplication.shared.windows.first(where: { $0.identifier?.rawValue == "preferencesWindow" }) {
                window.styleMask.remove(.resizable)
                window.standardWindowButton(.zoomButton)?.isHidden = true
            }
        }
    }
    
    private var tabBar: some View {
        HStack(spacing: 12) {
            ForEach(PrefTab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(12)
    }
    
    @ViewBuilder
    private var content: some View {
        Group {
            switch selectedTab {
            case .general:
                GeneralView()
            case .manageData:
                ImportExportView()
            case .about:
                AboutView()
            }
        }
        .frame(width: 420, height: 320)
    }
    
    private func tabButton(for tab: PrefTab) -> some View {
        let isSelected = (selectedTab == tab)
        let isHovered = (hoveredTab == tab)
        
        return Button(action: {
            selectedTab = tab
        }) {
            VStack(spacing: 6) {
                Image(systemName: tab.systemImage)
                    .font(.system(size: 20))
                Text(tab.rawValue)
                    .font(.caption)
            }
            .frame(width: 90, height: 62)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(
                        isHovered ? Color.primary.opacity(0.15) : Color.clear,
                        lineWidth: isHovered ? 1 : 0
                    )
            )
            .foregroundColor(isSelected ? Color.accentColor : .primary)
            .contentShape(RoundedRectangle(cornerRadius: 8))
            .accessibilityLabel(Text(tab.rawValue))
        }
        .buttonStyle(.plain)
        .onHover { inside in
            hoveredTab = inside ? tab : nil
        }
    }
}
