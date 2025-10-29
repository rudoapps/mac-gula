import SwiftUI
import Foundation

@available(macOS 15.0, *)
struct ModuleManagerView: View {
    let project: Project
    @Bindable var projectManager: ProjectManager
    @Binding var isLoading: Bool
    @Binding var showingError: Bool
    @Binding var errorMessage: String

    @State private var apiKey: String = ""
    private let getUserApiKeyUseCase: GetUserApiKeyUseCaseProtocol

    @State private var branch: String = ""
    @State private var availableBranches: [String] = []
    @State private var isLoadingBranches = false
    @State private var moduleListOutput: String = ""
    @State private var availableModules: [Module] = []
    @State private var selectedModules: Set<Module> = []
    @State private var installingModules: Set<UUID> = []
    @State private var currentlyInstallingModule: String? = nil
    @State private var autoReplaceModules: Bool = true
    @State private var commandOutput: String = ""
    @State private var showingModuleList = false
    @State private var isLoadingModules = false
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var shimmerOffset: CGFloat = -1.0
    @State private var barAnimationTimer: Timer?
    @State private var barScales: [CGFloat] = [0.3, 0.7, 1.0, 0.5, 0.8]
    @State private var moduleDataSource = ModuleDataSource()
    
    // Gula Status Integration
    @State private var gulaStatus: GulaStatus?
    @State private var installedModuleNames: Set<String> = []
    @State private var installedModulesInfo: [String: String] = [:] // Maps module name to installed branch
    @State private var isLoadingGulaStatus = false
    @State private var statusLoadingProgress: Double = 0.0
    @State private var statusAnimationOffset: CGFloat = -1.0
    @State private var statusPulseScale: CGFloat = 1.0

    // Computed property to check if all selectable modules are selected
    private var isAllSelectableModulesSelected: Bool {
        let selectableModules = availableModules.filter { $0.installationStatus == .notInstalled }
        return !selectableModules.isEmpty && selectedModules.count == selectableModules.count
    }

    init(project: Project,
         projectManager: ProjectManager,
         isLoading: Binding<Bool>,
         showingError: Binding<Bool>,
         errorMessage: Binding<String>,
         getUserApiKeyUseCase: GetUserApiKeyUseCaseProtocol? = nil) {
        self.project = project
        self.projectManager = projectManager
        self._isLoading = isLoading
        self._showingError = showingError
        self._errorMessage = errorMessage

        // Dependency Injection for GetUserApiKeyUseCase
        if let useCase = getUserApiKeyUseCase {
            self.getUserApiKeyUseCase = useCase
        } else {
            // Default dependency injection if not provided
            let network = Config.shared.network
            let remoteDataSource = ApiKeyRemoteDataSource(network: network)
            let localDataSource = ApiKeyLocalDataSource()
            let repository = ApiKeyRepository(
                remoteDataSource: remoteDataSource,
                localDataSource: localDataSource
            )
            self.getUserApiKeyUseCase = GetUserApiKeyUseCase(repository: repository)
        }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 40) {
                // Professional Form Container
                ProfessionalFormContainer(
                    title: "Gestor de Módulos",
                    subtitle: "Explora e instala módulos prediseñados para acelerar tu desarrollo",
                    icon: "square.stack.3d.up",
                    gradientColors: [.blue, .cyan]
                ) {
                    VStack(spacing: 28) {
                        // API Key Status (read-only, loaded automatically)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient(colors: [.green.opacity(0.1), .green.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "key.fill")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.green)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Clave de API")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primary)
                                    if !apiKey.isEmpty {
                                        HStack(spacing: 6) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(.green)
                                            Text("Cargada automáticamente desde tu cuenta")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.secondary)
                                        }
                                    } else {
                                        HStack(spacing: 6) {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(.orange)
                                            Text("No disponible - Inicia sesión primero")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }

                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(.secondary.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }

                        // Enhanced Branch Selection
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient(colors: [.blue.opacity(0.1), .blue.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "arrow.triangle.branch")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.blue)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Branch del Repositorio")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primary)

                                    if isLoadingBranches {
                                        HStack(spacing: 6) {
                                            ProgressView()
                                                .scaleEffect(0.7)
                                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                            Text("Cargando ramas...")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.secondary)
                                        }
                                    } else if !availableBranches.isEmpty {
                                        HStack(spacing: 6) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(.blue)
                                            Text("\(availableBranches.count) ramas disponibles")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.secondary)
                                        }
                                    } else if apiKey.isEmpty {
                                        HStack(spacing: 6) {
                                            Image(systemName: "info.circle.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                            Text("Se cargarán automáticamente al iniciar sesión")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.secondary)
                                        }
                                    } else {
                                        HStack(spacing: 6) {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(.orange)
                                            Text("No se encontraron ramas disponibles")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }

                                Spacer()

                                // Picker inside the card
                                if !availableBranches.isEmpty {
                                    Picker("", selection: $branch) {
                                        ForEach(availableBranches, id: \.self) { branchName in
                                            Text(branchName).tag(branchName)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .labelsHidden()
                                    .onChange(of: branch) { oldValue, newValue in
                                        // Automatically load modules when branch changes
                                        if !newValue.isEmpty && oldValue != newValue {
                                            Task {
                                                await loadModules()
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(.secondary.opacity(0.2), lineWidth: 1)
                                    )
                            )

                            // TextField for manual input when no branches available
                            if availableBranches.isEmpty && !isLoadingBranches {
                                ProfessionalTextField(
                                    title: "",
                                    placeholder: "main, develop, feature/...",
                                    icon: "arrow.branch",
                                    text: $branch,
                                    validation: { _ in
                                        return ProfessionalTextField.ValidationResult(isValid: true, message: nil)
                                    }
                                )
                            }
                        }

                        // Professional Action Buttons with Auto Replace Toggle
                        HStack(spacing: 20) {
                            ProfessionalButton(
                                title: "Instalar (\(selectedModules.count))",
                                icon: "arrow.down.circle.fill",
                                gradientColors: [.orange, .yellow],
                                style: .primary,
                                isDisabled: selectedModules.isEmpty || apiKey.isEmpty
                            ) {
                                Task {
                                    await installSelectedModules()
                                }
                            }

                            // Auto Replace Option
                            Toggle("Reemplazar módulos existentes automáticamente", isOn: $autoReplaceModules)
                                .font(.system(size: 14, weight: .medium))

                            Spacer()
                        }
                    }
                }
                .onAppear {
                    // Load API key automatically first
                    Task {
                        await loadApiKey()
                        // Then load gula status information
                        await loadGulaStatus()
                    }
                }
                .onChange(of: isLoadingModules) { newValue in
                    if newValue {
                        startLoadingAnimations()
                    } else {
                        stopLoadingAnimations()
                    }
                }
                .onDisappear {
                    stopLoadingAnimations()
                    stopStatusLoadingAnimations()
                }

                // Installation Progress Indicator
                if let currentModule = currentlyInstallingModule {
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Instalando módulo...")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Text(currentModule)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.orange)
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [Color.orange.opacity(0.3), Color.yellow.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    )
                    .shadow(
                        color: Color.orange.opacity(0.1),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                }

                // Enhanced Modules List Section
                if availableModules.isEmpty && !isLoading {
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 32, height: 32)
                                
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            Text("Información de Módulos")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        
                        Text("Los módulos se cargan automáticamente al abrir esta vista o al cambiar de rama. Se obtienen directamente del script gula.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [Color.blue.opacity(0.15), Color.cyan.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                }
                
                // Loading State for Modules
                if isLoadingModules {
                    VStack(spacing: 24) {
                        // Animated header with spinning icon
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 40, height: 40)
                                    .scaleEffect(pulseScale)
                                
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .rotationEffect(.degrees(rotationAngle))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Cargando Módulos...")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Text("Conectando con gula CLI")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        // Animated progress description
                        Text("Obteniendo la lista de módulos disponibles desde gula CLI. Por favor espera...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .opacity(pulseScale > 1.05 ? 0.8 : 1.0)
                        
                        // Enhanced loading animation with pulsing dots
                        HStack(spacing: 12) {
                            ForEach(0..<5) { index in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing))
                                    .frame(width: 6, height: 20)
                                    .scaleEffect(y: index < barScales.count ? barScales[index] : 0.5)
                                    .animation(.easeInOut(duration: 0.6), value: barScales)
                            }
                        }
                        .padding(.top, 12)
                        
                        // Shimmer effect
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        .orange.opacity(0.2),
                                        .yellow.opacity(0.3),
                                        .orange.opacity(0.2),
                                        .clear
                                    ],
                                    startPoint: UnitPoint(x: shimmerOffset, y: 0.5),
                                    endPoint: UnitPoint(x: shimmerOffset + 0.3, y: 0.5)
                                )
                            )
                            .frame(height: 2)
                            .clipShape(Capsule())
                            .opacity(1.0)
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [Color.orange.opacity(0.15), Color.yellow.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                }

                if !availableModules.isEmpty && !isLoadingModules {
                    VStack(alignment: .leading, spacing: 24) {
                        // Section Header with enhanced styling
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Módulos Disponibles")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Text("\(availableModules.count) módulos encontrados")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Enhanced Select All Button
                            ProfessionalButton(
                                title: isAllSelectableModulesSelected ? "Deseleccionar Todo" : "Seleccionar Todo",
                                icon: isAllSelectableModulesSelected ? "checkmark.square.fill" : "square",
                                gradientColors: [.blue, .purple],
                                style: .outline
                            ) {
                                toggleSelectAll()
                            }
                        }
                        
                        // Enhanced Modules List
                        LazyVStack(spacing: 6) {
                            ForEach(availableModules) { module in
                                ModuleListRow(
                                    module: module,
                                    isSelected: selectedModules.contains(module)
                                ) {
                                    toggleModuleSelection(module)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 28)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [Color.green.opacity(0.15), Color.mint.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // Enhanced Installation Output Section
                if !commandOutput.isEmpty {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [.green, .mint],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 32, height: 32)
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            Text("Resultado de Instalación")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        
                        ScrollView(.vertical, showsIndicators: true) {
                            Text(commandOutput)
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(24)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.regularMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .strokeBorder(
                                                    LinearGradient(
                                                        colors: [.green.opacity(0.3), .mint.opacity(0.2)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1.5
                                                )
                                        )
                                )
                                .shadow(color: .green.opacity(0.1), radius: 8, x: 0, y: 4)
                        }
                        .frame(maxHeight: 350)
                        .scrollBounceBehavior(.basedOnSize)
                    }
                    .padding(.horizontal, 32)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                
                Spacer(minLength: 20)
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 32)
        }
        .scrollBounceBehavior(.basedOnSize)
    }


    private func loadApiKey() async {
        do {
            let apiKeyEntity = try await getUserApiKeyUseCase.execute()
            await MainActor.run {
                self.apiKey = apiKeyEntity.key
                #if DEBUG
                print("✅ API key loaded successfully for ModuleManager")
                #endif
            }

            // Automatically load branches after API key is loaded
            await loadAvailableBranches()
        } catch {
            #if DEBUG
            print("⚠️ Could not load API key: \(error)")
            #endif
            await MainActor.run {
                // API key will remain empty, user needs to authenticate first
                self.errorMessage = "No se pudo cargar la clave API. Por favor, inicia sesión primero."
                self.showingError = true
            }
        }
    }

    private func loadModules() async {
        isLoadingModules = true
        selectedModules.removeAll()

        do {
            #if DEBUG
            print("🔄 Loading modules with API key: \(apiKey)")
            print("🌿 Branch: \(branch.isEmpty ? "default" : branch)")
            #endif

            // First, refresh gula status to get latest installed modules (with enhanced animation)
            await loadGulaStatus()

            let result = try await projectManager.listModules(
                apiKey: apiKey,
                branch: branch.isEmpty ? nil : branch
            )

            #if DEBUG
            print("📋 Module list output received")
            #endif
            moduleListOutput = result

            #if DEBUG
            // Debug: print each line to see the exact format
            let lines = result.components(separatedBy: .newlines)
            for (index, line) in lines.enumerated() {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.contains("Lista de módulos") || trimmed.hasPrefix("---") || (!trimmed.isEmpty && index > 20 && index < 40) {
                    print("Line \(index): '\(trimmed)'")
                }
            }
            #endif

            parseModulesFromOutput(result)

            #if DEBUG
            print("✅ Parsed \(availableModules.count) modules with installation status")
            #endif
        } catch {
            #if DEBUG
            print("❌ Error loading modules: \(error)")
            #endif
            errorMessage = error.localizedDescription
            showingError = true
        }

        isLoadingModules = false
    }
    
    private func loadGulaStatus() async {
        await MainActor.run {
            isLoadingGulaStatus = true
            statusLoadingProgress = 0.0
            startStatusLoadingAnimations()
        }
        
        do {
            // Simulate progressive loading steps
            await updateStatusProgress(0.25, stepDescription: "Escaneando")
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            
            await updateStatusProgress(0.5, stepDescription: "Analizando")
            let status = try await projectManager.getProjectStatus()
            
            await updateStatusProgress(0.75, stepDescription: "Procesando")
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            
            await MainActor.run {
                gulaStatus = status
                // Extract installed module names from gula status
                installedModuleNames = Set(status.installedModules.map { $0.name.lowercased() })
                // Create mapping of module name to installed branch
                installedModulesInfo = Dictionary(uniqueKeysWithValues: status.installedModules.map { ($0.name.lowercased(), $0.branch) })
                #if DEBUG
                print("📊 Gula Status: Found \(installedModuleNames.count) installed modules: \(installedModuleNames)")
                print("📊 Branch info: \(installedModulesInfo)")
                #endif
            }
            
            await updateStatusProgress(1.0, stepDescription: "Finalizando")
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            
        } catch {
            #if DEBUG
            print("❌ Error loading gula status: \(error)")
            #endif
            await MainActor.run {
                gulaStatus = nil
                installedModuleNames = []
                installedModulesInfo = [:]
            }
        }
        
        await MainActor.run {
            isLoadingGulaStatus = false
            statusLoadingProgress = 0.0
            stopStatusLoadingAnimations()
        }
    }
    
    private func updateStatusProgress(_ progress: Double, stepDescription: String) async {
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.3)) {
                statusLoadingProgress = progress
            }
        }
    }
    
    private func loadAvailableBranches() async {
        guard !apiKey.isEmpty else {
            #if DEBUG
            print("⚠️ API key is empty, cannot load branches")
            #endif
            return
        }

        isLoadingBranches = true
        availableBranches = []

        do {
            #if DEBUG
            print("🌿 Loading available branches with API key for project: \(project.name)")
            #endif
            let branches = try await projectManager.getAvailableBranches(apiKey: apiKey, for: project)
            
            await MainActor.run {
                self.availableBranches = branches

                // Set default branch if none selected
                if self.branch.isEmpty && !branches.isEmpty {
                    // Prefer 'main' or 'develop' if available, otherwise first branch
                    if branches.contains("main") {
                        self.branch = "main"
                    } else if branches.contains("develop") {
                        self.branch = "develop"
                    } else {
                        self.branch = branches.first ?? ""
                    }
                }

                self.isLoadingBranches = false
            }

            #if DEBUG
            print("✅ Branches loaded successfully: \(branches)")
            #endif

            // Automatically load modules after branches are loaded
            await loadModules()
        } catch {
            await MainActor.run {
                self.isLoadingBranches = false
                #if DEBUG
                print("❌ Error loading branches: \(error)")
                #endif
                // Optionally show error to user
                if let projectError = error as? ProjectError {
                    switch projectError {
                    case .invalidAPIKey(let message):
                        self.errorMessage = "Clave API inválida: \(message)"
                        self.showingError = true
                    default:
                        break
                    }
                }
            }
        }
    }
    
    private func parseModulesFromOutput(_ output: String) {
        var modules = Module.parseFromGulaOutput(output)

        // Update installation status and branch based on gula status information
        for i in 0..<modules.count {
            let moduleName = modules[i].name.lowercased()
            if installedModuleNames.contains(moduleName) {
                modules[i].installationStatus = .installed
                modules[i].installedBranch = installedModulesInfo[moduleName]
                #if DEBUG
                print("✅ Module '\(modules[i].name)' marked as installed from gula status, branch: \(modules[i].installedBranch ?? "unknown")")
                #endif
            } else {
                modules[i].installationStatus = .notInstalled
                modules[i].installedBranch = nil
            }
        }

        availableModules = modules
        #if DEBUG
        print("📝 Updated \(modules.count) modules with installation status from gula status")
        #endif
    }
    
    private func toggleModuleSelection(_ module: Module) {
        // Only allow selection if module is not installed and not currently installing
        guard module.installationStatus == .notInstalled else { return }
        
        if selectedModules.contains(module) {
            selectedModules.remove(module)
        } else {
            selectedModules.insert(module)
        }
    }
    
    private func toggleSelectAll() {
        let selectableModules = availableModules.filter { $0.installationStatus == .notInstalled }
        
        if selectedModules.count == selectableModules.count {
            selectedModules.removeAll()
        } else {
            selectedModules = Set(selectableModules)
        }
    }
    
    private func installSelectedModules() async {
        guard !selectedModules.isEmpty else { return }
        
        isLoading = true
        var results: [String] = []
        let totalModules = selectedModules.count
        var processedCount = 0
        
        for module in selectedModules {
            processedCount += 1
            
            // Update module status to installing and set current installing module
            await MainActor.run {
                if let index = availableModules.firstIndex(where: { $0.id == module.id }) {
                    availableModules[index].installationStatus = .installing
                }
                installingModules.insert(module.id)
                let autoReplaceStatus = autoReplaceModules ? " (reemplazo automático)" : ""
                currentlyInstallingModule = "\(module.displayName) (\(processedCount)/\(totalModules))\(autoReplaceStatus)"
            }
            
            do {
                // Add timeout wrapper for installation
                let result = try await withTimeout(seconds: 300) { // 5 minute timeout
                    try await projectManager.installModule(
                        module.name,
                        apiKey: apiKey,
                        branch: branch.isEmpty ? nil : branch,
                        autoReplace: autoReplaceModules
                    )
                }
                
                // Update module status to installed
                await MainActor.run {
                    if let index = availableModules.firstIndex(where: { $0.id == module.id }) {
                        availableModules[index].installationStatus = .installed
                    }
                    installingModules.remove(module.id)
                }
                
                results.append("✅ \(module.displayName): Instalado correctamente")
                print("✅ Successfully installed module: \(module.displayName)")
                
            } catch {
                // Update module status to failed
                await MainActor.run {
                    if let index = availableModules.firstIndex(where: { $0.id == module.id }) {
                        let errorMessage = error.localizedDescription.contains("timeout") ? 
                                         "Timeout - La instalación tomó demasiado tiempo" : 
                                         error.localizedDescription
                        availableModules[index].installationStatus = .failed(errorMessage)
                    }
                    installingModules.remove(module.id)
                }
                
                let errorMessage = error.localizedDescription.contains("timeout") ? 
                                 "Timeout - La instalación tomó demasiado tiempo" : 
                                 error.localizedDescription
                results.append("❌ \(module.displayName): \(errorMessage)")
                print("❌ Failed to install module: \(module.displayName), error: \(error)")
            }
            
            // Small delay between installations to prevent overwhelming the system
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        }
        
        // Clear selection and current installing module after installation attempt
        await MainActor.run {
            selectedModules.removeAll()
            currentlyInstallingModule = nil
        }
        
        commandOutput = results.joined(separator: "\n\n")
        
        // Refresh gula status to get updated installation information
        await loadGulaStatus()
        
        // Update modules list with new installation status and branch
        if !availableModules.isEmpty {
            var updatedModules = availableModules
            for i in 0..<updatedModules.count {
                let moduleName = updatedModules[i].name.lowercased()
                if installedModuleNames.contains(moduleName) {
                    updatedModules[i].installationStatus = .installed
                    updatedModules[i].installedBranch = installedModulesInfo[moduleName]
                }
            }
            availableModules = updatedModules
        }
        
        isLoading = false
        
        print("🏁 Installation process completed. Results:")
        print(commandOutput)
        print("📊 Updated installation status from gula status")
    }
    
    // Helper function to add timeout to async operations
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw TimeoutError()
            }
            
            guard let result = try await group.next() else {
                throw TimeoutError()
            }
            
            group.cancelAll()
            return result
        }
    }
    
    struct TimeoutError: Error {
        var localizedDescription: String {
            return "timeout"
        }
    }
    
    // MARK: - Animation Functions
    
    private func startLoadingAnimations() {
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            pulseScale = 1.1
        }
        
        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
            shimmerOffset = 1.0
        }
        
        // Start bar animation timer
        startBarAnimation()
    }
    
    private func stopLoadingAnimations() {
        withAnimation(.easeOut(duration: 0.3)) {
            rotationAngle = 0
            pulseScale = 1.0
            shimmerOffset = -1.0
        }
        
        // Stop bar animation timer
        stopBarAnimation()
    }
    
    private func startBarAnimation() {
        barAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.4)) {
                barScales = barScales.map { _ in
                    CGFloat.random(in: 0.3...1.5)
                }
            }
        }
    }
    
    private func stopBarAnimation() {
        barAnimationTimer?.invalidate()
        barAnimationTimer = nil
        withAnimation(.easeOut(duration: 0.3)) {
            barScales = [0.3, 0.7, 1.0, 0.5, 0.8]
        }
    }
    
    // MARK: - Status Loading Animation Functions
    
    private func startStatusLoadingAnimations() {
        // Rotating gradient animation
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            statusAnimationOffset = 1.0
        }
        
        // Pulsing effect
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            statusPulseScale = 1.15
        }
    }
    
    private func stopStatusLoadingAnimations() {
        withAnimation(.easeOut(duration: 0.4)) {
            statusAnimationOffset = -1.0
            statusPulseScale = 1.0
        }
    }
}
