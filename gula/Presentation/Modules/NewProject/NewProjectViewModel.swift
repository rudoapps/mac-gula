import Foundation
import SwiftUI

class NewProjectViewModel: ObservableObject {
    @Published var projectName: String = ""
    @Published var selectedType: ProjectType = .flutter
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
        return !projectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !selectedLocation.isEmpty
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
                name: projectName.trimmingCharacters(in: .whitespacesAndNewlines),
                type: selectedType,
                at: selectedLocation,
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