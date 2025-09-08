import SwiftUI

@main
struct gulaApp: App {
    @State private var isCheckingDependencies = true
    @State private var showOnboarding = false
    @State private var selectedProject: Project?
    
    private let dependenciesUseCase = CheckSystemDependenciesUseCase(systemRepository: SystemRepositoryImpl())
    
    var body: some Scene {
        WindowGroup {
            if isCheckingDependencies {
                // Loading screen while checking dependencies
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Verificando dependencias...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(NSColor.windowBackgroundColor))
                .task {
                    await checkDependenciesOnStartup()
                }
            } else if showOnboarding {
                OnboardingBuilder.build {
                    showOnboarding = false
                }
                .frame(minWidth: 900, minHeight: 600)
            } else if selectedProject == nil {
                ProjectSelectionBuilder.build { project in
                    selectedProject = project
                }
.frame(minWidth: 650, minHeight: 550)
            } else {
                MainContentView(project: selectedProject!) {
                    selectedProject = nil
                }
                .frame(minWidth: 900, minHeight: 600)
            }
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        #endif
    }
    
    @MainActor
    private func checkDependenciesOnStartup() async {
        let dependencyStatus = await dependenciesUseCase.execute()
        
        switch dependencyStatus {
        case .allInstalled:
            // Both dependencies are installed, go directly to project selection
            isCheckingDependencies = false
            showOnboarding = false
            
        case .missingDependencies(_), .error(_), .checking:
            // Missing dependencies or error, show onboarding
            isCheckingDependencies = false
            showOnboarding = true
        }
    }
}
