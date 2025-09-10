import Foundation
import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var dependencyStatus: DependencyStatus = .checking
    @Published var installingDependencies: Set<String> = []
    @Published var dependencyProgress: [String: String] = [:]
    
    private let checkDependenciesUseCase: CheckSystemDependenciesUseCaseProtocol
    private let systemRepository: SystemRepositoryProtocol
    
    // Callback to notify when setup is complete
    var onSetupComplete: (() -> Void)?
    
    init(onSetupComplete: (() -> Void)? = nil) {
        self.systemRepository = SystemRepositoryImpl()
        self.checkDependenciesUseCase = CheckSystemDependenciesUseCase(systemRepository: systemRepository)
        self.onSetupComplete = onSetupComplete
    }
    
    @MainActor
    func checkDependencies() {
        dependencyStatus = .checking
        
        Task {
            let status = await checkDependenciesUseCase.execute()
            dependencyStatus = status
        }
    }
    
    @MainActor
    func recheckDependencies() {
        checkDependencies()
    }
    
    @MainActor
    func installDependency(_ dependency: SystemDependency) {
        guard !installingDependencies.contains(dependency.name) else { return }
        
        // Si es Gula CLI, verificar que Homebrew esté instalado primero
        if dependency.name == "Gula CLI" {
            guard isHomebrewInstalled() else {
                dependencyStatus = .error("Homebrew debe instalarse antes que Gula CLI")
                return
            }
        }
        
        installingDependencies.insert(dependency.name)
        dependencyProgress[dependency.name] = "Iniciando instalación..."
        
        Task {
            do {
                if dependency.name == "Homebrew" {
                    // Instalación de Homebrew - usar Terminal para interactividad
                    dependencyProgress[dependency.name] = "Preparando instalación de Homebrew..."
                    try await Task.sleep(nanoseconds: 500_000_000)
                    
                    dependencyProgress[dependency.name] = "Abriendo Terminal para instalación interactiva..."
                    try await Task.sleep(nanoseconds: 500_000_000)
                    
                    dependencyProgress[dependency.name] = "Ejecutando instalador de Homebrew en Terminal..."
                    let result = try await systemRepository.executeCommandInTerminal(dependency.installCommand)
                    print("Installation result: \(result)")
                    
                    dependencyProgress[dependency.name] = "Configurando Homebrew..."
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 segundo
                    
                    dependencyProgress[dependency.name] = "Actualizando variables de entorno..."
                    try await Task.sleep(nanoseconds: 2_000_000_000) // 2 segundos para que Homebrew esté disponible
                    
                    dependencyProgress[dependency.name] = "Finalizando instalación..."
                    try await Task.sleep(nanoseconds: 500_000_000)
                    
                } else {
                    // Instalación de Gula CLI - usar comandos brew normales (sin sudo)
                    dependencyProgress[dependency.name] = "Preparando instalación de \(dependency.name)..."
                    try await Task.sleep(nanoseconds: 500_000_000)
                    
                    dependencyProgress[dependency.name] = "Configurando repositorio de Gula..."
                    try await Task.sleep(nanoseconds: 500_000_000)
                    
                    dependencyProgress[dependency.name] = "Descargando e instalando Gula CLI..."
                    let result = try await systemRepository.executeCommand(dependency.installCommand)
                    print("Installation result: \(result)")
                    
                    dependencyProgress[dependency.name] = "Finalizando instalación..."
                    try await Task.sleep(nanoseconds: 500_000_000)
                }
                
                // Verificación común para ambos
                dependencyProgress[dependency.name] = "Verificando instalación..."
                let status = await checkDependenciesUseCase.execute()
                dependencyStatus = status
                
                dependencyProgress[dependency.name] = "¡Instalación completada!"
                try await Task.sleep(nanoseconds: 500_000_000)
                
            } catch {
                dependencyProgress[dependency.name] = "Error en la instalación"
                dependencyStatus = .error("Error installing \(dependency.name): \(error.localizedDescription)")
            }
            
            installingDependencies.remove(dependency.name)
            dependencyProgress.removeValue(forKey: dependency.name)
        }
    }
    
    func proceedToMainApp() {
        onSetupComplete?()
    }
    
    @MainActor
    func skipDependencyCheck() {
        dependencyStatus = .allInstalled
    }
    
    private func isHomebrewInstalled() -> Bool {
        switch dependencyStatus {
        case .allInstalled:
            return true
        case .missingDependencies(let missing):
            // Homebrew está instalado si no está en la lista de dependencias faltantes
            return !missing.contains { $0.name == "Homebrew" }
        case .checking, .error:
            return false
        case .gulaUpdateRequired, .updatingGula, .gulaUpdated:
            return true // If we're dealing with gula updates, homebrew is installed
        }
    }
    
    func isInstalling(_ dependencyName: String) -> Bool {
        return installingDependencies.contains(dependencyName)
    }
    
    func installationProgress(for dependencyName: String) -> String {
        return dependencyProgress[dependencyName] ?? ""
    }
}