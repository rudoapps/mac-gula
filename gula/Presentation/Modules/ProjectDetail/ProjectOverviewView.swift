import SwiftUI
import Foundation

// MARK: - Project Overview View

struct ProjectOverviewView: View {
    let project: Project
    @Binding var selectedAction: GulaDashboardAction?
    @ObservedObject var projectManager: ProjectManager
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 32) {
                // Project Header Card
                ProjectHeaderCard(project: project)
                
                // Welcome Section
                WelcomeSection()
                
                // Project Summary Section
                ProjectSummarySection(project: project, projectManager: projectManager)

                // Quick Actions Grid
                QuickActionsGrid(selectedAction: $selectedAction)
                
                Spacer(minLength: 20)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

// MARK: - Supporting Views

private struct ProjectHeaderCard: View {
    let project: Project
    
    var body: some View {
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
    }
}

private struct WelcomeSection: View {
    var body: some View {
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
    }
}

private struct QuickActionsGrid: View {
    @Binding var selectedAction: GulaDashboardAction?
    
    var body: some View {
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
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var selectedAction: GulaDashboardAction? = .overview
    
    let sampleProject = Project(
        name: "Sample Project",
        path: "/Users/sample/project",
        type: .flutter
    )
    
    return ProjectOverviewView(
        project: sampleProject,
        selectedAction: $selectedAction,
        projectManager: ProjectManager.shared
    )
    .frame(width: 800, height: 600)
}
