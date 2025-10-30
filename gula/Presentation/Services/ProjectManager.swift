import Foundation

@Observable
class ProjectManager {
    static let shared = ProjectManager()
    
    var recentProjects: [Project] = []
    var currentProject: Project?
    
    private let userDefaults = UserDefaults.standard
    private let recentProjectsKey = "RecentProjects"
    private let systemRepository: SystemRepositoryProtocol
    
    init(systemRepository: SystemRepositoryProtocol = SystemRepositoryImpl()) {
        #if DEBUG
        print("🚀 ProjectManager: Inicializando...")
        #endif
        self.systemRepository = systemRepository
        loadRecentProjects()
        loadCurrentProject()
        #if DEBUG
        print("🚀 ProjectManager: Inicialización completada")
        #endif
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
                #if DEBUG
                print("Error loading recent projects: \(error)")
                #endif
                self.recentProjects = []
            }
        }
    }
    
    private func saveRecentProjects() {
        do {
            let data = try JSONEncoder().encode(recentProjects)
            userDefaults.set(data, forKey: recentProjectsKey)
        } catch {
            #if DEBUG
            print("Error saving recent projects: \(error)")
            #endif
        }
    }
    
    private func loadCurrentProject() {
        // Establecer el proyecto más reciente como el actual si existe
        if let mostRecentProject = recentProjects.first {
            #if DEBUG
            print("📁 ProjectManager: Proyecto más reciente encontrado: \(mostRecentProject.name)")
            #endif
            #if DEBUG
            print("📁 ProjectManager: Ruta del proyecto: \(mostRecentProject.path)")
            #endif
            #if DEBUG
            print("📁 ProjectManager: ¿Existe el proyecto?: \(mostRecentProject.exists)")
            #endif
            
            if mostRecentProject.exists {
                #if DEBUG
                print("📁 ProjectManager: Estableciendo proyecto actual: \(mostRecentProject.name)")
                #endif
                currentProject = mostRecentProject
            } else {
                #if DEBUG
                print("📁 ProjectManager: El proyecto no existe en el sistema de archivos")
                #endif
                currentProject = nil
            }
        } else {
            #if DEBUG
            print("📁 ProjectManager: No hay proyectos recientes disponibles")
            #endif
            currentProject = nil
        }
    }
    
    // MARK: - Project Operations
    
    func openProject(at path: String) -> Project? {
        guard let project = Project.createFromPath(path) else {
            return nil
        }
        
        currentProject = project
        addRecentProject(project)
        saveRecentProjects()
        #if DEBUG
        print("📁 ProjectManager: Proyecto abierto y establecido como actual: \(project.name)")
        #endif
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
            #if DEBUG
            print("Project creation result: \(result)")
            #endif
            
            // Verificar si la respuesta contiene errores de API key
            if result.contains("❌ Error") || result.contains("KEY incorrecta") || result.contains("no autorizada") {
                let errorMessage = "Clave de API inválida o no autorizada. Por favor verifica tu clave API."
                #if DEBUG
                print("❌ Error de API Key detectado durante la creación del proyecto: \(errorMessage)")
                #endif
                throw ProjectError.invalidAPIKey(errorMessage)
            }
            
            // Check if the result contains indicators of successful start
            let lowercaseResult = result.lowercased()
            if lowercaseResult.contains("empezando la instalación") || 
               lowercaseResult.contains("starting installation") ||
               lowercaseResult.contains("arquetipo") {
                #if DEBUG
                print("✅ Project creation initiated successfully")
                #endif
                
                // Wait a moment for the project to be fully created
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                
                // For Python projects, verify the actual project path that was created
                let actualProjectPath: String
                if type == .python {
                    // Check if gula created the project in the expected location
                    let expectedPath = "\(path)/\(name)"
                    #if DEBUG
                    print("🔍 Checking if Python project exists at: \(expectedPath)")
                    #endif
                    
                    if FileManager.default.fileExists(atPath: expectedPath) {
                        actualProjectPath = expectedPath
                        #if DEBUG
                        print("✅ Found Python project at: \(expectedPath)")
                        #endif
                    } else {
                        // If not found in expected location, use the configured path
                        actualProjectPath = projectPath
                        #if DEBUG
                        print("⚠️ Python project not found at expected location, using: \(projectPath)")
                        #endif
                    }
                } else {
                    actualProjectPath = projectPath
                }
                
                let project = Project(name: name, path: actualProjectPath, type: type)
                #if DEBUG
                print("📁 Created project object: \(project.name) at \(project.path)")
                #endif
                #if DEBUG
                print("📁 Project exists check: \(project.exists)")
                #endif
                
                currentProject = project
                addRecentProject(project)
                saveRecentProjects()
                #if DEBUG
                print("📁 ProjectManager: Proyecto creado y establecido como actual: \(project.name)")
                #endif
                
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
        
        // Construir el comando simplificado para ejecución directa
        var gulaCommand = "/opt/homebrew/bin/gula list --key=\(apiKey)"
        if let branch = branch {
            gulaCommand += " --branch=\(branch)"
        }

        let command = """
        cd "\(project.path)" && \(gulaCommand)
        """
        
        #if DEBUG
        print("🔍 Ejecutando comando: \(command)")
        #endif
        #if DEBUG
        print("📁 Directorio del proyecto: \(project.path)")
        #endif
        
        do {
            let result = try await systemRepository.executeCommand(command)
            #if DEBUG
            print("✅ Resultado del comando gula list:")
            #endif
            #if DEBUG
            print(result)
            #endif
            
            // Verificar si la respuesta contiene errores de API key
            if result.contains("❌ Error") || result.contains("KEY incorrecta") || result.contains("no autorizada") {
                let errorMessage = "Clave de API inválida o no autorizada. Por favor verifica tu clave API."
                #if DEBUG
                print("❌ Error de API Key detectado: \(errorMessage)")
                #endif
                throw ProjectError.invalidAPIKey(errorMessage)
            }
            
            // Verificar si la respuesta contiene errores de git
            if result.lowercased().contains("fatal:") && (result.contains("git repository") || result.contains("fetch-pack")) {
                let errorMessage = "Error de conexión con el repositorio de módulos. Verifica tu conexión a internet y que el proyecto esté correctamente inicializado."
                #if DEBUG
                print("❌ Error de Git detectado: \(errorMessage)")
                #endif
                throw ProjectError.installationFailed(errorMessage)
            }
            
            return result
        } catch {
            #if DEBUG
            print("❌ Error ejecutando gula list: \(error)")
            #endif
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

        // Simplified command - timeout is handled by systemRepository
        let command: String
        if autoReplace {
            // Use yes | for auto-replace mode (requires bash)
            command = "cd \"\(project.path)\" && yes | \(gulaCommand)"
        } else {
            // Direct execution without bash wrapper
            command = "cd \"\(project.path)\" && \(gulaCommand)"
        }
        
        #if DEBUG
        print("🔧 Instalando módulo: \(moduleName)")
        #endif
        #if DEBUG
        print("📁 Directorio del proyecto: \(project.path)")
        #endif
        #if DEBUG
        print("🔍 Comando completo: \(command)")
        #endif
        if autoReplace {
            #if DEBUG
            print("🔄 Modo reemplazo automático activado (timeout: 5 minutos)")
            #endif
        } else {
            #if DEBUG
            print("⚠️  Modo manual (timeout: 5 minutos)")
            #endif
        }
        
        let startTime = Date()

        do {
            // SystemRepository already has 5 minute timeout for long operations
            let result = try await systemRepository.executeCommand(command) 
            let elapsed = Date().timeIntervalSince(startTime)

            #if DEBUG
            print("📊 Instalación de \(moduleName) completada en \(String(format: "%.1f", elapsed)) segundos")
            #endif
            #if DEBUG
            print("📄 Resultado completo: \(result)")
            #endif
            
            // Verificar si la respuesta contiene errores de API key
            if result.contains("❌ Error") || result.contains("KEY incorrecta") || result.contains("no autorizada") {
                let errorMessage = "Clave de API inválida o no autorizada. Por favor verifica tu clave API."
                #if DEBUG
                print("❌ Error de API Key detectado: \(errorMessage)")
                #endif
                throw ProjectError.invalidAPIKey(errorMessage)
            }
            
            // Verificar si la respuesta contiene errores fatales
            if result.lowercased().contains("fatal") {
                let errorMessage = "Error fatal durante la instalación del módulo \(moduleName)"
                #if DEBUG
                print("❌ Error fatal detectado: \(errorMessage)")
                #endif
                throw ProjectError.installationFailed(errorMessage)
            }
            
            // Check for interactive prompts that might indicate the process got stuck
            if result.contains("¿Deseas reemplazarlo?") && result.contains("(s/n)") {
                // If we see the prompts but the process completed (didn't timeout), 
                // it means the yes command worked, so this is not an error
                if !result.contains("Fin de la ejecución") && !result.contains("Proceso finalizado") {
                    let errorMessage = "El módulo \(moduleName) requiere confirmación manual para reemplazar archivos existentes."
                    #if DEBUG
                    print("🤖 Prompt interactivo sin resolución detectado: \(errorMessage)")
                    #endif
                    throw ProjectError.installationFailed(errorMessage)
                } else {
                    #if DEBUG
                    print("🤖 Prompts interactivos detectados pero resueltos automáticamente con 'yes'")
                    #endif
                }
            }
            
            #if DEBUG
            print("✅ Módulo \(moduleName) instalado exitosamente")
            #endif
            return result
            
        } catch {
            let elapsed = Date().timeIntervalSince(startTime)
            #if DEBUG
            print("❌ Error instalando módulo \(moduleName) después de \(String(format: "%.1f", elapsed)) segundos: \(error)")
            #endif
            
            // Provide more specific error information
            if error.localizedDescription.contains("timeout") {
                throw ProjectError.installationFailed("La instalación del módulo \(moduleName) excedió el tiempo límite de 5 minutos")
            }
            
            throw error
        }
    }
    
    func generateTemplate(_ templateName: String) async throws -> String {
        guard let project = currentProject else {
            throw ProjectError.noCurrentProject
        }
        
        // Verificar que el directorio del proyecto existe
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: project.path) else {
            throw ProjectError.projectNotFound("El directorio del proyecto no existe: \(project.path)")
        }
        
        // Construir el comando simplificado
        let gulaCommand = "/opt/homebrew/bin/gula template \(templateName)"

        let command = """
        cd "\(project.path)" && \(gulaCommand)
        """
        
        #if DEBUG
        print("🏗️ Generando template: \(templateName)")
        #endif
        #if DEBUG
        print("📁 Directorio del proyecto: \(project.path)")
        #endif
        #if DEBUG
        print("🔍 Comando: \(command)")
        #endif
        
        do {
            let result = try await systemRepository.executeCommand(command)
            #if DEBUG
            print("✅ Template \(templateName) generado exitosamente")
            #endif
            return result
        } catch {
            #if DEBUG
            print("❌ Error generando template \(templateName): \(error)")
            #endif
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
        cd "\(project.path)" && /opt/homebrew/bin/gula template --list
        """
        
        #if DEBUG
        print("📋 Listando templates disponibles")
        #endif
        #if DEBUG
        print("📁 Directorio del proyecto: \(project.path)")
        #endif
        
        do {
            let result = try await systemRepository.executeCommand(command)
            return result
        } catch {
            #if DEBUG
            print("❌ Error listando templates: \(error)")
            #endif
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
    
    func getProjectStatus() async throws -> GulaStatus {
        guard let project = currentProject else {
            throw ProjectError.noCurrentProject
        }
        
        let command = """
        cd "\(project.path)" && /opt/homebrew/bin/gula status
        """
        
        #if DEBUG
        print("📊 Obteniendo status del proyecto")
        #endif
        #if DEBUG
        print("📁 Directorio del proyecto: \(project.path)")
        #endif
        #if DEBUG
        print("📊 Comando a ejecutar: \(command)")
        #endif
        
        do {
            let result = try await systemRepository.executeCommand(command)
            return parseGulaStatus(from: result)
        } catch {
            #if DEBUG
            print("❌ Error obteniendo status: \(error)")
            #endif
            // Retornar un status vacío en caso de error
            return GulaStatus(
                projectCreated: nil,
                gulaVersion: "Desconocida",
                installedModules: [],
                hasProject: false,
                statistics: nil,
                generatedTemplates: []
            )
        }
    }
    
    private func parseGulaStatus(from output: String) -> GulaStatus {
        var projectCreated: Date?
        var gulaVersion = "Desconocida"
        var installedModules: [GulaModule] = []
        var hasProject = false
        var statistics: GulaStatistics?
        var generatedTemplates: [GulaTemplate] = []
        
        let lines = output.components(separatedBy: .newlines)
        
        // Buscar versión de gula
        for line in lines {
            if line.contains("versión:") {
                let components = line.components(separatedBy: ":")
                if components.count > 1 {
                    gulaVersion = components[1].trimmingCharacters(in: .whitespaces)
                }
            }
            
            // Buscar fecha de creación del proyecto
            if line.contains("Proyecto creado:") {
                let components = line.components(separatedBy: ":")
                if components.count > 1 {
                    let dateString = components[1].trimmingCharacters(in: .whitespaces)
                    let formatter = ISO8601DateFormatter()
                    projectCreated = formatter.date(from: dateString)
                    hasProject = true
                }
            }
        }
        
        // Parsear estadísticas
        var successfulInstalls = 0
        var generatedTemplatesCount = 0
        var listingsPerformed = 0
        var operationsWithError = 0
        var totalOperations = 0
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedLine.contains("🔧 Instalaciones exitosas:") {
                if let value = extractNumberFromStatLine(trimmedLine) {
                    successfulInstalls = value
                }
            } else if trimmedLine.contains("📝 Templates generados:") {
                if let value = extractNumberFromStatLine(trimmedLine) {
                    generatedTemplatesCount = value
                }
            } else if trimmedLine.contains("📋 Listados realizados:") {
                if let value = extractNumberFromStatLine(trimmedLine) {
                    listingsPerformed = value
                }
            } else if trimmedLine.contains("❌ Operaciones con error:") {
                if let value = extractNumberFromStatLine(trimmedLine) {
                    operationsWithError = value
                }
            } else if trimmedLine.contains("📊 Total de operaciones:") {
                if let value = extractNumberFromStatLine(trimmedLine) {
                    totalOperations = value
                }
            }
        }
        
        statistics = GulaStatistics(
            successfulInstalls: successfulInstalls,
            generatedTemplates: generatedTemplatesCount,
            listingsPerformed: listingsPerformed,
            operationsWithError: operationsWithError,
            totalOperations: totalOperations
        )
        
        // Parsear módulos instalados
        var inModulesSection = false
        for line in lines {
            if line.contains("MÓDULOS INSTALADOS:") {
                inModulesSection = true
                continue
            }
            
            if inModulesSection {
                if line.contains("ÚLTIMAS OPERACIONES:") {
                    break
                }
                
                // Buscar líneas que contengan información de módulos
                if line.contains("→") && line.contains("(") && line.contains(")") {
                    let components = line.components(separatedBy: "→")
                    if components.count >= 2 {
                        let platform = components[0].trimmingCharacters(in: .whitespaces)
                        let moduleInfo = components[1].trimmingCharacters(in: .whitespaces)
                        
                        // Extraer nombre del módulo y fecha
                        let moduleComponents = moduleInfo.components(separatedBy: " (")
                        if moduleComponents.count >= 2 {
                            let moduleName = moduleComponents[0].trimmingCharacters(in: .whitespaces)
                            let remainingInfo = moduleComponents[1]
                            
                            // Extraer branch y fecha
                            let branchAndDate = remainingInfo.components(separatedBy: ") - ")
                            let branch = branchAndDate[0]
                            var installDate: Date?
                            
                            if branchAndDate.count > 1 {
                                let dateString = branchAndDate[1].replacingOccurrences(of: "Z", with: "")
                                let formatter = ISO8601DateFormatter()
                                installDate = formatter.date(from: dateString + "Z")
                            }
                            
                            let module = GulaModule(
                                name: moduleName,
                                platform: platform,
                                branch: branch,
                                installDate: installDate
                            )
                            installedModules.append(module)
                        }
                    }
                }
            }
        }
        
        // Parsear templates generados de la sección OPERACIONES
        var inOperationsSection = false
        for line in lines {
            if line.contains("OPERACIONES:") {
                inOperationsSection = true
                continue
            }
            
            if inOperationsSection {
                if line.contains("═══════════════════════════════════════════════") {
                    break
                }
                
                // Buscar líneas que contengan operaciones de template exitosas
                // Formato: "2025-09-11T13:33:18Z - template ios:phone (success)"
                if line.contains("template") && line.contains("(success)") {
                    let components = line.components(separatedBy: " - template ")
                    if components.count >= 2 {
                        let dateString = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
                        let templateInfo = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        // Extraer platform y nombre del template
                        let templateComponents = templateInfo.components(separatedBy: ":")
                        if templateComponents.count >= 2 {
                            let platform = templateComponents[0].trimmingCharacters(in: .whitespacesAndNewlines)
                            let nameAndStatus = templateComponents[1]
                            let templateName = nameAndStatus.components(separatedBy: " (success)")[0].trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            // Parsear fecha
                            let formatter = ISO8601DateFormatter()
                            let generatedDate = formatter.date(from: dateString)
                            
                            let template = GulaTemplate(
                                name: templateName,
                                platform: platform,
                                generatedDate: generatedDate
                            )
                            generatedTemplates.append(template)
                        }
                    }
                }
            }
        }
        
        // Si no encontramos el archivo de log, marcar como sin proyecto
        if output.contains("No se encontró archivo de log") {
            hasProject = false
        }
        
        return GulaStatus(
            projectCreated: projectCreated,
            gulaVersion: gulaVersion,
            installedModules: installedModules,
            hasProject: hasProject,
            statistics: statistics,
            generatedTemplates: generatedTemplates
        )
    }
    
    private func extractNumberFromStatLine(_ line: String) -> Int? {
        // Extraer número de líneas como "🔧 Instalaciones exitosas: 6"
        let components = line.components(separatedBy: ":")
        if components.count > 1 {
            let numberString = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
            return Int(numberString)
        }
        return nil
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
    case preCommitError(String)
    
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
        case .preCommitError(let message):
            return "Error con pre-commit hooks: \(message)"
        }
    }
}

// MARK: - Pre-commit Hooks Extension

extension ProjectManager {
    
    // MARK: - Pre-commit Installation & Configuration
    
    func isPreCommitInstalled() async throws -> Bool {
        do {
            let result = try await systemRepository.executeCommand("which pre-commit")
            return !result.isEmpty
        } catch {
            return false
        }
    }
    
    func isPreCommitToolInstalled() async -> Bool {
        do {
            let result = try await systemRepository.executeCommand("pre-commit --version")
            #if DEBUG
            print("✅ Pre-commit is installed: \(result)")
            #endif
            return true
        } catch {
            #if DEBUG
            print("⚠️ Pre-commit tool not found")
            #endif
            return false
        }
    }
    
    func isPreCommitInstalledInProject(_ project: Project) async -> Bool {
        let projectPath = project.path
        
        // Check if .pre-commit-config.yaml exists
        let configPath = "\(projectPath)/.pre-commit-config.yaml"
        let configExists = FileManager.default.fileExists(atPath: configPath)
        
        // Check if pre-commit hooks are actually installed in .git/hooks/
        let hookPath = "\(projectPath)/.git/hooks/pre-commit"
        let hookExists = FileManager.default.fileExists(atPath: hookPath)
        
        // Check if it's a pre-commit managed hook
        var isPreCommitHook = false
        if hookExists {
            do {
                let hookContent = try String(contentsOfFile: hookPath)
                isPreCommitHook = hookContent.contains("pre-commit")
            } catch {
                #if DEBUG
                print("❌ Error reading pre-commit hook: \(error)")
                #endif
            }
        }
        
        return configExists && hookExists && isPreCommitHook
    }
    
    func getPreCommitProjectStatus(_ project: Project) async -> PreCommitProjectStatus {
        let projectPath = project.path
        
        // Check if pre-commit tool is installed globally
        let toolInstalled = await isPreCommitToolInstalled()
        
        // Check if project has pre-commit configuration
        let configPath = "\(projectPath)/.pre-commit-config.yaml"
        let configExists = FileManager.default.fileExists(atPath: configPath)
        
        // Check if hooks are installed in the project
        let hooksInstalled = await isPreCommitInstalledInProject(project)
        
        // Get configured hooks if config exists
        var configuredHooks: [String] = []
        if configExists {
            do {
                configuredHooks = try await getConfiguredHooks(at: configPath)
            } catch {
                #if DEBUG
                print("❌ Error reading configured hooks: \(error)")
                #endif
            }
        }
        
        return PreCommitProjectStatus(
            toolInstalled: toolInstalled,
            configExists: configExists,
            hooksInstalled: hooksInstalled,
            configuredHooks: configuredHooks
        )
    }
    
    func executeCommand(_ command: String) async throws -> String {
        return try await systemRepository.executeCommand(command)
    }
    
    func getInstalledHookTools(for projectType: ProjectType) async -> [String] {
        var installedTools: [String] = []
        
        switch projectType {
        case .ios:
            // Check SwiftLint
            do {
                let _ = try await systemRepository.executeCommand("which swiftlint")
                installedTools.append("swiftlint")
            } catch {
                #if DEBUG
                print("SwiftLint not found")
                #endif
            }
            
            // Check SwiftFormat
            do {
                let _ = try await systemRepository.executeCommand("which swiftformat")
                installedTools.append("swiftformat")
            } catch {
                #if DEBUG
                print("SwiftFormat not found")
                #endif
            }
            
            // xcodebuild is always available on macOS
            installedTools.append("ios-build-check")
            
        case .android:
            // Check ktlint
            do {
                let _ = try await systemRepository.executeCommand("which ktlint")
                installedTools.append("ktlint")
            } catch {
                #if DEBUG
                print("ktlint not found")
                #endif
            }
            
            // Check detekt
            do {
                let _ = try await systemRepository.executeCommand("which detekt")
                installedTools.append("detekt")
            } catch {
                #if DEBUG
                print("detekt not found")
                #endif
            }
            
            // Android lint is available if Android SDK is installed
            do {
                let _ = try await systemRepository.executeCommand("which adb")
                installedTools.append("android-lint")
            } catch {
                #if DEBUG
                print("Android SDK not found")
                #endif
            }
            
        case .flutter:
            // Check dart analyzer
            do {
                let _ = try await systemRepository.executeCommand("which dart")
                installedTools.append("dart-analyze")
                installedTools.append("dart-format")
            } catch {
                #if DEBUG
                print("Dart not found")
                #endif
            }
            
            // Check flutter test
            do {
                let _ = try await systemRepository.executeCommand("which flutter")
                installedTools.append("flutter-test")
            } catch {
                #if DEBUG
                print("Flutter not found")
                #endif
            }
            
        case .python:
            // Check common Python tools
            do {
                let _ = try await systemRepository.executeCommand("which black")
                installedTools.append("black")
            } catch {
                #if DEBUG
                print("black not found")
                #endif
            }
            
            do {
                let _ = try await systemRepository.executeCommand("which flake8")
                installedTools.append("flake8")
            } catch {
                #if DEBUG
                print("flake8 not found")
                #endif
            }
            
            do {
                let _ = try await systemRepository.executeCommand("which mypy")
                installedTools.append("mypy")
            } catch {
                #if DEBUG
                print("mypy not found")
                #endif
            }
        }
        
        return installedTools
    }
    
    func installPreCommitTool() async throws {
        // Check if pre-commit is already installed
        if await isPreCommitToolInstalled() {
            #if DEBUG
            print("✅ Pre-commit is already installed")
            #endif
            return
        }
        
        #if DEBUG
        print("🔧 Installing pre-commit tool...")
        #endif
        
        // Check if Homebrew is available
        do {
            let _ = try await systemRepository.executeCommand("which brew")
            let result = try await systemRepository.executeCommand("brew install pre-commit")
            #if DEBUG
            print("✅ Pre-commit installed via Homebrew: \(result)")
            #endif
        } catch {
            // Try pip installation as fallback
            do {
                let result = try await systemRepository.executeCommand("pip3 install pre-commit")
                #if DEBUG
                print("✅ Pre-commit installed via pip: \(result)")
                #endif
            } catch {
                throw ProjectError.preCommitError("Failed to install pre-commit. Please install Homebrew or Python/pip first.")
            }
        }
    }
    
    func setupPreCommitHooks(_ enabledHooks: [PreCommitHook], for project: Project) async throws -> String {
        let projectPath = project.path
        
        // 1. Verify it's a git repository
        guard try await isGitRepository(at: projectPath) else {
            throw ProjectError.preCommitError("Project is not a Git repository")
        }
        
        // 2. Install pre-commit if needed
        if !(try await isPreCommitInstalled()) {
            try await installPreCommitTool()
        }
        
        // 3. Generate configuration
        let config = generatePreCommitConfig(from: enabledHooks)
        
        // 4. Write configuration file (always overwrite to ensure correct format)
        let configPath = "\(projectPath)/.pre-commit-config.yaml"
        try await writePreCommitConfig(config, to: configPath)
        #if DEBUG
        print("🔄 Pre-commit configuration updated at: \(configPath)")
        #endif
        
        // 5. Clean and reinstall hooks to ensure they use new configuration
        let cleanCommand = "cd \"\(projectPath)\" && pre-commit uninstall"
        try? await systemRepository.executeCommand(cleanCommand)
        
        let installCommand = "cd \"\(projectPath)\" && pre-commit install"
        let installResult = try await systemRepository.executeCommand(installCommand)
        
        // 6. Clean pre-commit cache to force refresh
        let cacheCleanCommand = "cd \"\(projectPath)\" && pre-commit clean"
        try? await systemRepository.executeCommand(cacheCleanCommand)
        
        // 7. Skip full test run during installation (too slow)
        // Just verify the installation was successful
        return "✅ Pre-commit hooks installed successfully!\n\nInstallation result:\n\(installResult)\n\n💡 Use 'Ejecutar Todos los Hooks' to test the configuration."
    }
    
    func getPreCommitStatus(for project: Project) async throws -> [HookStatus] {
        let projectPath = project.path
        
        // Check if pre-commit is installed in the project
        let configPath = "\(projectPath)/.pre-commit-config.yaml"
        guard FileManager.default.fileExists(atPath: configPath) else {
            return []
        }
        
        // First check if hooks are actually installed
        let hookInstallStatus = await checkHooksInstallation(at: projectPath)
        
        // Try to get hook status with better commands
        do {
            // Get configured hooks from config file
            let configuredHooks = try await getConfiguredHooks(at: configPath)
            
            // Check each hook individually
            var statuses: [HookStatus] = []
            
            for hookName in configuredHooks {
                let status = await checkIndividualHookStatus(hookName: hookName, projectPath: projectPath, isInstalled: hookInstallStatus)
                statuses.append(status)
            }
            
            return statuses
        } catch {
            #if DEBUG
            print("❌ Error getting pre-commit status: \(error)")
            #endif
            return []
        }
    }
    
    func runPreCommitHooks(for project: Project, hookIds: [String]? = nil) async throws -> String {
        let projectPath = project.path
        
        var command = "cd \"\(projectPath)\" && timeout 120 pre-commit run"
        
        if let hookIds = hookIds, !hookIds.isEmpty {
            command += " " + hookIds.joined(separator: " ")
        } else {
            command += " --all-files"
        }
        
        do {
            let result = try await systemRepository.executeCommand(command)
            return "✅ Pre-commit hooks executed successfully!\n\n\(result)"
        } catch {
            // Check if it's a timeout error
            let errorOutput = error.localizedDescription
            if errorOutput.contains("timeout") || errorOutput.contains("timed out") {
                return "⏰ Pre-commit execution timed out (after 2 minutes).\n\nThis can happen if:\n• SwiftLint/SwiftFormat is processing many files\n• iOS build check is running a full build\n• Network issues downloading dependencies\n\nTry running individual hooks or check project size.\n\nPartial output:\n\(errorOutput)"
            }
            
            // Pre-commit returns non-zero exit code when hooks fail, but that's expected
            // We still want to show the output
            return "⚠️ Some hooks failed (this might be expected):\n\n\(errorOutput)"
        }
    }
    
    func uninstallPreCommitHooks(for project: Project) async throws -> String {
        let projectPath = project.path
        
        // Remove pre-commit hooks
        let uninstallCommand = "cd \"\(projectPath)\" && pre-commit uninstall"
        let result = try await systemRepository.executeCommand(uninstallCommand)
        
        // Optionally remove config file
        let configPath = "\(projectPath)/.pre-commit-config.yaml"
        if FileManager.default.fileExists(atPath: configPath) {
            try FileManager.default.removeItem(atPath: configPath)
        }
        
        return "✅ Pre-commit hooks uninstalled successfully!\n\n\(result)"
    }
    
    // MARK: - Helper Methods
    
    private func isGitRepository(at path: String) async throws -> Bool {
        let command = "cd \"\(path)\" && git status"
        do {
            let _ = try await systemRepository.executeCommand(command)
            return true
        } catch {
            return false
        }
    }
    
    private func generatePreCommitConfig(from hooks: [PreCommitHook]) -> PreCommitConfig {
        // Group hooks by repository
        let groupedHooks = Dictionary(grouping: hooks) { $0.repo }
        
        let repos = groupedHooks.map { (repo, hooksInRepo) -> PreCommitRepo in
            let rev = repo == "local" ? "" : (hooksInRepo.first?.rev ?? "main")
            let hookConfigs = hooksInRepo.map { hook in
                PreCommitHookConfig(
                    id: hook.hookId,
                    name: repo == "local" ? hook.name : nil, // Name required for local hooks
                    entry: repo == "local" ? generateEntryForLocalHook(hook) : nil,
                    language: repo == "local" ? "system" : nil,
                    args: hook.args.isEmpty ? nil : hook.args,
                    files: nil,
                    excludeFiles: nil
                )
            }
            
            return PreCommitRepo(repo: repo, rev: rev, hooks: hookConfigs)
        }
        
        return PreCommitConfig(repos: repos)
    }
    
    private func generateEntryForLocalHook(_ hook: PreCommitHook) -> String {
        switch hook.hookId {
        case "ios-build-check":
            // iOS build check with proper wildcard expansion and error handling
            return "bash -c 'WORKSPACE=$(find . -maxdepth 1 -name \"*.xcworkspace\" | head -1); if [ -n \"$WORKSPACE\" ]; then SCHEME=$(xcodebuild -list -workspace \"$WORKSPACE\" 2>/dev/null | grep -A 1000 \"Schemes:\" | grep -v \"Schemes:\" | head -1 | sed \"s/^[ ]*//\"); echo \"Building workspace $WORKSPACE with scheme $SCHEME\"; xcodebuild -workspace \"$WORKSPACE\" -scheme \"$SCHEME\" clean build CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY=\"\" PROVISIONING_PROFILE=\"\" 2>&1 | tail -20; else PROJECT=$(find . -maxdepth 1 -name \"*.xcodeproj\" | head -1); if [ -n \"$PROJECT\" ]; then SCHEME=$(xcodebuild -list -project \"$PROJECT\" 2>/dev/null | grep -A 1000 \"Schemes:\" | grep -v \"Schemes:\" | head -1 | sed \"s/^[ ]*//\"); echo \"Building project $PROJECT with scheme $SCHEME\"; xcodebuild -project \"$PROJECT\" -scheme \"$SCHEME\" clean build CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY=\"\" PROVISIONING_PROFILE=\"\" 2>&1 | tail -20; else echo \"No Xcode project or workspace found\"; exit 1; fi; fi'"
        case "android-lint":
            return "./gradlew lint"
        case "flutter-test":
            return "flutter test"
        default:
            return "echo 'Custom hook: \(hook.name)'"
        }
    }
    
    private func writePreCommitConfig(_ config: PreCommitConfig, to path: String) async throws {
        let yaml = try generateYAMLString(from: config)
        
        do {
            try yaml.write(toFile: path, atomically: true, encoding: .utf8)
            #if DEBUG
            print("✅ Pre-commit config written to: \(path)")
            #endif
        } catch {
            throw ProjectError.preCommitError("Failed to write configuration file: \(error.localizedDescription)")
        }
    }
    
    private func generateYAMLString(from config: PreCommitConfig) throws -> String {
        var yaml = "# Pre-commit configuration generated by Gula\n"
        yaml += "# See https://pre-commit.com for more information\n\n"
        
        if let stages = config.defaultStages {
            yaml += "default_stages: [\(stages.map { "'\($0)'" }.joined(separator: ", "))]\n\n"
        }
        
        yaml += "repos:\n"
        
        for repo in config.repos {
            yaml += "  - repo: \(repo.repo)\n"
            if !repo.rev.isEmpty && repo.repo != "local" {
                yaml += "    rev: \(repo.rev)\n"
            }
            yaml += "    hooks:\n"
            
            for hook in repo.hooks {
                yaml += "      - id: \(hook.id)\n"
                
                if let name = hook.name {
                    yaml += "        name: \(name)\n"
                }
                
                if let entry = hook.entry {
                    yaml += "        entry: \(entry)\n"
                }
                
                if let language = hook.language {
                    yaml += "        language: \(language)\n"
                }
                
                if let args = hook.args, !args.isEmpty {
                    yaml += "        args: [\(args.map { "'\($0)'" }.joined(separator: ", "))]\n"
                }
                
                if let files = hook.files {
                    yaml += "        files: '\(files)'\n"
                }
                
                if let exclude = hook.excludeFiles {
                    yaml += "        exclude: '\(exclude)'\n"
                }
            }
            yaml += "\n"
        }
        
        return yaml
    }
    
    private func checkHooksInstallation(at projectPath: String) async -> Bool {
        do {
            let command = "cd \"\(projectPath)\" && pre-commit --version"
            let _ = try await systemRepository.executeCommand(command)
            
            // Check if hooks are installed in git
            let gitHookCommand = "cd \"\(projectPath)\" && ls -la .git/hooks/ | grep pre-commit"
            let _ = try await systemRepository.executeCommand(gitHookCommand)
            
            return true
        } catch {
            #if DEBUG
            print("❌ Pre-commit hooks not properly installed: \(error)")
            #endif
            return false
        }
    }
    
    private func getConfiguredHooks(at configPath: String) async throws -> [String] {
        let content = try String(contentsOfFile: configPath, encoding: .utf8)
        let lines = content.components(separatedBy: .newlines)
        var hooks: [String] = []
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if trimmedLine.hasPrefix("- id:") {
                let hookId = trimmedLine.replacingOccurrences(of: "- id:", with: "").trimmingCharacters(in: .whitespaces)
                hooks.append(hookId)
            }
        }
        
        return hooks
    }
    
    private func checkIndividualHookStatus(hookName: String, projectPath: String, isInstalled: Bool) async -> HookStatus {
        guard isInstalled else {
            return HookStatus(
                hookName: hookName,
                isInstalled: false,
                isWorking: false,
                lastRun: nil,
                lastRunDuration: nil,
                lastError: "Pre-commit hooks not installed"
            )
        }
        
        // Check if the specific tool is available
        let isToolAvailable = await checkToolAvailability(for: hookName, projectPath: projectPath)
        
        do {
            let startTime = Date()
            let command = "cd \"\(projectPath)\" && pre-commit run \(hookName) --all-files --verbose"
            let result = try await systemRepository.executeCommand(command)
            let duration = Date().timeIntervalSince(startTime)
            
            let isWorking = result.contains("Passed") || result.contains("Skipped") || result.contains("passed") || result.contains("skipped")
            
            return HookStatus(
                hookName: hookName,
                isInstalled: true,
                isWorking: isWorking && isToolAvailable,
                lastRun: Date(),
                lastRunDuration: duration,
                lastError: isWorking && isToolAvailable ? nil : "Hook failed or tool not available"
            )
        } catch {
            return HookStatus(
                hookName: hookName,
                isInstalled: true,
                isWorking: false,
                lastRun: Date(),
                lastRunDuration: nil,
                lastError: error.localizedDescription
            )
        }
    }
    
    private func checkToolAvailability(for hookName: String, projectPath: String) async -> Bool {
        let toolCommands: [String: String] = [
            "swiftlint": "which swiftlint",
            "swiftformat": "which swiftformat",
            "ktlint": "which ktlint",
            "detekt": "which detekt",
            "dartanalyze": "which dart",
            "dartfmt": "which dart"
        ]
        
        guard let command = toolCommands[hookName] else {
            // For custom or unknown hooks, assume they're available
            return true
        }
        
        do {
            let _ = try await systemRepository.executeCommand(command)
            #if DEBUG
            print("✅ Tool \(hookName) is available")
            #endif
            return true
        } catch {
            #if DEBUG
            print("⚠️ Tool \(hookName) not found in PATH")
            #endif
            return false
        }
    }
    
    private func parseHookStatus(from output: String) -> [HookStatus] {
        // Legacy parser - kept for compatibility
        let lines = output.components(separatedBy: .newlines)
        var statuses: [HookStatus] = []
        
        for line in lines {
            if line.contains("...") {
                let components = line.components(separatedBy: "...")
                if components.count >= 2 {
                    let hookName = components[0].trimmingCharacters(in: .whitespaces)
                    let result = components[1].trimmingCharacters(in: .whitespaces)
                    
                    let isWorking = result.lowercased().contains("passed") || result.lowercased().contains("skipped")
                    let lastError = isWorking ? nil : result
                    
                    let status = HookStatus(
                        hookName: hookName,
                        isInstalled: true,
                        isWorking: isWorking,
                        lastRun: Date(),
                        lastRunDuration: nil,
                        lastError: lastError
                    )
                    
                    statuses.append(status)
                }
            }
        }
        
        return statuses
    }
    
    // MARK: - Individual Hook Selection Management
    
    private func getHookSelectionKey(for project: Project) -> String {
        return "precommit_selected_hooks_\(project.path.replacingOccurrences(of: "/", with: "_"))"
    }
    
    func getSelectedHooks(for project: Project) -> Set<String> {
        let key = getHookSelectionKey(for: project)
        let savedHooks = UserDefaults.standard.stringArray(forKey: key) ?? []
        return Set(savedHooks)
    }
    
    func setSelectedHooks(_ hookIds: Set<String>, for project: Project) {
        let key = getHookSelectionKey(for: project)
        UserDefaults.standard.set(Array(hookIds), forKey: key)
    }
    
    func toggleHookSelection(_ hookId: String, for project: Project) {
        var selectedHooks = getSelectedHooks(for: project)
        if selectedHooks.contains(hookId) {
            selectedHooks.remove(hookId)
        } else {
            selectedHooks.insert(hookId)
        }
        setSelectedHooks(selectedHooks, for: project)
    }
    
    func setupSelectedPreCommitHooks(for project: Project) async throws -> String {
        let selectedHookIds = getSelectedHooks(for: project)
        let availableHooks = PreCommitHook.availableHooks(for: project.type)
        let selectedHooks = availableHooks.filter { selectedHookIds.contains($0.id) }
        
        if selectedHooks.isEmpty {
            throw ProjectError.preCommitError("No hooks selected for configuration")
        }
        
        return try await setupPreCommitHooks(selectedHooks, for: project)
    }
    
    func getAvailableHooksWithSelection(for project: Project) -> [PreCommitHook] {
        let selectedHookIds = getSelectedHooks(for: project)
        return PreCommitHook.availableHooksWithSelection(for: project.type, selectedHookIds: selectedHookIds)
    }
    
    // MARK: - Gula Branches Integration
    
    func getAvailableBranches(apiKey: String, for project: Project) async throws -> [String] {
        guard !apiKey.isEmpty else {
            throw ProjectError.invalidAPIKey("API key is required to fetch branches")
        }
        
        let projectPath = project.path
        let command = "cd \"\(projectPath)\" && gula branches --key=\(apiKey)"
        
        do {
            let result = try await systemRepository.executeCommand(command)
            #if DEBUG
            print("🌿 Branch command result for project \(project.name): \(result)")
            #endif
            
            // Verificar si la respuesta contiene errores de API key
            if result.contains("❌ Error") || result.contains("KEY incorrecta") || result.contains("no autorizada") {
                throw ProjectError.invalidAPIKey("Invalid API key or unauthorized access")
            }
            
            return parseBranchesFromOutput(result)
        } catch {
            #if DEBUG
            print("❌ Error obteniendo ramas para proyecto \(project.name): \(error)")
            #endif
            throw error
        }
    }
    
    private func parseBranchesFromOutput(_ output: String) -> [String] {
        let lines = output.components(separatedBy: .newlines)
        var branches: [String] = []
        var foundBranchSection = false
        
        for line in lines {
            // Clean ANSI escape sequences and trim
            let cleanedLine = cleanANSIEscapeCodes(line).trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Look for the branches section marker
            if cleanedLine.contains("Ramas disponibles para") {
                foundBranchSection = true
                continue
            }
            
            // Skip separator lines and empty lines
            if cleanedLine.isEmpty || 
               cleanedLine.hasPrefix("-------") ||
               cleanedLine.hasPrefix("====") ||
               cleanedLine.contains("██") ||
               cleanedLine.contains("╗") ||
               cleanedLine.contains("╝") ||
               cleanedLine.contains("╚") ||
               cleanedLine.contains("versión:") ||
               cleanedLine.contains("propiedad:") ||
               cleanedLine.contains("Cargando prerequisitos") ||
               cleanedLine.contains("Detectado proyecto") ||
               cleanedLine.contains("Obtención del código") {
                continue
            }
            
            // If we're in the branch section
            if foundBranchSection && !cleanedLine.isEmpty {
                // Stop if we hit another separator
                if cleanedLine.hasPrefix("-------") {
                    break
                }
                
                // Validate that this looks like a branch name (no special symbols, reasonable length)
                if isBranchName(cleanedLine) {
                    branches.append(cleanedLine)
                }
            }
        }
        
        #if DEBUG
        print("🌿 Parsed branches: \(branches)")
        #endif
        return branches
    }
    
    private func cleanANSIEscapeCodes(_ text: String) -> String {
        // Remove ANSI escape sequences like [1m, [0m, etc.
        let ansiPattern = "\\[[0-9;]*m"
        return text.replacingOccurrences(of: ansiPattern, with: "", options: .regularExpression)
    }
    
    private func isBranchName(_ text: String) -> Bool {
        // Basic validation for branch names
        // Should not be empty, not contain ASCII art characters, and be reasonable length
        guard !text.isEmpty && text.count > 0 && text.count < 100 else { return false }
        
        // Should not contain box drawing characters or other special symbols
        let invalidChars = CharacterSet(charactersIn: "██╗╚╝═─│┌┐└┘├┤┬┴┼")
        if text.rangeOfCharacter(from: invalidChars) != nil {
            return false
        }
        
        // Should look like a valid git branch name pattern
        let branchPattern = "^[a-zA-Z0-9._/-]+$"
        return text.range(of: branchPattern, options: .regularExpression) != nil
    }
}
