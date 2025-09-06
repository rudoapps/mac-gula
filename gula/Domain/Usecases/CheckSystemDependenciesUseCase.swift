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
        
        print("🔍 Starting dependency check...")
        
        for var dependency in dependencies {
            do {
                print("🔍 Checking \(dependency.name) with command: \(dependency.checkCommand)")
                dependency.isInstalled = try await systemRepository.checkCommandExists(dependency.checkCommand)
                print("✅ \(dependency.name) installed: \(dependency.isInstalled)")
                checkedDependencies.append(dependency)
            } catch {
                print("❌ Error checking \(dependency.name): \(error.localizedDescription)")
                return .error("Error checking \(dependency.name): \(error.localizedDescription)")
            }
        }
        
        let missingDependencies = checkedDependencies.filter { !$0.isInstalled }
        print("📋 Missing dependencies: \(missingDependencies.map { $0.name })")
        
        if missingDependencies.isEmpty {
            print("🎉 All dependencies installed!")
            return .allInstalled
        } else {
            print("⚠️ Missing \(missingDependencies.count) dependencies")
            return .missingDependencies(missingDependencies)
        }
    }
}