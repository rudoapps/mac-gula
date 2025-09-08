import SwiftUI
import AppKit
import Foundation

// Import domain entities and services
// Note: These would normally be imported from separate modules

// Extension to add accent colors to ProjectType
extension ProjectType {
    var accentColor: Color {
        switch self {
        case .android: return .green
        case .ios: return .blue
        case .flutter: return .cyan
        case .python: return .orange
        }
    }
}

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
                selectedAction: selectedAction ?? .overview,
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
    let selectedAction: GulaDashboardAction
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
    @State private var isLoadingModules = false
    
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
            
            if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Ejecutando comando gula...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            } else {
                contentView
            }
        }
        .navigationTitle(selectedAction.title)
        .frame(minWidth: 700, minHeight: 500)
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch selectedAction {
        case .overview:
            ProjectOverviewView(project: project)
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
                        )
                        
                        QuickActionCard(
                            title: "Instalar Módulo",
                            description: "Agrega nueva funcionalidad a tu proyecto",
                            icon: "square.and.arrow.down",
                            color: .orange,
                            gradient: [.orange, .yellow]
                        )
                        
                        QuickActionCard(
                            title: "Generar Template",
                            description: "Crea código automático con plantillas",
                            icon: "doc.badge.plus",
                            color: .purple,
                            gradient: [.purple, .pink]
                        )
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
    @State private var isHovered = false
    
    var body: some View {
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
    @State private var commandOutput: String = ""
    @State private var showingModuleList = false
    
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
                        
                        // Professional Action Buttons
                        HStack(spacing: 20) {
                            ProfessionalButton(
                                title: "Cargar Módulos",
                                icon: "magnifyingglass.circle.fill",
                                gradientColors: [.green, .mint],
                                style: .primary,
                                isDisabled: apiKey.isEmpty
                            ) {
                                Task {
                                    await loadModules()
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

                // Enhanced Modules List Section
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
                        
                        // Enhanced Modules Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(availableModules) { module in
                                EnhancedModuleCard(
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
        }
        .scrollBounceBehavior(.basedOnSize)
    }
    
    private func loadModules() async {
        isLoading = true
        selectedModules.removeAll()
        
        do {
            let result = try await projectManager.listModules(
                apiKey: apiKey,
                branch: branch.isEmpty ? nil : branch
            )
            moduleListOutput = result
            parseModulesFromOutput(result)
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
        
        isLoading = false
    }
    
    private func parseModulesFromOutput(_ output: String) {
        availableModules = Module.parseFromGulaOutput(output)
    }
    
    private func toggleModuleSelection(_ module: Module) {
        if selectedModules.contains(module) {
            selectedModules.remove(module)
        } else {
            selectedModules.insert(module)
        }
    }
    
    private func toggleSelectAll() {
        if selectedModules.count == availableModules.count {
            selectedModules.removeAll()
        } else {
            selectedModules = Set(availableModules)
        }
    }
    
    private func installSelectedModules() async {
        guard !selectedModules.isEmpty else { return }
        
        isLoading = true
        var results: [String] = []
        
        for module in selectedModules {
            do {
                let result = try await projectManager.installModule(
                    module.name,
                    apiKey: apiKey,
                    branch: branch.isEmpty ? nil : branch
                )
                results.append("✅ \(module.name): \(result)")
            } catch {
                results.append("❌ \(module.name): \(error.localizedDescription)")
            }
        }
        
        commandOutput = results.joined(separator: "\n\n")
        isLoading = false
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

struct ProfessionalTextField: View {
    let title: String
    let placeholder: String
    let icon: String
    @Binding var text: String
    let isSecure: Bool
    let isOptional: Bool
    let validation: ((String) -> ValidationResult)?
    
    @State private var isFocused = false
    @State private var isHovered = false
    
    struct ValidationResult {
        let isValid: Bool
        let message: String?
    }
    
    init(
        title: String,
        placeholder: String,
        icon: String,
        text: Binding<String>,
        isSecure: Bool = false,
        isOptional: Bool = false,
        validation: ((String) -> ValidationResult)? = nil
    ) {
        self.title = title
        self.placeholder = placeholder
        self.icon = icon
        self._text = text
        self.isSecure = isSecure
        self.isOptional = isOptional
        self.validation = validation
    }
    
    private var validationResult: ValidationResult? {
        return validation?(text)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Label with enhanced styling
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                if isOptional {
                    Text("(opcional)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary.opacity(0.8))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.secondary.opacity(0.1))
                        )
                }
                
                Spacer()
            }
            
            // Enhanced text field container
            HStack(spacing: 14) {
                // Icon with improved styling
                ZStack {
                    Circle()
                        .fill(iconBackgroundColor)
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(iconForegroundColor)
                }
                
                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                            .font(.system(size: 15, weight: .medium, design: .monospaced))
                            .textFieldStyle(.plain)
                    } else {
                        TextField(placeholder, text: $text)
                            .font(.system(size: 15, weight: .medium))
                            .textFieldStyle(.plain)
                    }
                }
                .onFocus { focused in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isFocused = focused
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(borderColor, lineWidth: borderWidth)
            )
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowOffset)
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.15)) {
                    isHovered = hovering
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isFocused)
            .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
            
            // Enhanced validation message
            if let result = validationResult, !text.isEmpty, !result.isValid, let message = result.message {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.red.opacity(0.8))
                    
                    Text(message)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.red.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.leading, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    private var backgroundMaterial: Material {
        if isFocused {
            return .regular
        } else if isHovered {
            return .regularMaterial
        } else {
            return .regularMaterial
        }
    }
    
    private var iconBackgroundColor: Color {
        if isFocused {
            return validationResult?.isValid == false ? Color.red.opacity(0.1) : Color.green.opacity(0.1)
        } else {
            return Color.secondary.opacity(0.08)
        }
    }
    
    private var iconForegroundColor: Color {
        if isFocused {
            return validationResult?.isValid == false ? .red : .green
        } else {
            return .secondary
        }
    }
    
    private var borderColor: Color {
        if isFocused {
            if let result = validationResult, !text.isEmpty {
                return result.isValid ? Color.green.opacity(0.6) : Color.red.opacity(0.6)
            } else {
                return Color.blue.opacity(0.6)
            }
        } else if isHovered {
            return Color.secondary.opacity(0.4)
        } else if text.isEmpty {
            return Color.secondary.opacity(0.25)
        } else {
            return Color.green.opacity(0.4)
        }
    }
    
    private var borderWidth: CGFloat {
        isFocused ? 2 : (text.isEmpty ? 1 : 1.5)
    }
    
    private var shadowColor: Color {
        if isFocused {
            if let result = validationResult, !text.isEmpty {
                return result.isValid ? Color.green.opacity(0.2) : Color.red.opacity(0.2)
            } else {
                return Color.blue.opacity(0.2)
            }
        } else {
            return Color.black.opacity(0.04)
        }
    }
    
    private var shadowRadius: CGFloat {
        isFocused ? 8 : 3
    }
    
    private var shadowOffset: CGFloat {
        isFocused ? 3 : 1
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
            HStack(spacing: 10) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
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
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: gradientColors.map { isHovered ? $0 : $0.opacity(0.9) },
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        case .secondary:
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.secondary.opacity(0.3), lineWidth: 1)
                )
        case .outline:
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2
                )
                .background(
                    RoundedRectangle(cornerRadius: 12)
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
                            placeholder: "crud, model, controller, service",
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
                if !commandOutput.isEmpty {
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
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            Text("Resultado de Generación")
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
                                                        colors: [.purple.opacity(0.3), .pink.opacity(0.2)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1.5
                                                )
                                        )
                                )
                                .shadow(color: .purple.opacity(0.1), radius: 8, x: 0, y: 4)
                        }
                        .frame(maxHeight: 350)
                        .scrollBounceBehavior(.basedOnSize)
                    }
                    .padding(.horizontal, 32)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Spacer(minLength: 30)
            }
            .padding(.vertical, 32)
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
