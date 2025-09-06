import Foundation
import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var dependencyStatus: DependencyStatus = .checking
    @Published var isInstalling = false
    
    private let checkDependenciesUseCase: CheckSystemDependenciesUseCaseProtocol
    private let systemRepository: SystemRepositoryProtocol
    
    // Callback to notify when setup is complete
    var onSetupComplete: (() -> Void)?
    
    init() {
        self.systemRepository = SystemRepositoryImpl()
        self.checkDependenciesUseCase = CheckSystemDependenciesUseCase(systemRepository: systemRepository)
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
        guard !isInstalling else { return }
        
        isInstalling = true
        
        Task {
            do {
                let result = try await systemRepository.executeCommand(dependency.installCommand)
                print("Installation result: \(result)")
                
                // Wait a moment for installation to complete
                try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                
                // Recheck dependencies after installation
                let status = await checkDependenciesUseCase.execute()
                dependencyStatus = status
                
            } catch {
                dependencyStatus = .error("Error installing \(dependency.name): \(error.localizedDescription)")
            }
            
            isInstalling = false
        }
    }
    
    func proceedToMainApp() {
        onSetupComplete?()
    }
    
    @MainActor
    func skipDependencyCheck() {
        dependencyStatus = .allInstalled
    }
}