import SwiftUI

// MARK: - Project Detail Main View

struct ProjectDetailView: View {
    let project: Project
    let onBack: () -> Void
    let onLogout: () -> Void
    @State private var projectManager = ProjectManager.shared
    @State private var viewModel: ProjectDetailViewModel
    @State private var selectedAction: GulaDashboardAction? = .overview
    @State private var showingModuleList = false

    init(project: Project, onBack: @escaping () -> Void, onLogout: @escaping () -> Void, viewModel: ProjectDetailViewModel = ProjectDetailViewModel()) {
        self.project = project
        self.onBack = onBack
        self.onLogout = onLogout
        self._viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            // Sidebar
            ProjectDetailSidebar(
                selection: $selectedAction,
                project: project,
                onBack: onBack,
                onLogout: onLogout
            )
            .navigationSplitViewColumnWidth(min: 280, ideal: 320, max: 400)
        } detail: {
            // Detail view
            ProjectDetailContent(
                selectedAction: $selectedAction,
                project: project,
                projectManager: projectManager,
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
    let onLogout: () -> Void
    
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
                        project: project,
                        onLogout: onLogout
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
    @Bindable var projectManager: ProjectManager
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
            if #available(macOS 15.0, *) {
                ModuleManagerView(
                    project: project,
                    projectManager: projectManager,
                    isLoading: $isLoading,
                    showingError: $showingError,
                    errorMessage: $errorMessage
                )
            } else {
                Text("El gestor de módulos requiere macOS 15.0 o superior")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
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
        case .chatAssistant:
            if #available(macOS 15.0, *) {
                ChatBuilder.buildProjectAgent(customerID: 1, project: project)
            } else {
                Text("ChatIA requiere macOS 15.0 o superior")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
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
        case .logout:
            // Logout is handled by the sidebar action, stay on overview
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
        onBack: { print("Back pressed") },
        onLogout: { print("Logout pressed") }
    )
}

// MARK: - App Version View

private struct AppVersionView: View {
 
    var body: some View {
        VStack(spacing: 6) {
            Divider()
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.7))
                
                Text("Gula v\(appVersion)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary.opacity(0.8))
                
                Spacer()

            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
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
