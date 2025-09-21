import Foundation

protocol CheckSystemDependenciesUseCaseProtocol {
    func execute() async -> DependencyStatus
    func execute(progressCallback: @escaping (DependencyStatus) -> Void) async -> DependencyStatus
}

class CheckSystemDependenciesUseCase: CheckSystemDependenciesUseCaseProtocol {
    private let systemRepository: SystemRepositoryProtocol
    
    init(systemRepository: SystemRepositoryProtocol) {
        self.systemRepository = systemRepository
    }
    
    func execute() async -> DependencyStatus {
        return await execute { _ in }
    }
    
    func execute(progressCallback: @escaping (DependencyStatus) -> Void) async -> DependencyStatus {
        progressCallback(.checking)

        // First, check internet connectivity
        progressCallback(.checkingConnectivity)
        print("🌐 Checking internet connectivity before dependency validation...")

        do {
            let hasInternet = try await systemRepository.checkInternetConnectivity()
            if !hasInternet {
                print("❌ No internet connection detected")
                progressCallback(.noInternetConnection)
                return .noInternetConnection
            }
            print("✅ Internet connectivity confirmed")
        } catch {
            print("⚠️ Could not verify internet connectivity, continuing anyway: \(error.localizedDescription)")
            // Continue with dependency check even if connectivity check fails
        }

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
        
        if !missingDependencies.isEmpty {
            print("⚠️ Missing \(missingDependencies.count) dependencies")
            return .missingDependencies(missingDependencies)
        }
        
        // If all dependencies are installed, check gula version
        print("🔍 Checking gula version...")
        do {
            let gulaHelpOutput = try await systemRepository.executeCommand("gula help")
            print("📋 Gula help output: \(gulaHelpOutput)")
            
            if gulaHelpOutput.contains("Es necesario actualizar el script tu versión:") {
                // Extract version from output
                let versionRegex = try NSRegularExpression(pattern: "tu versión: (\\d+\\.\\d+\\.\\d+)", options: [])
                let range = NSRange(location: 0, length: gulaHelpOutput.utf16.count)
                if let match = versionRegex.firstMatch(in: gulaHelpOutput, options: [], range: range),
                   let versionRange = Range(match.range(at: 1), in: gulaHelpOutput) {
                    let currentVersion = String(gulaHelpOutput[versionRange])
                    print("⚠️ Gula update required. Current version: \(currentVersion)")
                    progressCallback(.gulaUpdateRequired(currentVersion))
                    
                    // Verify internet connectivity before attempting update
                    print("🌐 Verifying internet connectivity before update...")
                    let hasInternetForUpdate = try await systemRepository.checkInternetConnectivity()
                    if !hasInternetForUpdate {
                        print("❌ No internet connection for update")
                        return .error("Internet connection required for updating Gula")
                    }

                    // Perform automatic update
                    print("🔄 Starting gula update...")
                    progressCallback(.updatingGula)

                    let updateOutput = try await systemRepository.executeCommand("brew upgrade gula")
                    print("✅ Gula update completed: \(updateOutput)")
                    
                    // Verify update was successful
                    let verifyOutput = try await systemRepository.executeCommand("gula help")
                    if verifyOutput.contains("✅ Tienes la versión más actual") {
                        print("✅ Gula successfully updated!")
                        progressCallback(.gulaUpdated)
                        return .allInstalled
                    } else {
                        return .error("Update completed but version check failed")
                    }
                } else {
                    return .error("Could not extract version from gula output")
                }
            } else if gulaHelpOutput.contains("✅ Tienes la versión más actual") {
                print("✅ Gula is up to date!")
                return .allInstalled
            } else {
                print("⚠️ Could not determine gula version status")
                return .error("Could not determine gula version status from output: \(gulaHelpOutput)")
            }
        } catch {
            print("❌ Error checking gula version: \(error.localizedDescription)")
            return .error("Error checking gula version: \(error.localizedDescription)")
        }
    }
}