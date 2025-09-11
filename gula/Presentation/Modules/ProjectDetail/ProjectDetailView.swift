import SwiftUI

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
        case .openInFinder:
            ProjectOverviewView(
                project: project,
                selectedAction: $selectedAction,
                projectManager: projectManager
            )
            .onAppear {
                NSWorkspace.shared.open(URL(fileURLWithPath: project.path))
            }
        case .changeProject:
            ProjectOverviewView(
                project: project,
                selectedAction: $selectedAction,
                projectManager: projectManager
            )
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