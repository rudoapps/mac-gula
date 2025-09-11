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
                        hasProject: false
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

struct ModuleCard: View {
    let module: GulaModule
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(platformColor(for: module.platform))
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(module.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("\(module.platform) • \(module.branch)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(.quaternary)
        )
    }
    
    private func platformColor(for platform: String) -> Color {
        switch platform.lowercased() {
        case "ios": return .blue
        case "android": return .green
        case "web": return .orange
        default: return .gray
        }
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
