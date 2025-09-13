import SwiftUI
import Foundation

struct PreCommitManagerView: View {
    let project: Project
    @ObservedObject var projectManager: ProjectManager
    
    @State private var projectStatus: PreCommitProjectStatus?
    @State private var installedTools: [String] = []
    @State private var isLoading = true
    @State private var installingTools: Set<String> = []
    @State private var isInstallingPreCommit = false
    @State private var isCreatingConfig = false
    @State private var isInstallingHooks = false
    @State private var selectedHooks: Set<String> = []
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.blue)
                        
                        Text("Pre-commit Hooks")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text("Ejecuta validaciones automáticas antes de cada commit en \(project.name)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                
                // Status Card
                statusCard
                
                
                // Project Status Details
                if let status = projectStatus {
                    projectStatusCard(status)
                }
                
                // Hook Selection Section  
                if !availableHooksWithSelection.isEmpty {
                    hookSelectionCard
                }
                
                Spacer(minLength: 20)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
        }
        .onAppear {
            print("🎯 PreCommitManagerView apareció para proyecto: \(project.name)")
            print("🎯 Tipo de proyecto detectado: \(project.type.displayName)")
            print("🎯 Hooks disponibles para \(project.type.displayName): \(PreCommitHook.availableHooks(for: project.type).count)")
            selectedHooks = projectManager.getSelectedHooks(for: project)
            Task {
                await checkStatus()
            }
        }
    }
    
    private var statusCard: some View {
        let status = projectStatus
        let isConfigured = status?.isFullyConfigured ?? false
        let statusColor: Color = {
            switch status?.statusLevel {
            case .configured: return .green
            case .partiallyConfigured: return .orange
            case .notConfigured, .none: return .red
            }
        }()
        
        return VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Status Icon
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: isConfigured ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(statusColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(statusTitle(for: status))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(status?.statusMessage ?? "Verificando estado...")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            HStack {
                Text("Proyecto: \(project.name)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(project.type.displayName)
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(project.type.accentColor.opacity(0.1))
                    .foregroundColor(project.type.accentColor)
                    .clipShape(Capsule())
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    
    
    private var availableHooksWithSelection: [PreCommitHook] {
        return projectManager.getAvailableHooksWithSelection(for: project)
    }
    
    
    private var hookSelectionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.green)
                
                Text("Seleccionar Hooks de Pre-commit")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(availableHooksWithSelection.count) hooks disponibles")
                    .font(.system(size: 12, weight: .medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.green.opacity(0.1))
                    .foregroundColor(.green)
                    .clipShape(Capsule())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Selecciona los hooks que deseas configurar para tu proyecto. Puedes elegir específicamente cuáles instalar.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "laptopcomputer")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                        Text("Proyecto: \(project.type.displayName)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.blue)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                        Text("Seleccionados: \(selectedHooks.count)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.blue)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "wrench.and.screwdriver")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                        Text("Disponibles: \(availableHooksWithSelection.count)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                }
                
                if availableHooksWithSelection.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Text("No hay hooks configurados para \(project.type.displayName). Verifica el tipo de proyecto.")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // All available hooks grid with selection
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(availableHooksWithSelection) { tool in
                    SelectableToolCard(
                        hook: tool,
                        isInstalling: installingTools.contains(tool.id),
                        isSelected: selectedHooks.contains(tool.id),
                        isInstalled: installedTools.contains(tool.id),
                        onToggleSelection: { 
                            if selectedHooks.contains(tool.id) {
                                selectedHooks.remove(tool.id)
                            } else {
                                selectedHooks.insert(tool.id)
                            }
                            projectManager.toggleHookSelection(tool.id, for: project)
                        },
                        onInstall: { await installTool(tool) }
                    )
                }
            }
            
            // Apply Configuration Button (only show if hooks are selected)
            if !selectedHooks.isEmpty {                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Configuración Lista")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("\(selectedHooks.count) hook(s) seleccionados para configurar")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            await createPreCommitConfig()
                        }
                    }) {
                        HStack(spacing: 8) {
                            if isCreatingConfig {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "gear")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            
                            Text(isCreatingConfig ? "Configurando..." : "Aplicar Configuración")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    .disabled(isCreatingConfig)
                }
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private func toolDisplayName(_ toolId: String) -> String {
        switch toolId {
        case "swiftlint": return "SwiftLint"
        case "swiftformat": return "SwiftFormat"
        case "ios-build-check": return "iOS Build Check"
        case "ktlint": return "ktlint"
        case "detekt": return "detekt"
        case "android-lint": return "Android Lint"
        case "android-build-check": return "Android Build Check"
        case "dart-analyze": return "Dart Analyze"
        case "dart-format": return "Dart Format"
        case "flutter-test": return "Flutter Test"
        case "black": return "Black"
        case "flake8": return "Flake8"
        case "mypy": return "MyPy"
        default: return toolId
        }
    }
    
    
    @MainActor
    private func checkStatus() async {
        isLoading = true
        
        // Get comprehensive project status
        projectStatus = await projectManager.getPreCommitProjectStatus(project)
        
        // Check available tools for this project type
        installedTools = await projectManager.getInstalledHookTools(for: project.type)
        
        print("🔧 Herramientas instaladas para \(project.type.displayName): \(installedTools)")
        print("🔧 Hooks disponibles: \(PreCommitHook.availableHooks(for: project.type).map { $0.name })")
        print("🔧 Hooks seleccionados: \(selectedHooks)")
        
        isLoading = false
    }
    
    private func statusTitle(for status: PreCommitProjectStatus?) -> String {
        switch status?.statusLevel {
        case .configured:
            return "Pre-commit Configurado"
        case .partiallyConfigured:
            return "Configuración Parcial"
        case .notConfigured, .none:
            return "Pre-commit No Configurado"
        }
    }
    
    private func projectStatusCard(_ status: PreCommitProjectStatus) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Estado Detallado del Proyecto")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                statusRowWithAction(
                    title: "Pre-commit Tool",
                    isEnabled: status.toolInstalled,
                    description: status.toolInstalled ? "Instalado globalmente" : "Necesita instalación global",
                    actionTitle: status.toolInstalled ? nil : (isInstallingPreCommit ? "Instalando..." : "Instalar pre-commit"),
                    isLoading: isInstallingPreCommit,
                    action: status.toolInstalled ? nil : { 
                        isInstallingPreCommit = true
                        await installPreCommitTool()
                        isInstallingPreCommit = false
                    }
                )
                
                statusRowWithAction(
                    title: "Configuración del Proyecto",
                    isEnabled: status.configExists,
                    description: status.configExists ? ".pre-commit-config.yaml existe" : "Falta archivo de configuración",
                    actionTitle: status.configExists ? nil : (isCreatingConfig ? "Creando..." : "Crear configuración"),
                    isLoading: isCreatingConfig,
                    action: status.configExists ? nil : { 
                        isCreatingConfig = true
                        await createPreCommitConfig()
                        isCreatingConfig = false
                    }
                )
                
                statusRowWithAction(
                    title: "Hooks Git Instalados",
                    isEnabled: status.hooksInstalled,
                    description: status.hooksInstalled ? "Hooks activos en .git/hooks/" : "Ejecutar 'pre-commit install'",
                    actionTitle: status.hooksInstalled ? nil : (isInstallingHooks ? "Instalando..." : "Instalar hooks"),
                    isLoading: isInstallingHooks,
                    action: status.hooksInstalled ? nil : { 
                        isInstallingHooks = true
                        await installPreCommitHooks()
                        isInstallingHooks = false
                    }
                )
                
                if !status.configuredHooks.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hooks Configurados (\(status.configuredHooks.count))")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        HStack {
                            ForEach(status.configuredHooks.prefix(3), id: \.self) { hook in
                                Text(hook)
                                    .font(.system(size: 12, weight: .medium))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .clipShape(Capsule())
                            }
                            
                            if status.configuredHooks.count > 3 {
                                Text("+\(status.configuredHooks.count - 3)")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private func statusRowWithAction(
        title: String, 
        isEnabled: Bool, 
        description: String,
        actionTitle: String? = nil,
        isLoading: Bool = false,
        action: (() async -> Void)? = nil
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: isEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isEnabled ? .green : .red)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Action button if needed
            if let actionTitle = actionTitle, let action = action {
                Button(action: {
                    Task {
                        await action()
                    }
                }) {
                    HStack(spacing: 8) {
                        if isLoading {
                            ZStack {
                                // Pulsing background circle
                                Circle()
                                    .fill(.white.opacity(0.3))
                                    .frame(width: 12, height: 12)
                                    .scaleEffect(isLoading ? 1.3 : 0.7)
                                    .opacity(isLoading ? 0.2 : 0.8)
                                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isLoading)
                                
                                // Rotating progress indicator
                                ProgressView()
                                    .scaleEffect(0.6)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .rotationEffect(.degrees(isLoading ? 360 : 0))
                                    .animation(.linear(duration: 1.8).repeatForever(autoreverses: false), value: isLoading)
                            }
                        } else {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 10, weight: .semibold))
                                .scaleEffect(1.0)
                                .animation(.easeInOut(duration: 0.2), value: isLoading)
                        }
                        
                        Text(actionTitle)
                            .font(.system(size: 12, weight: .semibold))
                            .animation(.easeInOut(duration: 0.3), value: isLoading)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        ZStack {
                            // Base gradient
                            LinearGradient(
                                colors: isLoading ? 
                                    [.gray, .gray.opacity(0.8)] :
                                    [.blue, .blue.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            
                            // Animated shimmer effect during loading
                            if isLoading {
                                LinearGradient(
                                    colors: [.clear, .white.opacity(0.3), .clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .offset(x: isLoading ? 80 : -80)
                                .animation(.linear(duration: 1.8).repeatForever(autoreverses: false), value: isLoading)
                            }
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .scaleEffect(isLoading ? 0.98 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isLoading)
                }
                .buttonStyle(.plain)
                .disabled(isLoading)
            }
        }
    }
    
    @MainActor
    private func installTool(_ hook: PreCommitHook) async {
        let command = installCommand(for: hook.id)
        
        // Mark as installing
        installingTools.insert(hook.id)
        
        // Show installation method based on tool
        if command.contains("brew install") || command.contains("pip install") {
            await executeInstallCommand(command, for: hook)
        } else if command == "Incluido con Xcode" || command == "Incluido con Flutter SDK" {
            // Show alert for tools already included
            showToolIncludedAlert(hook.name, with: command)
            installingTools.remove(hook.id)
        } else {
            openTerminalWithCommand(command)
            // For generic commands, wait and check after some time
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            await checkInstallationSuccess(for: hook.id)
        }
    }
    
    @MainActor
    private func executeInstallCommand(_ command: String, for hook: PreCommitHook) async {
        // Execute the command
        openTerminalWithCommand(command)
        
        // Wait for installation to potentially complete
        try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
        
        // Check if tool was installed
        await checkInstallationSuccess(for: hook.id)
    }
    
    @MainActor
    private func checkInstallationSuccess(for toolId: String) async {
        // Re-check installed tools
        let updatedTools = await projectManager.getInstalledHookTools(for: project.type)
        
        if updatedTools.contains(toolId) {
            // Tool was installed successfully
            installedTools = updatedTools
            showInstallationSuccess(for: toolId)
        } else {
            // Show option to check manually or try again
            showInstallationCheckDialog(for: toolId)
        }
        
        installingTools.remove(toolId)
    }
    
    private func showInstallationSuccess(for toolId: String) {
        let alert = NSAlert()
        alert.messageText = "¡Instalación exitosa!"
        alert.informativeText = "\(toolDisplayName(toolId)) se ha instalado correctamente."
        alert.addButton(withTitle: "Perfecto")
        alert.alertStyle = .informational
        
        DispatchQueue.main.async {
            alert.runModal()
        }
    }
    
    private func showInstallationCheckDialog(for toolId: String) {
        let alert = NSAlert()
        alert.messageText = "Verificar instalación"
        alert.informativeText = "La instalación de \(toolDisplayName(toolId)) puede estar en progreso. ¿Quieres verificar de nuevo?"
        alert.addButton(withTitle: "Verificar")
        alert.addButton(withTitle: "Más tarde")
        alert.alertStyle = .informational
        
        DispatchQueue.main.async {
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                Task {
                    await self.checkInstallationSuccess(for: toolId)
                }
            } else {
                self.installingTools.remove(toolId)
            }
        }
    }
    
    private func openTerminalWithCommand(_ command: String) {
        let script = """
        tell application "Terminal"
            activate
            do script "\(command)"
        end tell
        """
        
        if let appleScript = NSAppleScript(source: script) {
            var error: NSDictionary?
            appleScript.executeAndReturnError(&error)
            if let error = error {
                print("Error ejecutando AppleScript: \(error)")
            }
        }
    }
    
    private func showToolIncludedAlert(_ toolName: String, with message: String) {
        let alert = NSAlert()
        alert.messageText = "\(toolName) ya disponible"
        alert.informativeText = message
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .informational
        alert.runModal()
    }
    
    private func installCommand(for hookId: String) -> String {
        switch hookId {
        // iOS tools
        case "swiftlint":
            return "brew install swiftlint"
        case "swiftformat":
            return "brew install swiftformat"
        case "ios-build-check":
            return "Incluido con Xcode"
        // Android tools
        case "ktlint":
            return "brew install ktlint"
        case "detekt":
            return "brew install detekt"
        case "android-lint":
            return "Instalar Android SDK"
        case "android-build-check":
            return "Incluido con Android SDK"
        // Flutter tools
        case "dart-analyze", "dart-format":
            return "Incluido con Flutter SDK"
        case "flutter-test":
            return "flutter doctor"
        // Python tools
        case "black":
            return "pip install black"
        case "flake8":
            return "pip install flake8"
        case "mypy":
            return "pip install mypy"
        default:
            return "Ver documentación"
        }
    }
    
    @MainActor
    private func installPreCommitTool() async {
        do {
            try await projectManager.installPreCommitTool()
            
            // Show success alert
            let alert = NSAlert()
            alert.messageText = "¡Pre-commit instalado!"
            alert.informativeText = "Pre-commit se ha instalado correctamente usando pip."
            alert.addButton(withTitle: "Perfecto")
            alert.alertStyle = .informational
            alert.runModal()
            
            // Refresh status
            await checkStatus()
        } catch {
            // Show error alert
            let alert = NSAlert()
            alert.messageText = "Error al instalar pre-commit"
            alert.informativeText = "Error: \(error.localizedDescription)"
            alert.addButton(withTitle: "OK")
            alert.alertStyle = .warning
            alert.runModal()
        }
    }
    
    @MainActor
    private func createPreCommitConfig() async {
        // Check if user has selected any hooks
        if selectedHooks.isEmpty {
            // Show message asking user to select hooks first
            let alert = NSAlert()
            alert.messageText = "Selecciona hooks primero"
            alert.informativeText = "Por favor, selecciona al menos un hook de la lista antes de crear la configuración."
            alert.addButton(withTitle: "OK")
            alert.alertStyle = .informational
            alert.runModal()
            return
        }
        
        isCreatingConfig = true
        
        do {
            // Use selected hooks instead of all hooks
            let hooksToSetup = availableHooksWithSelection.filter { selectedHooks.contains($0.id) }
            _ = try await projectManager.setupPreCommitHooks(hooksToSetup, for: project)
            
            // Show success alert
            let alert = NSAlert()
            alert.messageText = "¡Configuración creada!"
            alert.informativeText = "Se ha creado .pre-commit-config.yaml con \(hooksToSetup.count) hook(s) seleccionados."
            alert.addButton(withTitle: "Perfecto")
            alert.alertStyle = .informational
            alert.runModal()
            
            // Refresh status
            await checkStatus()
        } catch {
            // Show error alert
            let alert = NSAlert()
            alert.messageText = "Error al crear configuración"
            alert.informativeText = "Error: \(error.localizedDescription)"
            alert.addButton(withTitle: "OK")
            alert.alertStyle = .warning
            alert.runModal()
        }
        
        isCreatingConfig = false
    }
    
    @MainActor
    private func installPreCommitHooks() async {
        do {
            _ = try await projectManager.executeCommand("cd \"\(project.path)\" && pre-commit install")
            
            // Show success alert
            let alert = NSAlert()
            alert.messageText = "¡Hooks instalados!"
            alert.informativeText = "Los hooks de pre-commit han sido instalados en el repositorio Git."
            alert.addButton(withTitle: "Perfecto")
            alert.alertStyle = .informational
            alert.runModal()
            
            // Refresh status
            await checkStatus()
        } catch {
            // Show error alert
            let alert = NSAlert()
            alert.messageText = "Error al instalar hooks"
            alert.informativeText = "Error: \(error.localizedDescription)"
            alert.addButton(withTitle: "OK")
            alert.alertStyle = .warning
            alert.runModal()
        }
    }
}

#Preview {
    let sampleProject = Project(
        name: "Sample iOS Project",
        path: "/Users/sample/ios-project",
        type: .ios
    )
    
    PreCommitManagerView(
        project: sampleProject,
        projectManager: ProjectManager.shared
    )
    .frame(width: 800, height: 600)
}

// MARK: - Selectable Tool Card

struct SelectableToolCard: View {
    let hook: PreCommitHook
    let isInstalling: Bool
    let isSelected: Bool
    let isInstalled: Bool
    let onToggleSelection: () -> Void
    let onInstall: () async -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Tool Header with selection checkbox
            HStack(spacing: 8) {
                // Selection checkbox
                Button(action: onToggleSelection) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isSelected ? .blue : .gray)
                }
                .buttonStyle(.plain)
                
                Image(systemName: hook.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(categoryColor)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(hook.name)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(hook.category.rawValue)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(categoryColor)
                        .textCase(.uppercase)
                }
                
                Spacer()
            }
            
            // Description
            Text(hook.description)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // Status and Installation section
            HStack(spacing: 8) {
                // Installed status badge
                if isInstalled {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.green)
                        
                        Text("Instalado")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .strokeBorder(.green.opacity(0.3), lineWidth: 1)
                    )
                }
                
                // Configured status badge
                if isSelected {
                    HStack(spacing: 6) {
                        Image(systemName: "gear.circle.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.blue)
                        
                        Text("Configurado")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .strokeBorder(.blue.opacity(0.3), lineWidth: 1)
                    )
                }
                
                Spacer()
                
                // Installation button (only if not installed)
                if !isInstalled {
                // Installation button
                Button(action: {
                    Task {
                        await onInstall()
                    }
                }) {
                HStack(spacing: 8) {
                    if isInstalling {
                        ZStack {
                            // Pulsing background circle
                            Circle()
                                .fill(.white.opacity(0.3))
                                .frame(width: 16, height: 16)
                                .scaleEffect(isInstalling ? 1.2 : 0.8)
                                .opacity(isInstalling ? 0.3 : 0.8)
                                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isInstalling)
                            
                            // Rotating progress indicator
                            ProgressView()
                                .scaleEffect(0.7)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .rotationEffect(.degrees(isInstalling ? 360 : 0))
                                .animation(.linear(duration: 2.0).repeatForever(autoreverses: false), value: isInstalling)
                        }
                    } else {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .scaleEffect(1.0)
                            .animation(.easeInOut(duration: 0.2), value: isInstalling)
                    }
                    
                    Text(isInstalling ? "Instalando..." : "Instalar \(hook.name)")
                        .font(.system(size: 12, weight: .semibold))
                        .animation(.easeInOut(duration: 0.3), value: isInstalling)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    ZStack {
                        // Base gradient
                        LinearGradient(
                            colors: isInstalling ? 
                                [.gray, .gray.opacity(0.8)] :
                                [categoryColor, categoryColor.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        // Animated shimmer effect during installation
                        if isInstalling {
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.2), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .offset(x: isInstalling ? 100 : -100)
                            .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: isInstalling)
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .scaleEffect(isInstalling ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isInstalling)
                }
                .buttonStyle(.plain)
                .disabled(isInstalling)
                .help(isInstalling ? "Instalación en progreso..." : "Instalar \(hook.name) usando \(installCommand(for: hook.id))")
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(
                            LinearGradient(
                                colors: isSelected ? 
                                    [.blue.opacity(0.5), .blue.opacity(0.2)] :
                                    [categoryColor.opacity(0.3), categoryColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
        )
    }
    
    private var categoryColor: Color {
        switch hook.category {
        case .linting: return .blue
        case .formatting: return .green
        case .testing: return .orange
        case .security: return .red
        case .build: return .purple
        case .custom: return .gray
        }
    }
    
    private func installCommand(for hookId: String) -> String {
        switch hookId {
        // iOS tools
        case "swiftlint":
            return "brew install swiftlint"
        case "swiftformat":
            return "brew install swiftformat"
        case "ios-build-check":
            return "Incluido con Xcode"
        // Android tools
        case "ktlint":
            return "brew install ktlint"
        case "detekt":
            return "brew install detekt"
        case "android-lint":
            return "Instalar Android SDK"
        case "android-build-check":
            return "Incluido con Android SDK"
        // Flutter tools
        case "dart-analyze", "dart-format":
            return "Incluido con Flutter SDK"
        case "flutter-test":
            return "flutter doctor"
        // Python tools
        case "black":
            return "pip install black"
        case "flake8":
            return "pip install flake8"
        case "mypy":
            return "pip install mypy"
        default:
            return "Ver documentación"
        }
    }
}

// MARK: - Missing Tool Card

struct MissingToolCard: View {
    let hook: PreCommitHook
    let isInstalling: Bool
    let onInstall: () async -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Tool Header
            HStack(spacing: 8) {
                Image(systemName: hook.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(categoryColor)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(hook.name)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(hook.category.rawValue)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(categoryColor)
                        .textCase(.uppercase)
                }
                
                Spacer()
            }
            
            // Description
            Text(hook.description)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // Installation button
            Button(action: {
                Task {
                    await onInstall()
                }
            }) {
                HStack(spacing: 8) {
                    if isInstalling {
                        ZStack {
                            // Pulsing background circle
                            Circle()
                                .fill(.white.opacity(0.3))
                                .frame(width: 16, height: 16)
                                .scaleEffect(isInstalling ? 1.2 : 0.8)
                                .opacity(isInstalling ? 0.3 : 0.8)
                                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isInstalling)
                            
                            // Rotating progress indicator
                            ProgressView()
                                .scaleEffect(0.7)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .rotationEffect(.degrees(isInstalling ? 360 : 0))
                                .animation(.linear(duration: 2.0).repeatForever(autoreverses: false), value: isInstalling)
                        }
                    } else {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .scaleEffect(1.0)
                            .animation(.easeInOut(duration: 0.2), value: isInstalling)
                    }
                    
                    Text(isInstalling ? "Instalando..." : "Instalar \(hook.name)")
                        .font(.system(size: 12, weight: .semibold))
                        .animation(.easeInOut(duration: 0.3), value: isInstalling)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    ZStack {
                        // Base gradient
                        LinearGradient(
                            colors: isInstalling ? 
                                [.gray, .gray.opacity(0.8)] :
                                [categoryColor, categoryColor.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        // Animated shimmer effect during installation
                        if isInstalling {
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.2), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .offset(x: isInstalling ? 100 : -100)
                            .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: isInstalling)
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .scaleEffect(isInstalling ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isInstalling)
            }
            .buttonStyle(.plain)
            .disabled(isInstalling)
            .help(isInstalling ? "Instalación en progreso..." : "Instalar \(hook.name) usando \(installCommand(for: hook.id))")
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(
                            LinearGradient(
                                colors: [categoryColor.opacity(0.3), categoryColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
    
    private var categoryColor: Color {
        switch hook.category {
        case .linting: return .blue
        case .formatting: return .green
        case .testing: return .orange
        case .security: return .red
        case .build: return .purple
        case .custom: return .gray
        }
    }
    
    private func installCommand(for hookId: String) -> String {
        switch hookId {
        // iOS tools
        case "swiftlint":
            return "brew install swiftlint"
        case "swiftformat":
            return "brew install swiftformat"
        case "ios-build-check":
            return "Incluido con Xcode"
        // Android tools
        case "ktlint":
            return "brew install ktlint"
        case "detekt":
            return "brew install detekt"
        case "android-lint":
            return "Instalar Android SDK"
        case "android-build-check":
            return "Incluido con Android SDK"
        // Flutter tools
        case "dart-analyze", "dart-format":
            return "Incluido con Flutter SDK"
        case "flutter-test":
            return "flutter doctor"
        // Python tools
        case "black":
            return "pip install black"
        case "flake8":
            return "pip install flake8"
        case "mypy":
            return "pip install mypy"
        default:
            return "Ver documentación"
        }
    }
}

