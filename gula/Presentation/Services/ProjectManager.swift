import Foundation

class ProjectManager: ObservableObject {
    static let shared = ProjectManager()
    
    @Published var recentProjects: [Project] = []
    @Published var currentProject: Project?
    
    private let userDefaults = UserDefaults.standard
    private let recentProjectsKey = "RecentProjects"
    private let systemRepository: SystemRepositoryProtocol
    
    init(systemRepository: SystemRepositoryProtocol = SystemRepositoryImpl()) {
        self.systemRepository = systemRepository
        loadRecentProjects()
    }
    
    // MARK: - Recent Projects Management
    
    func addRecentProject(_ project: Project) {
        // Remove existing project with same path
        recentProjects.removeAll { $0.path == project.path }
        
        // Add to beginning
        recentProjects.insert(project, at: 0)
        
        // Keep only last 10 projects
        if recentProjects.count > 10 {
            recentProjects = Array(recentProjects.prefix(10))
        }
        
        saveRecentProjects()
    }
    
    func removeRecentProject(_ project: Project) {
        recentProjects.removeAll { $0.id == project.id }
        saveRecentProjects()
    }
    
    private func loadRecentProjects() {
        if let data = userDefaults.data(forKey: recentProjectsKey) {
            do {
                let projects = try JSONDecoder().decode([Project].self, from: data)
                // Filter out projects that no longer exist
                self.recentProjects = projects.filter { $0.exists }
            } catch {
                print("Error loading recent projects: \(error)")
                self.recentProjects = []
            }
        }
    }
    
    private func saveRecentProjects() {
        do {
            let data = try JSONEncoder().encode(recentProjects)
            userDefaults.set(data, forKey: recentProjectsKey)
        } catch {
            print("Error saving recent projects: \(error)")
        }
    }
    
    // MARK: - Project Operations
    
    func openProject(at path: String) -> Project? {
        guard let project = Project.createFromPath(path) else {
            return nil
        }
        
        currentProject = project
        addRecentProject(project)
        return project
    }
    
    func createProject(name: String, type: ProjectType, at path: String, apiKey: String) async throws -> Project {
        // Create the project directory
        let projectPath = "\(path)/\(name)"
        
        do {
            try FileManager.default.createDirectory(
                atPath: projectPath,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            throw ProjectError.failedToCreateDirectory(error.localizedDescription)
        }
        
        // Change to project directory and execute gula create command
        let command = "cd \"\(projectPath)\" && gula create \(type.rawValue) --key=\(apiKey)"
        
        do {
            let result = try await systemRepository.executeCommand(command)
            print("Project creation result: \(result)")
            
            let project = Project(name: name, path: projectPath, type: type)
            currentProject = project
            addRecentProject(project)
            
            return project
        } catch {
            // Clean up directory if project creation failed
            try? FileManager.default.removeItem(atPath: projectPath)
            throw ProjectError.failedToCreateProject(error.localizedDescription)
        }
    }
    
    // MARK: - Gula Commands
    
    func listModules(apiKey: String, branch: String? = nil) async throws -> String {
        guard let project = currentProject else {
            throw ProjectError.noCurrentProject
        }
        
        var command = "cd \"\(project.path)\" && gula list --key=\(apiKey)"
        if let branch = branch {
            command += " --branch=\(branch)"
        }
        
        return try await systemRepository.executeCommand(command)
    }
    
    func installModule(_ moduleName: String, apiKey: String, branch: String? = nil) async throws -> String {
        guard let project = currentProject else {
            throw ProjectError.noCurrentProject
        }
        
        var command = "cd \"\(project.path)\" && gula install \(moduleName) --key=\(apiKey)"
        if let branch = branch {
            command += " --branch=\(branch)"
        }
        
        return try await systemRepository.executeCommand(command)
    }
    
    func generateTemplate(_ templateName: String, type: String? = nil) async throws -> String {
        guard let project = currentProject else {
            throw ProjectError.noCurrentProject
        }
        
        var command = "cd \"\(project.path)\" && gula template \(templateName)"
        if let type = type {
            command += " --type=\(type)"
        }
        
        return try await systemRepository.executeCommand(command)
    }
}

// MARK: - Errors

enum ProjectError: LocalizedError {
    case failedToCreateDirectory(String)
    case failedToCreateProject(String)
    case noCurrentProject
    case invalidProjectPath
    
    var errorDescription: String? {
        switch self {
        case .failedToCreateDirectory(let message):
            return "Error creando directorio: \(message)"
        case .failedToCreateProject(let message):
            return "Error creando proyecto: \(message)"
        case .noCurrentProject:
            return "No hay proyecto seleccionado"
        case .invalidProjectPath:
            return "Ruta de proyecto inválida"
        }
    }
}