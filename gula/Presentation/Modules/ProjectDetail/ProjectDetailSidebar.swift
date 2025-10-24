import SwiftUI

// MARK: - Project Header Section

struct ProjectHeaderSection: View {
    let project: Project
    let onBack: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Enhanced Back button
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: isHovered 
                                            ? [project.type.accentColor.opacity(0.2), project.type.accentColor.opacity(0.1)]
                                            : [Color.secondary.opacity(0.1), Color.secondary.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 28, height: 28)
                                .shadow(
                                    color: isHovered ? project.type.accentColor.opacity(0.2) : .clear,
                                    radius: 3,
                                    x: 0,
                                    y: 1
                                )
                            
                            Image(systemName: "chevron.left")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(isHovered ? project.type.accentColor : .secondary)
                        }
                        
                        Text("Volver a Proyectos")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(isHovered ? .primary : .secondary)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isHovered ? Color.primary.opacity(0.05) : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(
                                        isHovered 
                                            ? LinearGradient(
                                                colors: [project.type.accentColor.opacity(0.3), project.type.accentColor.opacity(0.1)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                            : LinearGradient(colors: [Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                                        lineWidth: isHovered ? 1 : 0
                                    )
                            )
                    )
                    .shadow(
                        color: isHovered ? .black.opacity(0.08) : .clear,
                        radius: isHovered ? 4 : 0,
                        x: 0,
                        y: 2
                    )
                    .scaleEffect(isHovered ? 1.02 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isHovered)
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.2)) {
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

// MARK: - Sidebar Section

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
        VStack(alignment: .leading, spacing: 12) {
            // Enhanced Section Header
            HStack(spacing: 8) {
                // Section indicator line
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [project.type.accentColor, project.type.accentColor.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 3, height: 16)
                    .clipShape(Capsule())
                
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.primary.opacity(0.8))
                    .textCase(.uppercase)
                    .tracking(0.8)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            // Section Items with enhanced spacing
            VStack(spacing: 6) {
                ForEach(items) { item in
                    if item.isEnabled {
                        SidebarItem(
                            item: item,
                            isSelected: selection == item,
                            action: {
                                print("🎯 Sidebar: Seleccionando item: \(item)")
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selection = item
                                }
                            },
                            project: project,
                            onBack: onBack
                        )
                    }
                }
            }
        }
        .padding(.bottom, 16)
    }
}

// MARK: - Sidebar Item

struct SidebarItem: View {
    let item: GulaDashboardAction
    let isSelected: Bool
    let action: () -> Void
    let project: Project
    let onBack: (() -> Void)?
    @State private var isHovered = false
    @State private var isPressed = false
    
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
            } else {
                action()
            }
        }) {
            HStack(spacing: 14) {
                // Enhanced Icon with gradient and shadow
                ZStack {
                    // Background with gradient
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: iconGradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                        .shadow(
                            color: iconShadowColor,
                            radius: iconShadowRadius,
                            x: 0,
                            y: iconShadowY
                        )
                    
                    // Icon with enhanced styling
                    Image(systemName: item.icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(iconForegroundColor)
                        .scaleEffect(isPressed ? 0.95 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: isPressed)
                }
                
                // Enhanced Title
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(textColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [accentColor, accentColor.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 6, height: 6)
                            .shadow(color: accentColor.opacity(0.4), radius: 2, x: 0, y: 1)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(borderGradient, lineWidth: borderWidth)
                    )
            )
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: shadowY
            )
            .scaleEffect(isPressed ? 0.98 : (isHovered ? 1.02 : 1.0))
            .animation(.easeInOut(duration: 0.15), value: isHovered)
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
    
    // Enhanced computed properties for better aesthetics
    
    private var accentColor: Color {
        return project.type.accentColor
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return Color.primary.opacity(0.1)
        } else if isHovered {
            return Color.primary.opacity(0.05)
        } else {
            return .clear
        }
    }
    
    private var iconGradientColors: [Color] {
        if isSelected {
            return [accentColor, accentColor.opacity(0.8)]
        } else if isHovered {
            return [accentColor.opacity(0.3), accentColor.opacity(0.2)]
        } else {
            return [Color.secondary.opacity(0.15), Color.secondary.opacity(0.1)]
        }
    }
    
    private var iconForegroundColor: Color {
        return .secondary
    }
    
    private var iconShadowColor: Color {
        if isSelected {
            return accentColor.opacity(0.4)
        } else if isHovered {
            return accentColor.opacity(0.2)
        } else {
            return .black.opacity(0.1)
        }
    }
    
    private var iconShadowRadius: CGFloat {
        isSelected ? 4 : (isHovered ? 3 : 2)
    }
    
    private var iconShadowY: CGFloat {
        isSelected ? 2 : 1
    }
    
    private var textColor: Color {
        if isSelected {
            return .primary
        } else if isHovered {
            return .primary.opacity(0.9)
        } else {
            return .secondary
        }
    }
    
    private var borderGradient: LinearGradient {
        if isSelected {
            return LinearGradient(
                colors: [accentColor.opacity(0.4), accentColor.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if isHovered {
            return LinearGradient(
                colors: [accentColor.opacity(0.2), accentColor.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var borderWidth: CGFloat {
        if isSelected {
            return 1.5
        } else if isHovered {
            return 1
        } else {
            return 0
        }
    }
    
    private var shadowColor: Color {
        if isSelected {
            return accentColor.opacity(0.15)
        } else if isHovered {
            return .black.opacity(0.08)
        } else {
            return .black.opacity(0.04)
        }
    }
    
    private var shadowRadius: CGFloat {
        if isSelected {
            return 8
        } else if isHovered {
            return 6
        } else {
            return 3
        }
    }
    
    private var shadowY: CGFloat {
        if isSelected {
            return 4
        } else if isHovered {
            return 3
        } else {
            return 2
        }
    }
    
    private func openInFinder() {
        #if os(macOS)
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: project.path)
        #endif
    }
}

// MARK: - Dashboard Action Enum

enum GulaDashboardAction: String, CaseIterable, Identifiable, Hashable {
    case overview = "overview"
    case modules = "modules"
    case generateTemplate = "generateTemplate"
    case preCommitHooks = "preCommitHooks"
    case apiGenerator = "apiGenerator"
    case chatAssistant = "chatAssistant"
    case openInFinder = "openInFinder"
    case settings = "settings"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .overview: return "Resumen"
        case .modules: return "Módulos"
        case .generateTemplate: return "Generar Template"
        case .preCommitHooks: return "Pre-commit Hooks"
        case .apiGenerator: return "API Generator"
        case .chatAssistant: return "Chat Asistente"
        case .openInFinder: return "Abrir en Finder"
        case .settings: return "Configuración"
        }
    }
    
    var icon: String {
        switch self {
        case .overview: return "doc.text.magnifyingglass"
        case .modules: return "square.stack.3d.up"
        case .generateTemplate: return "doc.badge.plus"
        case .preCommitHooks: return "checkmark.shield"
        case .apiGenerator: return "network"
        case .chatAssistant: return "message.badge.fill"
        case .openInFinder: return "folder"
        case .settings: return "gear"
        }
    }

    var isEnabled: Bool {
        switch self {
        case .apiGenerator, .chatAssistant: false
        default: true
        }
    }

    static let projectItems: [GulaDashboardAction] = [.overview, .openInFinder]
    static let developmentItems: [GulaDashboardAction] = [.modules, .generateTemplate, .preCommitHooks, .apiGenerator, .chatAssistant]
    static let toolsItems: [GulaDashboardAction] = [.settings]
}

// MARK: - Project Type Extension

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
