import SwiftUI
import AppKit
import Foundation

// Import domain entities and services
// Note: These would normally be imported from separate modules



// Note: ProjectManager is imported from Services layer

struct MainContentView: View {
    let project: Project
    let onBack: () -> Void
    @StateObject private var projectManager = ProjectManager.shared
    @State private var selectedAction: GulaDashboardAction? = .overview
    @State private var showingModuleList = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationSplitView {
            GulaSidebarView(selection: $selectedAction, project: project, onBack: onBack)
        } detail: {
            GulaDashboardDetailView(
                selectedAction: $selectedAction,
                project: project,
                projectManager: projectManager,
                showingError: $showingError,
                errorMessage: $errorMessage,
                isLoading: $isLoading
            )
        }
        .navigationSplitViewStyle(.balanced)
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .background(
            Button("") {
                onBack()
            }
            .keyboardShortcut(.escape, modifiers: [])
            .hidden()
        )
    }
}

struct GulaSidebarView: View {
    @Binding var selection: GulaDashboardAction?
    let project: Project
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Project Header with Back Button
            ProjectHeaderSection(project: project, onBack: onBack)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)
            
            // Navigation Items in ScrollView
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // Project Section (without change project item)
                    SidebarSection(
                        title: "Proyecto",
                        items: [.overview, .openInFinder],
                        selection: $selection,
                        project: project,
                        onBack: onBack
                    )
                    
                    // Gula Actions Section
                    SidebarSection(
                        title: "Herramientas",
                        items: GulaDashboardAction.gulaItems,
                        selection: $selection,
                        project: project
                    )
                    
                    // Settings Section
                    SidebarSection(
                        title: "Configuración",
                        items: GulaDashboardAction.settingsItems,
                        selection: $selection,
                        project: project
                    )
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .frame(minWidth: 240, maxWidth: 260)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .fill(Color.primary.opacity(0.08))
                .frame(width: 1)
                .frame(maxWidth: .infinity, alignment: .trailing)
        )
    }
}

struct ProjectHeaderSection: View {
    let project: Project
    let onBack: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Back button
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        
                        Text("Volver a Proyectos")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(isHovered ? .primary : .secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isHovered ? Color.primary.opacity(0.06) : Color.clear)
                    )
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isHovered = hovering
                    }
                }
                
                Spacer()
            }
            
            // Project info card
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    // Project icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        project.type.accentColor,
                                        project.type.accentColor.opacity(0.7)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                            .shadow(color: project.type.accentColor.opacity(0.3), radius: 6, x: 0, y: 3)
                        
                        Text(project.type.icon)
                            .font(.system(size: 20, weight: .medium))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(project.name)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "tag.fill")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(project.type.accentColor)
                            
                            Text(project.type.displayName)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [project.type.accentColor.opacity(0.2), project.type.accentColor.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
            
            // Divider
            Divider()
                .padding(.top, 8)
        }
    }
}


struct SidebarSection: View {
    let title: String
    let items: [GulaDashboardAction]
    @Binding var selection: GulaDashboardAction?
    let project: Project
    let onBack: (() -> Void)?
    
    init(title: String, items: [GulaDashboardAction], selection: Binding<GulaDashboardAction?>, project: Project, onBack: (() -> Void)? = nil) {
        self.title = title
        self.items = items
        self._selection = selection
        self.project = project
        self.onBack = onBack
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Section Header
            HStack {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                Spacer()
            }
            .padding(.horizontal, 4)
            
            // Section Items
            VStack(spacing: 2) {
                ForEach(items) { item in
                    SidebarItem(
                        item: item,
                        isSelected: selection == item,
                        action: {
                            selection = item
                        },
                        project: project,
                        onBack: onBack
                    )
                }
            }
        }
    }
}

struct SidebarItem: View {
    let item: GulaDashboardAction
    let isSelected: Bool
    let action: () -> Void
    let project: Project
    let onBack: (() -> Void)?
    @State private var isHovered = false
    
    init(item: GulaDashboardAction, isSelected: Bool, action: @escaping () -> Void, project: Project, onBack: (() -> Void)? = nil) {
        self.item = item
        self.isSelected = isSelected
        self.action = action
        self.project = project
        self.onBack = onBack
    }
    
    var body: some View {
        Button(action: {
            if item == .openInFinder {
                openInFinder()
            } else if item == .changeProject {
                onBack?()
            } else {
                action()
            }
        }) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(iconBackgroundColor)
                        .frame(width: 28, height: 28)
                    
                    Image(systemName: item.icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(iconForegroundColor)
                }
                
                // Title
                Text(item.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(textColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(borderColor, lineWidth: borderWidth)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .primary.opacity(0.08)
        } else if isHovered {
            return .primary.opacity(0.04)
        } else {
            return .clear
        }
    }
    
    private var iconBackgroundColor: Color {
        if isSelected {
            return .primary.opacity(0.12)
        } else if isHovered {
            return .primary.opacity(0.06)
        } else {
            return .primary.opacity(0.04)
        }
    }
    
    private var iconForegroundColor: Color {
        if isSelected {
            return .primary
        } else {
            return .secondary
        }
    }
    
    private var textColor: Color {
        if isSelected {
            return .primary
        } else {
            return .secondary
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return .primary.opacity(0.15)
        } else {
            return .clear
        }
    }
    
    private var borderWidth: CGFloat {
        isSelected ? 1 : 0
    }
    
    private func openInFinder() {
        #if os(macOS)
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: project.path)
        #endif
    }
}

struct GulaDashboardDetailView: View {
    @Binding var selectedAction: GulaDashboardAction?
    let project: Project
    @ObservedObject var projectManager: ProjectManager
    @Binding var showingError: Bool
    @Binding var errorMessage: String
    @Binding var isLoading: Bool
    @State private var apiKey: String = ""
    @State private var moduleListOutput: String = ""
    @State private var commandOutput: String = ""
    @State private var availableModules: [Module] = []
    @State private var selectedModules: Set<Module> = []
    
    var body: some View {
        ZStack {
            #if os(macOS)
            VisualEffectView(material: .underWindowBackground)
                .ignoresSafeArea()
            #else
            Color.clear
                .background(.regularMaterial)
                .ignoresSafeArea()
            #endif
            
            contentView
        }
        .navigationTitle((selectedAction ?? .overview).title)
        .frame(minWidth: 700, minHeight: 500)
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch selectedAction ?? .overview {
        case .overview:
            ProjectOverviewView(project: project, selectedAction: $selectedAction)
        case .modules:
            ModuleManagerView(
                project: project,
                projectManager: projectManager,
                apiKey: $apiKey,
                isLoading: $isLoading,
                showingError: $showingError,
                errorMessage: $errorMessage
            )
        case .generateTemplate:
            TemplateGeneratorView(
                project: project,
                projectManager: projectManager,
                commandOutput: $commandOutput,
                isLoading: $isLoading,
                showingError: $showingError,
                errorMessage: $errorMessage
            )
        case .openInFinder:
            // This case should never be reached since openInFinder is handled directly in SidebarItem
            EmptyView()
        case .changeProject:
            // This case should never be reached since changeProject is handled directly in SidebarItem
            EmptyView()
        case .settings:
            Text("Configuración")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray.opacity(0.1))
        }
    }
}

enum GulaDashboardAction: String, CaseIterable, Identifiable, Hashable {
    case overview = "overview"
    case modules = "modules"
    case generateTemplate = "generateTemplate"
    case openInFinder = "openInFinder"
    case changeProject = "changeProject"
    case settings = "settings"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .overview: return "Resumen"
        case .modules: return "Módulos"
        case .generateTemplate: return "Generar Template"
        case .openInFinder: return "Abrir en Finder"
        case .changeProject: return "Cambiar Proyecto"
        case .settings: return "Configuración"
        }
    }
    
    var icon: String {
        switch self {
        case .overview: return "doc.text.magnifyingglass"
        case .modules: return "square.stack.3d.up"
        case .generateTemplate: return "doc.badge.plus"
        case .openInFinder: return "folder"
        case .changeProject: return "arrow.left.square"
        case .settings: return "gear"
        }
    }
    
    
    static let projectItems: [GulaDashboardAction] = [.overview, .openInFinder, .changeProject]
    static let gulaItems: [GulaDashboardAction] = [.modules, .generateTemplate]
    static let settingsItems: [GulaDashboardAction] = [.settings]
}

// MARK: - Dashboard Views

struct ProjectOverviewView: View {
    let project: Project
    @Binding var selectedAction: GulaDashboardAction?
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 32) {
                // Project Header Card
                VStack(spacing: 20) {
                    HStack(spacing: 20) {
                        // Project Icon with gradient background
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            project.type == .python ? Color.green.opacity(0.8) : Color.blue.opacity(0.8),
                                            project.type == .python ? Color.mint.opacity(0.6) : Color.cyan.opacity(0.6)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            
                            Text(project.type.icon)
                                .font(.system(size: 36, weight: .medium))
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(project.name)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 8) {
                                Image(systemName: "tag.fill")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(project.type == .python ? .green : .blue)
                                
                                Text(project.type.displayName)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack(spacing: 8) {
                                Image(systemName: "folder.fill")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary.opacity(0.7))
                                
                                Text(project.displayPath)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary.opacity(0.8))
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                        }
                        
                        Spacer()
                    }
                }
                .padding(24)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.secondary.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                
                // Welcome Section
                VStack(spacing: 16) {
                    Text("¡Bienvenido a tu proyecto!")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Usa las herramientas de Gula para acelerar tu desarrollo con módulos prediseñados y templates automáticos.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 32)
                
                // Quick Actions Grid
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Acciones Rápidas")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        QuickActionCard(
                            title: "Listar Módulos",
                            description: "Explora módulos disponibles en el repositorio",
                            icon: "list.bullet.rectangle",
                            color: .green,
                            gradient: [.green, .mint]
                        ) {
                            selectedAction = .modules
                        }
                        
                        QuickActionCard(
                            title: "Instalar Módulo",
                            description: "Agrega nueva funcionalidad a tu proyecto",
                            icon: "square.and.arrow.down",
                            color: .orange,
                            gradient: [.orange, .yellow]
                        ) {
                            selectedAction = .modules
                        }
                        
                        QuickActionCard(
                            title: "Generar Template",
                            description: "Crea código automático con plantillas",
                            icon: "doc.badge.plus",
                            color: .purple,
                            gradient: [.purple, .pink]
                        ) {
                            selectedAction = .generateTemplate
                        }
                    }
                }
                
                Spacer(minLength: 20)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

struct QuickActionCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let gradient: [Color]
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Icon with gradient background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradient.map { $0.opacity(isHovered ? 0.8 : 0.6) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                        .shadow(color: color.opacity(0.3), radius: isHovered ? 8 : 4, x: 0, y: 2)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(description)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(height: 140)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    LinearGradient(
                        colors: gradient.map { $0.opacity(isHovered ? 0.4 : 0.2) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: isHovered ? 2 : 1
                )
        )
        .shadow(color: .black.opacity(0.06), radius: isHovered ? 12 : 6, x: 0, y: isHovered ? 6 : 3)
        .shadow(color: color.opacity(0.1), radius: isHovered ? 8 : 0, x: 0, y: 2)
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .contentShape(Rectangle())
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .onHover { hovering in
            if hovering {
                NSCursor.pointingHand.set()
            } else {
                NSCursor.arrow.set()
            }
        }
    }
}

// MARK: - Module Data Model
struct ModuleManagerView: View {
    let project: Project
    @ObservedObject var projectManager: ProjectManager
    @Binding var apiKey: String
    @Binding var isLoading: Bool
    @Binding var showingError: Bool
    @Binding var errorMessage: String
    
    @State private var branch: String = ""
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
    @StateObject private var moduleDataSource = ModuleDataSource()
    
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
                        // Enhanced API Key Input with validation
                        ProfessionalTextField(
                            title: "Clave de API",
                            placeholder: "Ingresa tu clave de API privada",
                            icon: "key.fill",
                            text: $apiKey,
                            isSecure: true,
                            validation: { key in
                                if key.isEmpty {
                                    return ProfessionalTextField.ValidationResult(isValid: false, message: nil)
                                } else {
                                    return ProfessionalTextField.ValidationResult(isValid: true, message: nil)
                                }
                            }
                        )
                        
                        // Enhanced Branch Input
                        ProfessionalTextField(
                            title: "Branch del Repositorio",
                            placeholder: "main, develop, feature/new-module",
                            icon: "arrow.triangle.branch",
                            text: $branch,
                            isOptional: true,
                            validation: { branch in
                                return ProfessionalTextField.ValidationResult(isValid: true, message: nil)
                            }
                        )
                        
                        // Auto Replace Option
                        Toggle("Reemplazar módulos existentes automáticamente", isOn: $autoReplaceModules)
                            .font(.system(size: 14, weight: .medium))
                            .padding(.vertical, 4)
                        
                        // Professional Action Buttons
                        HStack(spacing: 20) {
                            ProfessionalButton(
                                title: "Cargar Módulos",
                                icon: "magnifyingglass.circle.fill",
                                gradientColors: [.green, .mint],
                                style: .primary,
                                isDisabled: false
                            ) {
                                if !isLoadingModules {
                                    Task {
                                        await loadModules()
                                    }
                                }
                            }
                            
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
                            
                            Spacer()
                        }
                    }
                }
                .onAppear {
                    // No load modules automatically - wait for script execution
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
                        
                        Text("Para ver la lista de módulos disponibles, ingresa tu clave API y ejecuta el botón 'Cargar Módulos'. Los módulos se obtendrán directamente del script gula.")
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
                
                if !availableModules.isEmpty {
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
                                title: selectedModules.count == availableModules.count ? "Deseleccionar Todo" : "Seleccionar Todo",
                                icon: selectedModules.count == availableModules.count ? "checkmark.square.fill" : "square",
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
    
    
    private func loadModules() async {
        isLoadingModules = true
        selectedModules.removeAll()
        
        do {
            print("Loading modules with API key: \(apiKey)")
            print("Branch: \(branch.isEmpty ? "default" : branch)")
            
            let result = try await projectManager.listModules(
                apiKey: apiKey,
                branch: branch.isEmpty ? nil : branch
            )
            
            print("Module list output: \(result)")
            moduleListOutput = result
            
            // Debug: print each line to see the exact format
            let lines = result.components(separatedBy: .newlines)
            for (index, line) in lines.enumerated() {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.contains("Lista de módulos") || trimmed.hasPrefix("---") || (!trimmed.isEmpty && index > 20 && index < 40) {
                    print("Line \(index): '\(trimmed)'")
                }
            }
            
            parseModulesFromOutput(result)
            
            print("Parsed \(availableModules.count) modules")
        } catch {
            print("Error loading modules: \(error)")
            errorMessage = error.localizedDescription
            showingError = true
        }
        
        isLoadingModules = false
    }
    
    private func parseModulesFromOutput(_ output: String) {
        availableModules = Module.parseFromGulaOutput(output)
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
        isLoading = false
        
        print("🏁 Installation process completed. Results:")
        print(commandOutput)
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
    
    // MARK: - Template Functions
    
}

struct ModuleListRow: View {
    let module: Module
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Module Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    isSelected ? Color.blue : Color.secondary.opacity(0.6),
                                    isSelected ? Color.cyan : Color.secondary.opacity(0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                        .shadow(color: (isSelected ? Color.blue : Color.secondary).opacity(0.2), radius: 2, x: 0, y: 1)
                    
                    Image(systemName: module.icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // Module Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(module.displayName)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(module.description)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // Category Badge
                Text(module.category.rawValue)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(isSelected ? Color.blue.opacity(0.3) : Color.secondary.opacity(0.1))
                    )
                
                // Installation Status Indicator
                installationStatusView
                
                // Selection Indicator
                if module.installationStatus == .notInstalled {
                    ZStack {
                        Circle()
                            .fill(
                                isSelected 
                                    ? LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    : LinearGradient(colors: [Color.secondary.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        isSelected ? Color.clear : Color.secondary.opacity(0.3),
                                        lineWidth: 1
                                    )
                            )
                            .frame(width: 20, height: 20)
                        
                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.regularMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isSelected 
                            ? LinearGradient(colors: [.blue.opacity(0.6), .cyan.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.secondary.opacity(isHovered ? 0.3 : 0.15)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(
                color: isSelected ? Color.blue.opacity(0.15) : Color.black.opacity(isHovered ? 0.04 : 0.02),
                radius: isSelected ? 4 : (isHovered ? 3 : 2),
                x: 0,
                y: isSelected ? 2 : 1
            )
            .scaleEffect(isHovered ? 1.005 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
    
    @ViewBuilder
    private var installationStatusView: some View {
        switch module.installationStatus {
        case .notInstalled:
            EmptyView()
        case .installing:
            HStack(spacing: 6) {
                ProgressView()
                    .scaleEffect(0.7)
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                Text("Instalando...")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.blue)
            }
        case .installed:
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.green)
                Text("Instalado")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.green)
            }
        case .failed(let error):
            HStack(spacing: 6) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.red)
                Text("Error")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.red)
            }
            .help(error)
        }
    }
}

struct CompactModuleCard: View {
    let module: Module
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Module Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    isSelected ? Color.blue : Color.secondary.opacity(0.6),
                                    isSelected ? Color.cyan : Color.secondary.opacity(0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 28, height: 28)
                        .shadow(color: (isSelected ? Color.blue : Color.secondary).opacity(0.2), radius: 2, x: 0, y: 1)
                    
                    Image(systemName: module.icon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // Module Info
                VStack(spacing: 4) {
                    Text(module.displayName)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                    
                    Text(module.description)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Selection Indicator
                ZStack {
                    Circle()
                        .fill(
                            isSelected 
                                ? LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(colors: [Color.secondary.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    isSelected ? Color.clear : Color.secondary.opacity(0.3),
                                    lineWidth: 0.5
                                )
                        )
                        .frame(width: 16, height: 16)
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: isSelected)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(
                                isSelected 
                                    ? LinearGradient(colors: [.blue.opacity(0.6), .cyan.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    : LinearGradient(colors: [Color.secondary.opacity(isHovered ? 0.3 : 0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: isSelected ? 1.5 : 0.5
                            )
                    )
            )
            .shadow(
                color: isSelected ? Color.blue.opacity(0.15) : Color.black.opacity(isHovered ? 0.04 : 0.02),
                radius: isSelected ? 4 : (isHovered ? 3 : 2),
                x: 0,
                y: isSelected ? 2 : 1
            )
            .scaleEffect(isHovered ? 1.01 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

struct EnhancedModuleCard: View {
    let module: Module
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isHovered = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // Module Header
                HStack(spacing: 12) {
                    // Module Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        isSelected ? Color.blue : Color.secondary.opacity(0.6),
                                        isSelected ? Color.cyan : Color.secondary.opacity(0.4)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                            .shadow(color: (isSelected ? Color.blue : Color.secondary).opacity(0.3), radius: 6, x: 0, y: 3)
                        
                        Image(systemName: module.icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(module.displayName)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(module.description)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                }
                
                // Selection Indicator
                HStack {
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                isSelected 
                                    ? LinearGradient(
                                        colors: [.blue, .cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    : LinearGradient(
                                        colors: [Color.secondary.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(
                                        isSelected ? Color.clear : Color.secondary.opacity(0.3),
                                        lineWidth: 1.5
                                    )
                            )
                            .frame(width: 28, height: 28)
                            .shadow(
                                color: isSelected ? Color.blue.opacity(0.3) : Color.clear,
                                radius: isSelected ? 4 : 0,
                                x: 0,
                                y: 2
                            )
                        
                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: isSelected)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        isSelected 
                                            ? Color.blue.opacity(0.6) 
                                            : (isHovered ? Color.secondary.opacity(0.4) : Color.secondary.opacity(0.2)),
                                        isSelected 
                                            ? Color.cyan.opacity(0.4) 
                                            : (isHovered ? Color.secondary.opacity(0.2) : Color.secondary.opacity(0.1))
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .shadow(
                color: isSelected 
                    ? Color.blue.opacity(0.2) 
                    : Color.black.opacity(isHovered ? 0.08 : 0.04),
                radius: isSelected ? 12 : (isHovered ? 10 : 6),
                x: 0,
                y: isSelected ? 6 : (isHovered ? 4 : 2)
            )
            .scaleEffect(
                isPressed ? 0.95 : (isHovered ? 1.03 : 1.0)
            )
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
    }
}

struct TemplateCard: View {
    let template: Template
    let isSelected: Bool
    let selectedType: TemplateType
    let onSelect: () -> Void
    let onGenerate: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Template Header
            HStack(spacing: 12) {
                // Template Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    isSelected ? Color.purple : Color.secondary.opacity(0.6),
                                    isSelected ? Color.pink : Color.secondary.opacity(0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                        .shadow(color: (isSelected ? Color.purple : Color.secondary).opacity(0.3), radius: 6, x: 0, y: 3)
                    
                    Image(systemName: template.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.displayName)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(template.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.purple)
                        .fontWeight(.medium)
                }
                
                Spacer()
            }
            
            // Template Description
            Text(template.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            // Supported Types
            HStack {
                ForEach(template.supportedTypes.prefix(2), id: \.self) { type in
                    HStack(spacing: 4) {
                        Image(systemName: type.icon)
                            .font(.caption2)
                        Text(type.displayName)
                            .font(.caption2)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(type == selectedType ? Color.purple.opacity(0.2) : Color.secondary.opacity(0.1))
                    )
                    .foregroundColor(type == selectedType ? .purple : .secondary)
                }
                
                Spacer()
            }
            
            // Action Buttons
            HStack(spacing: 8) {
                Button("Seleccionar") {
                    onSelect()
                }
                .font(.caption)
                .foregroundColor(isSelected ? .white : .purple)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected ? LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing) : LinearGradient(colors: [Color.purple.opacity(0.1)], startPoint: .leading, endPoint: .trailing))
                        .stroke(Color.purple, lineWidth: isSelected ? 0 : 1)
                )
                
                Button("Generar") {
                    onGenerate()
                }
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                )
                
                Spacer()
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isSelected 
                            ? LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.secondary.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Professional Form Components

struct ProfessionalFormContainer<Content: View>: View {
    let title: String
    let subtitle: String?
    let icon: String
    let gradientColors: [Color]
    @ViewBuilder let content: Content
    
    init(
        title: String,
        subtitle: String? = nil,
        icon: String,
        gradientColors: [Color],
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.gradientColors = gradientColors
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 28) {
            // Form Header
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: gradientColors,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)
                            .shadow(color: gradientColors.first?.opacity(0.3) ?? .clear, radius: 8, x: 0, y: 4)
                        
                        Image(systemName: icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(title)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 32)
            
            // Form Content
            content
                .padding(.horizontal, 32)
                .padding(.vertical, 28)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: gradientColors.map { $0.opacity(0.15) },
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 6)
                        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                )
        }
    }
}


struct ProfessionalButton: View {
    let title: String
    let icon: String?
    let gradientColors: [Color]
    let action: () -> Void
    let isDisabled: Bool
    let style: ButtonStyle
    
    @State private var isPressed = false
    @State private var isHovered = false
    
    enum ButtonStyle {
        case primary
        case secondary
        case outline
    }
    
    init(
        title: String,
        icon: String? = nil,
        gradientColors: [Color] = [.blue, .cyan],
        style: ButtonStyle = .primary,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.gradientColors = gradientColors
        self.style = style
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(backgroundView)
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowOffset)
            .scaleEffect(isPressed ? 0.96 : (isHovered ? 1.02 : 1.0))
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering && !isDisabled
            }
        }
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: gradientColors.map { isHovered ? $0 : $0.opacity(0.9) },
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        case .secondary:
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.secondary.opacity(0.3), lineWidth: 1)
                )
        case .outline:
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2
                )
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isHovered ? gradientColors.first?.opacity(0.05) ?? .clear : .clear)
                )
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary, .outline:
            return .primary
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary:
            return gradientColors.first?.opacity(0.3) ?? .clear
        case .secondary, .outline:
            return .black.opacity(0.06)
        }
    }
    
    private var shadowRadius: CGFloat {
        isHovered ? 12 : 6
    }
    
    private var shadowOffset: CGFloat {
        isHovered ? 4 : 2
    }
}

// Extension to handle focus state
extension View {
    func onFocus(perform action: @escaping (Bool) -> Void) -> some View {
        self.background(
            FocusStateHelper(onFocusChange: action)
        )
    }
}

struct FocusStateHelper: NSViewRepresentable {
    let onFocusChange: (Bool) -> Void
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        context.coordinator.view = view
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onFocusChange: onFocusChange)
    }
    
    class Coordinator: NSObject {
        let onFocusChange: (Bool) -> Void
        var view: NSView?
        
        init(onFocusChange: @escaping (Bool) -> Void) {
            self.onFocusChange = onFocusChange
            super.init()
        }
    }
}

// Extension for press events
extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    onPress()
                }
                .onEnded { _ in
                    onRelease()
                }
        )
    }
}

struct TemplateGeneratorView: View {
    let project: Project
    @ObservedObject var projectManager: ProjectManager
    @Binding var commandOutput: String
    @Binding var isLoading: Bool
    @Binding var showingError: Bool
    @Binding var errorMessage: String
    @State private var templateName: String = ""
    @State private var templateType: String = ""
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 40) {
                // Enhanced Professional Form Container
                ProfessionalFormContainer(
                    title: "Generador de Templates",
                    subtitle: "Automatiza la creación de código con plantillas inteligentes y personalizables",
                    icon: "wand.and.stars",
                    gradientColors: [.purple, .pink]
                ) {
                    VStack(spacing: 28) {
                        // Enhanced Template Name Input with validation
                        ProfessionalTextField(
                            title: "Nombre del Template",
                            placeholder: "user, car, product ...",
                            icon: "doc.text.fill",
                            text: $templateName,
                            validation: { name in
                                if name.isEmpty {
                                    return ProfessionalTextField.ValidationResult(isValid: false, message: nil)
                                } else if name.count < 2 {
                                    return ProfessionalTextField.ValidationResult(isValid: false, message: "El nombre debe tener al menos 2 caracteres")
                                } else if name.contains(" ") {
                                    return ProfessionalTextField.ValidationResult(isValid: false, message: "El nombre no puede contener espacios")
                                } else {
                                    return ProfessionalTextField.ValidationResult(isValid: true, message: nil)
                                }
                            }
                        )
                        
                        // Enhanced Template Type Input
                        ProfessionalTextField(
                            title: "Tipo de Template",
                            placeholder: "model, view, controller, service, component",
                            icon: "tag.circle.fill",
                            text: $templateType,
                            isOptional: true,
                            validation: { type in
                                return ProfessionalTextField.ValidationResult(isValid: true, message: nil)
                            }
                        )
                        
                        // Enhanced Generate Button
                        HStack {
                            ProfessionalButton(
                                title: "Generar Template",
                                icon: "wand.and.stars.inverse",
                                gradientColors: [.purple, .pink],
                                style: .primary,
                                isDisabled: templateName.isEmpty
                            ) {
                                Task {
                                    await generateTemplate()
                                }
                            }
                            
                            Spacer()
                        }
                    }
                }
                
                // Enhanced Output Section
                if !commandOutput.isEmpty || isLoading {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [.purple, .pink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 32, height: 32)
                                
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.6)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Text(isLoading ? "Generando Template..." : "Resultado de Generación")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        
                        ScrollView(.vertical, showsIndicators: true) {
                            if isLoading {
                                VStack(spacing: 24) {
                                    // Animated generator icon
                                    ZStack {
                                        Circle()
                                            .fill(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .frame(width: 60, height: 60)
                                            .scaleEffect(isLoading ? 1.1 : 0.9)
                                            .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isLoading)
                                        
                                        Image(systemName: "gearshape.2")
                                            .font(.system(size: 24, weight: .semibold))
                                            .foregroundColor(.white)
                                            .rotationEffect(.degrees(isLoading ? 360 : 0))
                                            .animation(Animation.linear(duration: 3.0).repeatForever(autoreverses: false), value: isLoading)
                                    }
                                    
                                    VStack(spacing: 8) {
                                        Text("Generando Template...")
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundColor(.primary)
                                        
                                        Text("Ejecutando comando gula")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    // Animated progress bars
                                    VStack(spacing: 8) {
                                        ForEach(0..<3) { index in
                                            HStack {
                                                Text(["Preparando archivos...", "Generando código...", "Finalizando..."][index])
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(.secondary)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                
                                                Circle()
                                                    .fill(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                                                    .frame(width: 6, height: 6)
                                                    .scaleEffect(isLoading ? 1.5 : 0.5)
                                                    .opacity(isLoading ? 1.0 : 0.3)
                                                    .animation(
                                                        Animation.easeInOut(duration: 0.6)
                                                            .repeatForever()
                                                            .delay(Double(index) * 0.3),
                                                        value: isLoading
                                                    )
                                            }
                                        }
                                    }
                                    .padding(.top, 8)
                                    
                                    Text("Por favor, espera mientras se genera el template")
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundColor(.secondary.opacity(0.8))
                                        .multilineTextAlignment(.center)
                                        .opacity(isLoading ? 0.7 : 1.0)
                                        .animation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isLoading)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(40)
                            } else {
                                Text(commandOutput)
                                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(24)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.regularMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [.purple.opacity(0.3), .pink.opacity(0.2)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                        )
                        .shadow(color: .purple.opacity(0.1), radius: 8, x: 0, y: 4)
                        .frame(maxHeight: 350)
                        .scrollBounceBehavior(.basedOnSize)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Spacer(minLength: 30)
            }
            .padding(.vertical, 32)
            .padding(.horizontal, 32)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
    
    private func generateTemplate() async {
        isLoading = true
        do {
            let result = try await projectManager.generateTemplate(
                templateName,
                type: templateType.isEmpty ? nil : templateType
            )
            commandOutput = result
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
        isLoading = false
    }
}

// MARK: - Extensions

// Extension to add accent colors to ProjectType
extension ProjectType {
    var accentColor: Color {
        switch self {
        case .android:
            return .green
        case .ios:
            return .blue
        case .flutter:
            return .cyan
        case .python:
            return .orange
        }
    }
}

struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleProject = Project(
            name: "Sample Project",
            path: "/Users/sample/project",
            type: .flutter
        )
        return MainContentView(project: sampleProject) {
            print("Back button pressed")
        }
    }
}
