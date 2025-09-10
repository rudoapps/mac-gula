import Foundation
import SwiftUI

class ProjectSelectionViewModel: ObservableObject {
    @Published var showingNewProjectSheet = false
    @Published var showingError = false
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var recentProjects: [Project] = []
    
    private var projectManager: ProjectManager
    private let filePickerService: FilePickerService
    
    // Callback to notify when a project is selected
    var onProjectSelected: ((Project) -> Void)?
    
    init(projectManager: ProjectManager = ProjectManager.shared, 
         filePickerService: FilePickerService = FilePickerService.shared) {
        self.projectManager = projectManager
        self.filePickerService = filePickerService
        
        // Initialize with current projects
        self.recentProjects = projectManager.recentProjects
    }
    
    // MARK: - Actions
    
    @MainActor
    func createNewProject() {
        showingNewProjectSheet = true
    }
    
    @MainActor
    func openExistingProject() async {
        guard let selectedPath = await filePickerService.selectProjectFolder() else {
            return
        }
        
        isLoading = true
        
        if let project = projectManager.openProject(at: selectedPath) {
            onProjectSelected?(project)
        } else {
            showError("No se pudo detectar el tipo de proyecto en la carpeta seleccionada. Asegúrate de seleccionar una carpeta que contenga un proyecto Android, iOS, Flutter o Python válido.")
        }
        
        isLoading = false
    }
    
    @MainActor
    func selectRecentProject(_ project: Project) {
        if project.exists {
            projectManager.currentProject = project
            projectManager.updateProjectAccessDate(project) // Update last opened time
            // Update local copy to reflect date change
            recentProjects = projectManager.recentProjects
            onProjectSelected?(project)
        } else {
            showError("El proyecto ya no existe en la ubicación: \(project.displayPath)")
            projectManager.removeRecentProject(project)
            // Update local copy immediately
            recentProjects = projectManager.recentProjects
        }
    }
    
    @MainActor
    func removeRecentProject(_ project: Project) {
        projectManager.removeRecentProject(project)
        // Update local copy immediately
        recentProjects = projectManager.recentProjects
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}