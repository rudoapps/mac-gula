import Foundation

protocol CheckSystemDependenciesUseCaseProtocol {
    func execute() async -> DependencyStatus
}

class CheckSystemDependenciesUseCase: CheckSystemDependenciesUseCaseProtocol {
    private let systemRepository: SystemRepositoryProtocol
    
    init(systemRepository: SystemRepositoryProtocol) {
        self.systemRepository = systemRepository
    }
    
    func execute() async -> DependencyStatus {
        let dependencies = [SystemDependency.homebrew, SystemDependency.gula]
        var checkedDependencies: [SystemDependency] = []
        
        for var dependency in dependencies {
            do {
                dependency.isInstalled = try await systemRepository.checkCommandExists(dependency.checkCommand)
                checkedDependencies.append(dependency)
            } catch {
                return .error("Error checking \(dependency.name): \(error.localizedDescription)")
            }
        }
        
        let missingDependencies = checkedDependencies.filter { !$0.isInstalled }
        
        if missingDependencies.isEmpty {
            return .allInstalled
        } else {
            return .missingDependencies(missingDependencies)
        }
    }
}