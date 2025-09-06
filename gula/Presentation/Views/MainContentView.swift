import SwiftUI

struct MainContentView: View {
    @State private var selectedItem: SidebarItem? = .home
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selectedItem)
        } detail: {
            DetailView(selectedItem: selectedItem ?? .home)
        }
        .navigationSplitViewStyle(.balanced)
    }
}

struct SidebarView: View {
    @Binding var selection: SidebarItem?
    
    var body: some View {
        List(selection: $selection) {
            Section("Principal") {
                ForEach(SidebarItem.mainItems) { item in
                    NavigationLink(value: item) {
                        Label(item.title, systemImage: item.icon)
                    }
                }
            }
            
            Section("Herramientas") {
                ForEach(SidebarItem.toolItems) { item in
                    NavigationLink(value: item) {
                        Label(item.title, systemImage: item.icon)
                    }
                }
            }
        }
        .navigationTitle("Gula")
        .frame(minWidth: 200)
        #if os(macOS)
        .background(VisualEffectView())
        #else
        .background(.regularMaterial)
        #endif
    }
}

struct DetailView: View {
    let selectedItem: SidebarItem
    
    var body: some View {
        ZStack {
            #if os(macOS)
            VisualEffectView(material: .underWindowBackground)
                .ignoresSafeArea()
            #else
            Color.clear
                .background(.regularMaterial)
                .ignoresSafeArea()
            #endif
            
            Group {
                switch selectedItem {
                case .home:
                    HomeView()
                case .documents:
                    DocumentsView()
                case .favorites:
                    FavoritesView()
                case .settings:
                    SettingsView()
                case .analytics:
                    AnalyticsView()
                case .tools:
                    ToolsView()
                }
            }
            .padding()
        }
        .navigationTitle(selectedItem.title)
        .frame(minWidth: 600, minHeight: 400)
    }
}

enum SidebarItem: String, CaseIterable, Identifiable, Hashable {
    case home = "home"
    case documents = "documents"
    case favorites = "favorites"
    case settings = "settings"
    case analytics = "analytics"
    case tools = "tools"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .home: return "Inicio"
        case .documents: return "Documentos"
        case .favorites: return "Favoritos"
        case .settings: return "Configuración"
        case .analytics: return "Analíticas"
        case .tools: return "Herramientas"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .documents: return "doc.text.fill"
        case .favorites: return "heart.fill"
        case .settings: return "gear"
        case .analytics: return "chart.bar.fill"
        case .tools: return "wrench.and.screwdriver.fill"
        }
    }
    
    static let mainItems: [SidebarItem] = [.home, .documents, .favorites]
    static let toolItems: [SidebarItem] = [.analytics, .tools, .settings]
}

#Preview {
    MainContentView()
}