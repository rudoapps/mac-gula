import Foundation
import SwiftUI
import TripleA

enum PythonStack: String, CaseIterable, Identifiable {
    case fastapi = "fastapi"
    case django = "django"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .fastapi:
            return "FastAPI"
        case .django:
            return "Django"
        }
    }
    
    var description: String {
        switch self {
        case .fastapi:
            return "API moderna y rápida"
        case .django:
            return "Framework web completo"
        }
    }
    
    var icon: String {
        switch self {
        case .fastapi:
            return "⚡️"
        case .django:
            return "🌐"
        }
    }
    
    var optionNumber: String {
        switch self {
        case .fastapi:
            return "1"
        case .django:
            return "2"
        }
    }
}

@available(macOS 15.0, *)
@Observable
class NewProjectViewModel {
    var projectName: String = ""
    var selectedType: ProjectType = .flutter
    var selectedPythonStack: PythonStack = .fastapi
    var packageName: String = ""
    var selectedLocation: String = ""
    var isCreating = false
    var showingError = false
    var errorMessage = ""
    var creationProgress = ""
    var isLoadingApiKey = false

    private let projectManager: ProjectManager
    private let filePickerService: FilePickerService
    private let getUserApiKeyUseCase: GetUserApiKeyUseCaseProtocol
    private var apiKey: String = ""

    init(projectManager: ProjectManager = ProjectManager.shared,
         filePickerService: FilePickerService = FilePickerService.shared,
         getUserApiKeyUseCase: GetUserApiKeyUseCaseProtocol? = nil) {
        self.projectManager = projectManager
        self.filePickerService = filePickerService

        // Initialize use case with default implementation if not injected
        if let useCase = getUserApiKeyUseCase {
            self.getUserApiKeyUseCase = useCase
        } else {
            // Create default dependencies
            let network = Config.shared.network
            let remoteDataSource = ApiKeyRemoteDataSource(network: network)
            let localDataSource = ApiKeyLocalDataSource()
            let repository = ApiKeyRepository(
                remoteDataSource: remoteDataSource,
                localDataSource: localDataSource
            )
            self.getUserApiKeyUseCase = GetUserApiKeyUseCase(repository: repository)
        }

        // Set default location to Documents
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            selectedLocation = documentsPath.path
        }

        // Load API key automatically
        Task {
            await loadApiKey()
        }
    }

    @MainActor
    private func loadApiKey() async {
        isLoadingApiKey = true
        do {
            let apiKeyEntity = try await getUserApiKeyUseCase.execute()
            self.apiKey = apiKeyEntity.key
            print("✅ API key loaded successfully")
        } catch {
            print("⚠️ Could not load API key: \(error)")
            // API key will remain empty, user needs to authenticate first
        }
        isLoadingApiKey = false
    }
    
    var isValid: Bool {
        let nameValid = !projectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && isValidProjectName
        let apiKeyValid = !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let locationValid = !selectedLocation.isEmpty
        
        // Package name validation only for mobile projects (not Python)
        let packageValid = selectedType == .python || 
                          (!packageName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && isValidPackageName)
        
        return nameValid && packageValid && apiKeyValid && locationValid
    }
    
    var isValidProjectName: Bool {
        let name = projectName.trimmingCharacters(in: .whitespacesAndNewlines)
        // Solo permite letras, números, guiones (-), guiones bajos (_) y puntos (.)
        let allowedCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.")
        return name.rangeOfCharacter(from: allowedCharacterSet.inverted) == nil && !name.isEmpty
    }
    
    var cleanedProjectName: String {
        let name = projectName.trimmingCharacters(in: .whitespacesAndNewlines)
        // Reemplaza caracteres no válidos con guiones bajos
        let allowedCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.")
        return String(name.unicodeScalars.map { allowedCharacterSet.contains($0) ? Character($0) : "_" })
    }
    
    var isValidPackageName: Bool {
        let packageName = packageName.trimmingCharacters(in: .whitespacesAndNewlines)
        return packageName.contains(".") && !packageName.hasPrefix(".") && !packageName.hasSuffix(".")
    }
    
    var selectedLocationDisplay: String {
        return selectedLocation.replacingOccurrences(of: NSHomeDirectory(), with: "~")
    }
    
    @MainActor
    func selectLocation() async {
        guard let location = await filePickerService.selectNewProjectLocation(suggestedName: projectName) else {
            return
        }
        selectedLocation = location
    }
    
    @MainActor
    func createProject() async -> Project? {
        guard isValid else { return nil }
        
        isCreating = true
        creationProgress = "Iniciando creación del proyecto..."
        
        do {
            creationProgress = "Configurando estructura del proyecto..."
            
            let project = try await projectManager.createProject(
                name: cleanedProjectName,
                type: selectedType,
                at: selectedLocation,
                packageName: packageName.trimmingCharacters(in: .whitespacesAndNewlines),
                pythonStack: selectedPythonStack.optionNumber,
                apiKey: apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            
            creationProgress = "¡Proyecto creado exitosamente!"
            
            // Small delay to show success message
            try await Task.sleep(nanoseconds: 500_000_000)
            
            isCreating = false
            return project
            
        } catch {
            isCreating = false
            showError(error.localizedDescription)
            return nil
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}
