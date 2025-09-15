import SwiftUI
import Sparkle

// MARK: - Project Detail Main View

struct ProjectDetailView: View {
    let project: Project
    let onBack: () -> Void
    @StateObject private var projectManager = ProjectManager.shared
    @StateObject private var viewModel: ProjectDetailViewModel
    @State private var selectedAction: GulaDashboardAction? = .overview
    @State private var showingModuleList = false
    
    init(project: Project, onBack: @escaping () -> Void, viewModel: ProjectDetailViewModel = ProjectDetailViewModel()) {
        self.project = project
        self.onBack = onBack
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            // Sidebar
            ProjectDetailSidebar(
                selection: $selectedAction,
                project: project,
                onBack: onBack
            )
            .navigationSplitViewColumnWidth(min: 280, ideal: 320, max: 400)
        } detail: {
            // Detail view
            ProjectDetailContent(
                selectedAction: $selectedAction,
                project: project,
                projectManager: projectManager,
                apiKey: $viewModel.apiKey,
                isLoading: $viewModel.isLoading,
                showingError: $viewModel.showingError,
                errorMessage: $viewModel.errorMessage
            )
        }
        .onAppear {
            viewModel.loadData()
        }
    }
}

// MARK: - Project Detail Sidebar

private struct ProjectDetailSidebar: View {
    @Binding var selection: GulaDashboardAction?
    let project: Project
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            ProjectHeaderSection(project: project, onBack: onBack)
                .padding(.horizontal, 20)
            
            // Navigation
            ScrollView {
                VStack(spacing: 8) {
                    SidebarSection(
                        title: "Proyecto",
                        items: GulaDashboardAction.projectItems,
                        selection: $selection,
                        project: project,
                        onBack: onBack
                    )
                    
                    SidebarSection(
                        title: "Desarrollo",
                        items: GulaDashboardAction.developmentItems,
                        selection: $selection,
                        project: project
                    )
                    
                    SidebarSection(
                        title: "Herramientas",
                        items: GulaDashboardAction.toolsItems,
                        selection: $selection,
                        project: project
                    )
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
            }
            .scrollBounceBehavior(.basedOnSize)
            
            Spacer()
            
            // Version info
            AppVersionView()
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Project Detail Content

private struct ProjectDetailContent: View {
    @Binding var selectedAction: GulaDashboardAction?
    let project: Project
    @ObservedObject var projectManager: ProjectManager
    @Binding var apiKey: String
    @Binding var isLoading: Bool
    @Binding var showingError: Bool
    @Binding var errorMessage: String
    
    @ViewBuilder
    var body: some View {
        switch selectedAction ?? .overview {
        case .overview:
            ProjectOverviewView(
                project: project,
                selectedAction: $selectedAction,
                projectManager: projectManager
            )
        case .modules:
            ModuleManagerView(
                project: project,
                projectManager: projectManager,
                apiKey: $apiKey,
                isLoading: $isLoading,
                showingError: $showingError,
                errorMessage: $errorMessage
            )
        case .generateTemplate:
            TemplateGeneratorView(
                project: project,
                projectManager: projectManager
            )
        case .preCommitHooks:
            PreCommitManagerView(
                project: project,
                projectManager: projectManager
            )
            .onAppear {
                print("🎯 Case .preCommitHooks ejecutándose para proyecto: \(project.name)")
            }
        case .apiGenerator:
            APIGeneratorView(project: project)
        case .openInFinder:
            ProjectOverviewView(
                project: project,
                selectedAction: $selectedAction,
                projectManager: projectManager
            )
            .onAppear {
                NSWorkspace.shared.open(URL(fileURLWithPath: project.path))
            }
        case .settings:
            ProjectOverviewView(
                project: project,
                selectedAction: $selectedAction,
                projectManager: projectManager
            )
        }
    }
}

// MARK: - Preview

#Preview {
    let sampleProject = Project(
        name: "Sample Project",
        path: "/Users/sample/project",
        type: .flutter
    )
    
    return ProjectDetailView(
        project: sampleProject,
        onBack: { print("Back pressed") }
    )
}

// MARK: - App Version View

private struct AppVersionView: View {
    private let updater = SPUStandardUpdaterController(
        startingUpdater: false,
        updaterDelegate: nil,
        userDriverDelegate: nil
    ).updater
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.7))
                
                Text("Gula v\(appVersion)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary.opacity(0.8))
                
                Spacer()
                
                Button(action: {
                    updater.checkForUpdates()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary.opacity(0.6))
                }
                .buttonStyle(.plain)
                .disabled(!updater.canCheckForUpdates)
                .help("Buscar actualizaciones")
            }
            
            Rectangle()
                .fill(.secondary.opacity(0.2))
                .frame(height: 0.5)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.primary.opacity(0.03))
        )
    }
    
    private var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return "\(version) (\(build))"
        } else {
            return "1.0"
        }
    }
}