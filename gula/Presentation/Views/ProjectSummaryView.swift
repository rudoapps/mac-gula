import SwiftUI
import Foundation

// MARK: - Project Summary Section

struct ProjectSummarySection: View {
    let project: Project
    let projectManager: ProjectManager
    @State private var gulaStatus: GulaStatus?
    @State private var isLoadingStatus = false
    @State private var statusLoadingProgress: Double = 0.0
    @State private var statusAnimationOffset: CGFloat = -1.0
    @State private var statusPulseScale: CGFloat = 1.0
    
    var body: some View {
        HStack {
            Text("Estado del Proyecto")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            Spacer()
        }
        VStack(alignment: .leading, spacing: 16) {
            if isLoadingStatus {
                ProjectSummaryLoadingView(
                    loadingProgress: statusLoadingProgress,
                    animationOffset: statusAnimationOffset,
                    pulseScale: statusPulseScale
                )
            } else if let status = gulaStatus, status.hasProject {
                ProjectSummaryContentView(status: status)
            } else {
                ProjectSummaryEmptyView()
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.secondary.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .onAppear {
            print("🔍 ProjectSummarySection: onAppear ejecutado para proyecto: \(project.name)")
            loadGulaStatus()
        }
        .onChange(of: isLoadingStatus) { newValue in
            if newValue {
                startStatusLoadingAnimations()
            } else {
                stopStatusLoadingAnimations()
            }
        }
    }
    
    private func loadGulaStatus() {
        print("🔍 ProjectSummarySection: Iniciando carga de gula status")
        isLoadingStatus = true
        statusLoadingProgress = 0.0
        startStatusLoadingAnimations()
        
        Task {
            do {
                // Progressive loading with animations
                await updateStatusProgress(0.25)
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
                
                await updateStatusProgress(0.5)
                let status = try await projectManager.getProjectStatus()
                
                await updateStatusProgress(0.75)
                try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
                
                print("🔍 ProjectSummarySection: gula status obtenido exitosamente")
                
                await updateStatusProgress(1.0)
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
                
                await MainActor.run {
                    self.gulaStatus = status
                    self.isLoadingStatus = false
                    self.statusLoadingProgress = 0.0
                    stopStatusLoadingAnimations()
                }
            } catch {
                print("🔍 ProjectSummarySection: Error en gula status: \(error)")
                await MainActor.run {
                    self.gulaStatus = GulaStatus(
                        projectCreated: nil,
                        gulaVersion: "Error",
                        installedModules: [],
                        hasProject: false,
                        statistics: nil,
                        generatedTemplates: []
                    )
                    self.isLoadingStatus = false
                    self.statusLoadingProgress = 0.0
                    stopStatusLoadingAnimations()
                }
            }
        }
    }
    
    private func updateStatusProgress(_ progress: Double) async {
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.3)) {
                statusLoadingProgress = progress
            }
        }
    }
    
    private func startStatusLoadingAnimations() {
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            statusAnimationOffset = 1.0
        }
        
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

// MARK: - Supporting Views

struct ProjectSummaryLoadingView: View {
    let loadingProgress: Double
    let animationOffset: CGFloat
    let pulseScale: CGFloat
    
    var body: some View {
        VStack(spacing: 20) {
            // Animated header with gula-specific icon
            HStack(spacing: 16) {
                ZStack {
                    // Outer ring with rotating gradient
                    Circle()
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [.blue, .cyan, .mint, .green, .blue]),
                                center: .center,
                                startAngle: .degrees(0),
                                endAngle: .degrees(360)
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 36, height: 36)
                        .rotationEffect(.degrees(animationOffset * 180))
                    
                    // Inner circle with pulsing effect
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 24, height: 24)
                        .scaleEffect(pulseScale)
                        .shadow(color: .blue.opacity(0.3), radius: 6, x: 0, y: 2)
                    
                    // Gula status icon
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(pulseScale * 0.8)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Obteniendo información del proyecto...")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Consultando gula status")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .opacity(pulseScale > 1.05 ? 0.6 : 1.0)
                }
                
                Spacer()
            }
            
            // Enhanced progress bar with shimmer effect
            VStack(spacing: 8) {
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 4)
                    
                    // Animated progress fill
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .cyan, .mint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 4)
                        .scaleEffect(x: loadingProgress, y: 1.0, anchor: .leading)
                        .animation(.easeInOut(duration: 0.3), value: loadingProgress)
                    
                    // Shimmer overlay
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    .white.opacity(0.4),
                                    .white.opacity(0.6),
                                    .white.opacity(0.4),
                                    .clear
                                ],
                                startPoint: UnitPoint(x: animationOffset, y: 0.5),
                                endPoint: UnitPoint(x: animationOffset + 0.3, y: 0.5)
                            )
                        )
                        .frame(height: 4)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                
                // Status indicators with animated dots
                HStack(spacing: 16) {
                    ForEach(0..<3) { index in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(
                                    loadingProgress > Double(index) * 0.33 
                                        ? LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        : LinearGradient(colors: [.secondary.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .frame(width: 6, height: 6)
                                .scaleEffect(loadingProgress > Double(index) * 0.33 ? pulseScale : 0.8)
                                .animation(.easeInOut(duration: 0.4).delay(Double(index) * 0.1), value: loadingProgress)
                            
                            Text([
                                "Escaneando",
                                "Analizando", 
                                "Procesando"
                            ][index])
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(
                                    loadingProgress > Double(index) * 0.33 
                                        ? .primary 
                                        : .secondary.opacity(0.6)
                                )
                                .animation(.easeInOut(duration: 0.3), value: loadingProgress)
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(.vertical, 12)
    }
}

struct ProjectSummaryEmptyView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "folder.badge.questionmark")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sin información de proyecto")
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Text("No se pudo obtener la información del proyecto")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 8)
    }
}

struct ProjectSummaryContentView: View {
    let status: GulaStatus
    
    var body: some View {
        VStack(spacing: 16) {
            ProjectInfoRow(status: status)
            if !status.installedModules.isEmpty {
                ModulesGrid(modules: status.installedModules)
            }
            if !status.generatedTemplates.isEmpty {
                TemplatesSection(templates: status.generatedTemplates)
            }
        }
    }
}

// MARK: - Project Info Components

struct ProjectInfoRow: View {
    let status: GulaStatus
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    var body: some View {
        HStack(spacing: 20) {
            ProjectInfoCard(
                title: "Versión Gula", 
                value: status.gulaVersion, 
                icon: "info.circle.fill", 
                color: .blue
            )
            
            ProjectInfoCard(
                title: "Módulos", 
                value: "\(status.installedModules.count)", 
                icon: "cube.box.fill", 
                color: .green
            )
            
            if let statistics = status.statistics {
                ProjectInfoCard(
                    title: "Templates", 
                    value: "\(statistics.generatedTemplates)", 
                    icon: "doc.text.fill", 
                    color: .orange
                )
                
                ProjectInfoCard(
                    title: "Errores", 
                    value: "\(statistics.operationsWithError)", 
                    icon: "exclamationmark.triangle.fill", 
                    color: .red
                )
            }
            
            if let projectCreated = status.projectCreated {
                ProjectInfoCard(
                    title: "Creado", 
                    value: formatDate(projectCreated), 
                    icon: "calendar", 
                    color: .purple
                )
            }
            
            Spacer()
        }
    }
}

struct ProjectInfoCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
            }
        }
    }
}

// MARK: - Modules Components

struct ModulesGrid: View {
    let modules: [GulaModule]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Módulos Instalados")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                ForEach(modules.prefix(6)) { module in
                    ModuleCard(module: module)
                }
            }
            
            if modules.count > 6 {
                Text("Y \(modules.count - 6) módulos más...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
    }
}

// MARK: - Templates Components

struct TemplatesSection: View {
    let templates: [GulaTemplate]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Templates Generados")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                ForEach(templates.prefix(6)) { template in
                    GeneratedTemplateCard(template: template)
                }
                
                if templates.count > 6 {
                    Text("Y \(templates.count - 6) templates más...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
        }
    }
}

struct GeneratedTemplateCard: View {
    let template: GulaTemplate
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Platform Icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: platformGradientColors(for: template.platform),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                    .shadow(color: platformColor(for: template.platform).opacity(0.3), radius: isHovered ? 4 : 2, x: 0, y: 2)
                
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            // Template Info
            VStack(alignment: .leading, spacing: 4) {
                Text(template.name)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Text(template.platform)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(platformColor(for: template.platform))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(platformColor(for: template.platform).opacity(0.1))
                        .clipShape(Capsule())
                    
                    if let date = template.generatedDate {
                        Text("•")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.secondary.opacity(0.6))
                        
                        Text(formatDate(date))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Status indicator
            VStack(spacing: 2) {
                Image(systemName: "doc.badge.plus")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.orange)
                
                Text("Generado")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.orange)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(backgroundGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(borderGradient, lineWidth: borderWidth)
                )
        )
        .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowY)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter.string(from: date)
    }
    
    // MARK: - Computed Properties
    
    private func platformColor(for platform: String) -> Color {
        switch platform.lowercased() {
        case "ios": return .blue
        case "android": return .green
        case "web": return .orange
        case "flutter": return .cyan
        case "react": return .purple
        default: return .gray
        }
    }
    
    private func platformGradientColors(for platform: String) -> [Color] {
        switch platform.lowercased() {
        case "ios": return [.blue, .blue.opacity(0.7)]
        case "android": return [.green, .green.opacity(0.7)]
        case "web": return [.orange, .orange.opacity(0.7)]
        case "flutter": return [.cyan, .cyan.opacity(0.7)]
        case "react": return [.purple, .purple.opacity(0.7)]
        default: return [.gray, .gray.opacity(0.7)]
        }
    }
    
    private var backgroundGradient: LinearGradient {
        if isHovered {
            return LinearGradient(
                colors: [platformColor(for: template.platform).opacity(0.03), platformColor(for: template.platform).opacity(0.01)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.primary.opacity(0.02), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var borderGradient: LinearGradient {
        if isHovered {
            return LinearGradient(
                colors: [platformColor(for: template.platform).opacity(0.3), platformColor(for: template.platform).opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.secondary.opacity(0.15), Color.secondary.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var borderWidth: CGFloat {
        isHovered ? 1.2 : 0.8
    }
    
    private var shadowColor: Color {
        if isHovered {
            return platformColor(for: template.platform).opacity(0.15)
        } else {
            return .black.opacity(0.05)
        }
    }
    
    private var shadowRadius: CGFloat {
        isHovered ? 6 : 3
    }
    
    private var shadowY: CGFloat {
        isHovered ? 3 : 1
    }
}

struct ModuleCard: View {
    let module: GulaModule
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Platform Icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: platformGradientColors(for: module.platform),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                    .shadow(color: platformColor(for: module.platform).opacity(0.3), radius: isHovered ? 4 : 2, x: 0, y: 2)
                
                Image(systemName: platformIcon(for: module.platform))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            // Module Info
            VStack(alignment: .leading, spacing: 4) {
                Text(module.name)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    // Platform chip
                    Text(module.platform)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(platformColor(for: module.platform))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(platformColor(for: module.platform).opacity(0.1))
                        .clipShape(Capsule())
                    
                    // Branch chip with icon
                    HStack(spacing: 3) {
                        Image(systemName: branchIcon(for: module.branch))
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundColor(branchColor(for: module.branch))
                        
                        Text(module.branch)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(branchColor(for: module.branch))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(branchColor(for: module.branch).opacity(0.1))
                            .overlay(
                                Capsule()
                                    .strokeBorder(branchColor(for: module.branch).opacity(0.2), lineWidth: 0.5)
                            )
                    )
                }
            }
            
            Spacer()
            
            // Status indicator
            VStack(spacing: 2) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.green)
                
                Text("Instalado")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.green)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(backgroundGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(borderGradient, lineWidth: borderWidth)
                )
        )
        .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowY)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private func platformColor(for platform: String) -> Color {
        switch platform.lowercased() {
        case "ios": return .blue
        case "android": return .green
        case "web": return .orange
        case "flutter": return .cyan
        case "react": return .blue
        case "node", "nodejs": return .green
        case "python": return .yellow
        case "java": return .red
        case "javascript", "js": return .yellow
        case "typescript", "ts": return .blue
        case "swift": return .orange
        case "kotlin": return .purple
        case "dart": return .cyan
        default: return .gray
        }
    }
    
    private func platformGradientColors(for platform: String) -> [Color] {
        switch platform.lowercased() {
        case "ios": return [.blue, .blue.opacity(0.7)]
        case "android": return [.green, .green.opacity(0.7)]
        case "web": return [.orange, .orange.opacity(0.7)]
        case "flutter": return [.cyan, .cyan.opacity(0.7)]
        case "react": return [.blue, .blue.opacity(0.7)]
        case "node", "nodejs": return [.green, .green.opacity(0.7)]
        case "python": return [.yellow, .yellow.opacity(0.7)]
        case "java": return [.red, .red.opacity(0.7)]
        case "javascript", "js": return [.yellow, .yellow.opacity(0.7)]
        case "typescript", "ts": return [.blue, .blue.opacity(0.7)]
        case "swift": return [.orange, .orange.opacity(0.7)]
        case "kotlin": return [.purple, .purple.opacity(0.7)]
        case "dart": return [.cyan, .cyan.opacity(0.7)]
        default: return [.gray, .gray.opacity(0.7)]
        }
    }
    
    private func platformIcon(for platform: String) -> String {
        switch platform.lowercased() {
        case "ios": return "applelogo"
        case "android": return "androidlogo"
        case "web": return "globe.americas.fill"
        case "flutter": return "bird.fill"
        case "react": return "atom"
        case "node", "nodejs": return "server.rack"
        case "python": return "snake.circle.fill"
        case "java": return "cup.and.saucer.fill"
        case "javascript", "js": return "js.circle.fill"
        case "typescript", "ts": return "t.circle.fill"
        case "swift": return "swift"
        case "kotlin": return "k.circle.fill"
        case "dart": return "d.circle.fill"
        default: return "cube.fill"
        }
    }
    
    private func branchIcon(for branch: String) -> String {
        switch branch.lowercased() {
        case "main", "master": return "star.fill"
        case "develop", "dev", "development": return "hammer.fill"
        case "staging", "stage": return "theatermasks.fill"
        case "release": return "paperplane.fill"
        case "hotfix": return "wrench.and.screwdriver.fill"
        case "feature": return "lightbulb.fill"
        case "beta": return "testtube.2"
        case "production", "prod": return "checkmark.seal.fill"
        default: 
            if branch.hasPrefix("feature/") || branch.hasPrefix("feat/") {
                return "lightbulb.fill"
            } else if branch.hasPrefix("hotfix/") {
                return "wrench.and.screwdriver.fill"
            } else if branch.hasPrefix("release/") {
                return "paperplane.fill"
            } else {
                return "arrow.branch"
            }
        }
    }
    
    private func branchColor(for branch: String) -> Color {
        switch branch.lowercased() {
        case "main", "master": return .indigo
        case "develop", "dev", "development": return .orange
        case "staging", "stage": return .purple
        case "release": return .blue
        case "hotfix": return .red
        case "feature": return .green
        case "beta": return .cyan
        case "production", "prod": return .mint
        default:
            if branch.hasPrefix("feature/") || branch.hasPrefix("feat/") {
                return .green
            } else if branch.hasPrefix("hotfix/") {
                return .red
            } else if branch.hasPrefix("release/") {
                return .blue
            } else {
                return .secondary
            }
        }
    }
    
    private var backgroundGradient: LinearGradient {
        if isHovered {
            return LinearGradient(
                colors: [platformColor(for: module.platform).opacity(0.04), platformColor(for: module.platform).opacity(0.02)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.primary.opacity(0.02), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var borderGradient: LinearGradient {
        if isHovered {
            return LinearGradient(
                colors: [platformColor(for: module.platform).opacity(0.3), platformColor(for: module.platform).opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.secondary.opacity(0.15), Color.secondary.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var borderWidth: CGFloat {
        isHovered ? 1.2 : 0.8
    }
    
    private var shadowColor: Color {
        if isHovered {
            return platformColor(for: module.platform).opacity(0.15)
        } else {
            return .black.opacity(0.05)
        }
    }
    
    private var shadowRadius: CGFloat {
        isHovered ? 6 : 3
    }
    
    private var shadowY: CGFloat {
        isHovered ? 3 : 1
    }
}

// MARK: - Preview

#Preview {
    let sampleProject = Project(
        name: "Sample Project",
        path: "/Users/sample/project",
        type: .flutter
    )
    
    ProjectSummarySection(
        project: sampleProject,
        projectManager: ProjectManager.shared
    )
    .padding()
    .frame(width: 600)
}
