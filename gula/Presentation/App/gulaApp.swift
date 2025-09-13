import SwiftUI
import Sparkle

@main
struct gulaApp: App {
    @State private var isCheckingDependencies = true
    @State private var showOnboarding = false
    @State private var selectedProject: Project?
    @State private var dependencyStatus: DependencyStatus = .checking
    
    private let dependenciesUseCase = CheckSystemDependenciesUseCase(systemRepository: SystemRepositoryImpl())
    @ObservedObject private var projectManager = ProjectManager.shared
    private let updaterController: SPUStandardUpdaterController
    
    init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }
    
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
                .onAppear {
                    print("🚀 gulaApp: Checking dependencies...")
                }
            } else if showOnboarding {
                OnboardingBuilder.build {
                    showOnboarding = false
                }
                .frame(minWidth: 900, minHeight: 600)
            } else if projectManager.currentProject == nil {
                ProjectSelectionBuilder.build { project in
                    // Update access date when entering project
                    ProjectManager.shared.updateProjectAccessDate(project)
                    // El ProjectManager ya establece currentProject internamente
                }
                .frame(minWidth: 650, minHeight: 550)
                .onAppear {
                    print("🚀 gulaApp: Mostrando ProjectSelection - currentProject es nil")
                }
            } else {
                MainContentView(project: projectManager.currentProject!) {
                    projectManager.currentProject = nil
                }
                .frame(minWidth: 900, minHeight: 600)
                .onAppear {
                    print("🚀 gulaApp: Mostrando MainContentView - currentProject: \(projectManager.currentProject!.name)")
                }
            }
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        #endif
        
        #if os(macOS)
        .commands {
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(updater: updaterController.updater)
            }
        }
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
        print("🚀 gulaApp: checkDependenciesOnStartup iniciado")
        
        let finalStatus = await dependenciesUseCase.execute { status in
            Task { @MainActor in
                dependencyStatus = status
                print("🚀 gulaApp: Dependency status actualizado: \(status)")
            }
        }
        
        print("🚀 gulaApp: Final status: \(finalStatus)")
        
        switch finalStatus {
        case .allInstalled:
            print("🚀 gulaApp: Todas las dependencias instaladas")
            // All dependencies are installed and up to date
            isCheckingDependencies = false
            showOnboarding = false
            
        case .missingDependencies(_), .error(_), .checking, .gulaUpdateRequired(_), .updatingGula, .gulaUpdated:
            print("🚀 gulaApp: Mostrando onboarding debido a: \(finalStatus)")
            // Missing dependencies or error, show onboarding
            isCheckingDependencies = false
            showOnboarding = true
        }
        
        print("🚀 gulaApp: checkDependenciesOnStartup completado - isCheckingDependencies: \(isCheckingDependencies), showOnboarding: \(showOnboarding)")
    }
}

#if os(macOS)
struct CheckForUpdatesView: View {
    let updater: SPUUpdater
    
    var body: some View {
        Button("Check for Updates...") {
            updater.checkForUpdates()
        }
        .disabled(!updater.canCheckForUpdates)
    }
}
#endif
