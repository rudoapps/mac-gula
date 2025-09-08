import Foundation
import SwiftUI

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

class NewProjectViewModel: ObservableObject {
    @Published var projectName: String = ""
    @Published var selectedType: ProjectType = .flutter
    @Published var selectedPythonStack: PythonStack = .fastapi
    @Published var packageName: String = ""
    @Published var apiKey: String = ""
    @Published var selectedLocation: String = ""
    @Published var isCreating = false
    @Published var showingError = false
    @Published var errorMessage = ""
    @Published var creationProgress = ""
    
    private let projectManager: ProjectManager
    private let filePickerService: FilePickerService
    
    init(projectManager: ProjectManager = ProjectManager.shared,
         filePickerService: FilePickerService = FilePickerService.shared) {
        self.projectManager = projectManager
        self.filePickerService = filePickerService
        
        // Set default location to Documents
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            selectedLocation = documentsPath.path
        }
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