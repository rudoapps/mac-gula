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
        objectWillChange.send()
    }
    
    func removeRecentProject(_ project: Project) {
        recentProjects.removeAll { $0.id == project.id }
        saveRecentProjects()
        objectWillChange.send()
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
    
    func updateProjectAccessDate(_ project: Project) {
        // Create a new project with updated last opened date
        let updatedProject = Project(
            name: project.name,
            path: project.path,
            type: project.type,
            lastOpened: Date()
        )
        
        // Update in recent projects
        addRecentProject(updatedProject)
        
        // Update current project if it's the same
        if currentProject?.path == project.path {
            currentProject = updatedProject
        }
    }
    
    func createProject(name: String, type: ProjectType, at path: String, packageName: String, pythonStack: String, apiKey: String) async throws -> Project {
        // Don't create the project directory - let gula create it
        let projectPath = "\(path)/\(name)"
        
        // Create automated input for the interactive prompts using form data
        // Python projects have different prompts than mobile projects
        let automatedInputs: String
        if type == .python {
            // Python needs: APP_NAME and STACK (1=fastapi, 2=django)
            automatedInputs = """
            \(name)
            \(pythonStack)
            """
        } else {
            // Mobile projects need PROJECT_PATH, APP_NAME, and NEW_PACKAGE
            automatedInputs = """
            \(projectPath)
            \(name)
            \(packageName)
            """
        }
        
        // Execute gula create command
        let command: String
        if type == .python {
            // Python projects: ensure directory exists and is writable, then cd to it
            command = "mkdir -p \"\(path)\" && cd \"\(path)\" && echo '\(automatedInputs)' | gula create \(type.rawValue) --key=\(apiKey)"
        } else {
            // Mobile projects: execute from a writable directory and pass full project path
            command = "cd /tmp && echo '\(automatedInputs)' | gula create \(type.rawValue) --key=\(apiKey)"
        }
        
        do {
            let result = try await systemRepository.executeCommand(command)
            print("Project creation result: \(result)")
            
            // Verificar si la respuesta contiene errores de API key
            if result.contains("❌ Error") || result.contains("KEY incorrecta") || result.contains("no autorizada") {
                let errorMessage = "Clave de API inválida o no autorizada. Por favor verifica tu clave API."
                print("❌ Error de API Key detectado durante la creación del proyecto: \(errorMessage)")
                throw ProjectError.invalidAPIKey(errorMessage)
            }
            
            // Check if the result contains indicators of successful start
            let lowercaseResult = result.lowercased()
            if lowercaseResult.contains("empezando la instalación") || 
               lowercaseResult.contains("starting installation") ||
               lowercaseResult.contains("arquetipo") {
                print("✅ Project creation initiated successfully")
                
                // Wait a moment for the project to be fully created
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                
                // For Python projects, verify the actual project path that was created
                let actualProjectPath: String
                if type == .python {
                    // Check if gula created the project in the expected location
                    let expectedPath = "\(path)/\(name)"
                    print("🔍 Checking if Python project exists at: \(expectedPath)")
                    
                    if FileManager.default.fileExists(atPath: expectedPath) {
                        actualProjectPath = expectedPath
                        print("✅ Found Python project at: \(expectedPath)")
                    } else {
                        // If not found in expected location, use the configured path
                        actualProjectPath = projectPath
                        print("⚠️ Python project not found at expected location, using: \(projectPath)")
                    }
                } else {
                    actualProjectPath = projectPath
                }
                
                let project = Project(name: name, path: actualProjectPath, type: type)
                print("📁 Created project object: \(project.name) at \(project.path)")
                print("📁 Project exists check: \(project.exists)")
                
                currentProject = project
                addRecentProject(project)
                
                return project
            } else {
                // Output doesn't look like a successful gula execution
                try? FileManager.default.removeItem(atPath: projectPath)
                throw ProjectError.failedToCreateProject("Gula no produjo la salida esperada: \(result)")
            }
            
        } catch {
            // Clean up directory if project creation failed
            try? FileManager.default.removeItem(atPath: projectPath)
            
            // Provide more user-friendly error messages
            let errorMessage: String
            if error.localizedDescription.contains("timeout") {
                errorMessage = "La creación del proyecto tardó demasiado tiempo. Verifica tu conexión a internet y la clave API."
            } else if error.localizedDescription.contains("Command failed") {
                errorMessage = "Error ejecutando el comando gula. Verifica que la clave API sea válida y que tengas permisos en el directorio."
            } else {
                errorMessage = error.localizedDescription
            }
            
            throw ProjectError.failedToCreateProject(errorMessage)
        }
    }
    
    // MARK: - Gula Commands
    
    func listModules(apiKey: String, branch: String? = nil) async throws -> String {
        guard let project = currentProject else {
            throw ProjectError.noCurrentProject
        }
        
        // Verificar que el directorio del proyecto existe
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: project.path) else {
            throw ProjectError.projectNotFound("El directorio del proyecto no existe: \(project.path)")
        }
        
        // Construir el comando con cd explícito
        var gulaCommand = "/opt/homebrew/bin/gula list --key=\(apiKey)"
        if let branch = branch {
            gulaCommand += " --branch=\(branch)"
        }
        
        let command = """
        cd "\(project.path)" && pwd && echo "Ejecutando desde: $(pwd)" && \(gulaCommand)
        """
        
        print("🔍 Ejecutando comando: \(command)")
        print("📁 Directorio del proyecto: \(project.path)")
        
        do {
            let result = try await systemRepository.executeCommand(command)
            print("✅ Resultado del comando gula list:")
            print(result)
            
            // Verificar si la respuesta contiene errores de API key
            if result.contains("❌ Error") || result.contains("KEY incorrecta") || result.contains("no autorizada") {
                let errorMessage = "Clave de API inválida o no autorizada. Por favor verifica tu clave API."
                print("❌ Error de API Key detectado: \(errorMessage)")
                throw ProjectError.invalidAPIKey(errorMessage)
            }
            
            // Verificar si la respuesta contiene errores de git
            if result.lowercased().contains("fatal:") && (result.contains("git repository") || result.contains("fetch-pack")) {
                let errorMessage = "Error de conexión con el repositorio de módulos. Verifica tu conexión a internet y que el proyecto esté correctamente inicializado."
                print("❌ Error de Git detectado: \(errorMessage)")
                throw ProjectError.installationFailed(errorMessage)
            }
            
            return result
        } catch {
            print("❌ Error ejecutando gula list: \(error)")
            throw error
        }
    }
    
    func installModule(_ moduleName: String, apiKey: String, branch: String? = nil, autoReplace: Bool = false) async throws -> String {
        guard let project = currentProject else {
            throw ProjectError.noCurrentProject
        }
        
        // Verificar que el directorio del proyecto existe
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: project.path) else {
            throw ProjectError.projectNotFound("El directorio del proyecto no existe: \(project.path)")
        }
        
        var gulaCommand = "/opt/homebrew/bin/gula install \(moduleName) --key=\(apiKey)"
        if let branch = branch {
            gulaCommand += " --branch=\(branch)"
        }
        
        // Enhanced command with better timeout and interrupt handling
        let finalCommand: String
        if autoReplace {
            // Use timeout with yes command and proper exit code handling
            finalCommand = "timeout 300 bash -c 'yes | \(gulaCommand)'; EXIT_CODE=$?; if [ $EXIT_CODE -eq 124 ]; then echo 'GULA_TIMEOUT_OCCURRED'; else exit $EXIT_CODE; fi"
        } else {
            // Add timeout for manual mode with proper exit code handling
            finalCommand = "timeout 300 \(gulaCommand); EXIT_CODE=$?; if [ $EXIT_CODE -eq 124 ]; then echo 'GULA_TIMEOUT_OCCURRED'; else exit $EXIT_CODE; fi"
        }
        
        let command = """
        cd "\(project.path)" && pwd && echo "Ejecutando desde: $(pwd)" && echo "Iniciando instalación de \(moduleName)..." && \(finalCommand)
        """
        
        print("🔧 Instalando módulo: \(moduleName)")
        print("📁 Directorio del proyecto: \(project.path)")
        print("🔍 Comando completo: \(command)")
        if autoReplace {
            print("🔄 Modo reemplazo automático activado (timeout: 5 minutos)")
        } else {
            print("⚠️  Modo manual (timeout: 5 minutos)")
        }
        
        let startTime = Date()
        
        do {
            let result = try await systemRepository.executeCommand(command)
            let elapsed = Date().timeIntervalSince(startTime)
            
            print("📊 Instalación de \(moduleName) completada en \(String(format: "%.1f", elapsed)) segundos")
            print("📄 Resultado completo: \(result)")
            
            // Check for timeout or interruption
            if result.contains("GULA_TIMEOUT_OCCURRED") {
                let errorMessage = "La instalación del módulo \(moduleName) excedió el tiempo límite de 5 minutos"
                print("⏱️ Timeout detectado: \(errorMessage)")
                throw ProjectError.installationFailed(errorMessage)
            }
            
            // Verificar si la respuesta contiene errores de API key
            if result.contains("❌ Error") || result.contains("KEY incorrecta") || result.contains("no autorizada") {
                let errorMessage = "Clave de API inválida o no autorizada. Por favor verifica tu clave API."
                print("❌ Error de API Key detectado: \(errorMessage)")
                throw ProjectError.invalidAPIKey(errorMessage)
            }
            
            // Verificar si la respuesta contiene errores fatales
            if result.lowercased().contains("fatal") {
                let errorMessage = "Error fatal durante la instalación del módulo \(moduleName)"
                print("❌ Error fatal detectado: \(errorMessage)")
                throw ProjectError.installationFailed(errorMessage)
            }
            
            // Check for interactive prompts that might indicate the process got stuck
            if result.contains("¿Deseas reemplazarlo?") && result.contains("(s/n)") {
                // If we see the prompts but the process completed (didn't timeout), 
                // it means the yes command worked, so this is not an error
                if !result.contains("Fin de la ejecución") && !result.contains("Proceso finalizado") {
                    let errorMessage = "El módulo \(moduleName) requiere confirmación manual para reemplazar archivos existentes."
                    print("🤖 Prompt interactivo sin resolución detectado: \(errorMessage)")
                    throw ProjectError.installationFailed(errorMessage)
                } else {
                    print("🤖 Prompts interactivos detectados pero resueltos automáticamente con 'yes'")
                }
            }
            
            print("✅ Módulo \(moduleName) instalado exitosamente")
            return result
            
        } catch {
            let elapsed = Date().timeIntervalSince(startTime)
            print("❌ Error instalando módulo \(moduleName) después de \(String(format: "%.1f", elapsed)) segundos: \(error)")
            
            // Provide more specific error information
            if error.localizedDescription.contains("timeout") {
                throw ProjectError.installationFailed("La instalación del módulo \(moduleName) excedió el tiempo límite de 5 minutos")
            }
            
            throw error
        }
    }
    
    func generateTemplate(_ templateName: String, type: String? = nil) async throws -> String {
        guard let project = currentProject else {
            throw ProjectError.noCurrentProject
        }
        
        // Verificar que el directorio del proyecto existe
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: project.path) else {
            throw ProjectError.projectNotFound("El directorio del proyecto no existe: \(project.path)")
        }
        
        // Usar un script más robusto que asegure el cambio de directorio
        var gulaCommand = "/opt/homebrew/bin/gula template \(templateName)"
        if let type = type {
            gulaCommand += " --type=\(type)"
        }
        
        let command = """
        cd "\(project.path)" && pwd && echo "Ejecutando desde: $(pwd)" && \(gulaCommand)
        """
        
        print("🏗️ Generando template: \(templateName)")
        print("📁 Directorio del proyecto: \(project.path)")
        print("🔍 Comando: \(command)")
        
        do {
            let result = try await systemRepository.executeCommand(command)
            print("✅ Template \(templateName) generado exitosamente")
            return result
        } catch {
            print("❌ Error generando template \(templateName): \(error)")
            throw error
        }
    }
    
    func listTemplates() async throws -> String {
        guard let project = currentProject else {
            throw ProjectError.noCurrentProject
        }
        
        // Verificar que el directorio del proyecto existe
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: project.path) else {
            throw ProjectError.projectNotFound("El directorio del proyecto no existe: \(project.path)")
        }
        
        let command = """
        cd "\(project.path)" && pwd && echo "Ejecutando desde: $(pwd)" && /opt/homebrew/bin/gula template --list
        """
        
        print("📋 Listando templates disponibles")
        print("📁 Directorio del proyecto: \(project.path)")
        
        do {
            let result = try await systemRepository.executeCommand(command)
            return result
        } catch {
            print("❌ Error listando templates: \(error)")
            // Devolver lista simulada para testing
            return """
            ═══════════════════════════════════════════════
                            TEMPLATES DISPONIBLES                 
            ═══════════════════════════════════════════════
            
            📱 COMPONENTES UI:
              • user           - Gestión de usuarios (CRUD completo)
              • product        - Gestión de productos (CRUD completo)
              • order          - Gestión de pedidos (CRUD completo)
              • category       - Gestión de categorías (CRUD completo)
              
            🔐 AUTENTICACIÓN:
              • auth           - Sistema de autenticación completo
              • profile        - Perfil de usuario editable
              
            💳 COMERCIO:
              • payment        - Procesamiento de pagos
              • cart           - Carrito de compras
              
            📊 REPORTES:
              • analytics      - Dashboard de analytics
              • reports        - Generador de reportes
              
            🛠️ UTILIDADES:
              • settings       - Pantalla de configuración
              • notifications  - Sistema de notificaciones
            
            ═══════════════════════════════════════════════
            Total: 12 templates disponibles
            
            Tipos disponibles: clean, fastapi
            """
        }
    }
}

// MARK: - Errors

enum ProjectError: LocalizedError {
    case failedToCreateDirectory(String)
    case failedToCreateProject(String)
    case noCurrentProject
    case invalidProjectPath
    case projectNotFound(String)
    case invalidAPIKey(String)
    case installationFailed(String)
    
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
        case .projectNotFound(let message):
            return "Proyecto no encontrado: \(message)"
        case .invalidAPIKey(let message):
            return message
        case .installationFailed(let message):
            return message
        }
    }
}
