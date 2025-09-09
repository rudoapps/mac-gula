import SwiftUI

@main
struct gulaApp: App {
    @State private var isCheckingDependencies = true
    @State private var showOnboarding = false
    @State private var selectedProject: Project?
    @State private var dependencyStatus: DependencyStatus = .checking
    
    private let dependenciesUseCase = CheckSystemDependenciesUseCase(systemRepository: SystemRepositoryImpl())
    
    var body: some Scene {
        WindowGroup {
            if isCheckingDependencies {
                // Loading screen while checking dependencies
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    
                    Text(statusMessage)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    if case .gulaUpdateRequired(let version) = dependencyStatus {
                        Text("Versión actual: \(version)")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
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
                    // Update access date when entering project
                    ProjectManager.shared.updateProjectAccessDate(project)
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
    
    private var statusMessage: String {
        switch dependencyStatus {
        case .checking:
            return "Verificando dependencias..."
        case .allInstalled:
            return "Dependencias verificadas ✅"
        case .missingDependencies(_):
            return "Instalando dependencias faltantes..."
        case .gulaUpdateRequired(_):
            return "Actualización de Gula requerida"
        case .updatingGula:
            return "Actualizando Gula...\nEsto puede tardar unos minutos"
        case .gulaUpdated:
            return "Gula actualizado exitosamente ✅"
        case .error(_):
            return "Error verificando dependencias"
        }
    }
    
    @MainActor
    private func checkDependenciesOnStartup() async {
        let finalStatus = await dependenciesUseCase.execute { status in
            Task { @MainActor in
                dependencyStatus = status
            }
        }
        
        switch finalStatus {
        case .allInstalled:
            // All dependencies are installed and up to date
            isCheckingDependencies = false
            showOnboarding = false
            
        case .missingDependencies(_), .error(_), .checking, .gulaUpdateRequired(_), .updatingGula, .gulaUpdated:
            // Missing dependencies or error, show onboarding
            isCheckingDependencies = false
            showOnboarding = true
        }
    }
}
