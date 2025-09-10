import SwiftUI

struct ProjectSelectionView: View {
    @StateObject private var viewModel: ProjectSelectionViewModel
    
    init(viewModel: ProjectSelectionViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                headerView(geometry: geometry)
                
                ScrollView(.vertical, showsIndicators: true) {
                    contentView(geometry: geometry)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .frame(minWidth: 700, maxWidth: .infinity, minHeight: 500, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color(NSColor.windowBackgroundColor),
                    Color(NSColor.controlBackgroundColor).opacity(0.3)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .sheet(isPresented: $viewModel.showingNewProjectSheet) {
            NewProjectView { project in
                viewModel.onProjectSelected?(project)
            }
        }
        .alert("Error", isPresented: $viewModel.showingError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .overlay {
            if viewModel.isLoading {
                Color.black.opacity(0.3)
                    .overlay {
                        ProgressView()
                            .scaleEffect(1.5)
                    }
            }
        }
    }
    
    private func headerView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 24) {
            HStack(spacing: 16) {
                Image(systemName: "hammer.circle.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(.linearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("GULA")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Acelerador de Desarrollo")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, max(20, min(40, geometry.size.width * 0.05)))
            .padding(.top, 32)
            
            Divider()
                .padding(.horizontal, max(20, min(40, geometry.size.width * 0.05)))
        }
        .background(.ultraThinMaterial)
    }
    
    private func contentView(geometry: GeometryProxy) -> some View {
        LazyVStack(spacing: 32) {
            // Main Actions Section
            mainActionsSection
                .padding(.top, 32)
            
            // Recent Projects Section
            if !viewModel.recentProjects.isEmpty {
                recentProjectsSection
            } else {
                emptyStateView
            }
            
            // Bottom spacing for scroll
            Color.clear
                .frame(height: 20)
        }
        .padding(.horizontal, max(20, min(40, geometry.size.width * 0.05)))
    }
    
    private var mainActionsSection: some View {
        VStack(spacing: 20) {
            // Section Title
            HStack {
                Text("¿Qué quieres hacer?")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            // Action Cards
            VStack(spacing: 12) {
                createNewProjectCard
                openExistingProjectCard
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(.secondary.opacity(0.6))
            
            Text("No hay proyectos recientes")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            
            Text("Los proyectos que abras aparecerán aquí")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.secondary.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var createNewProjectCard: some View {
        Button(action: viewModel.createNewProject) {
            HStack(spacing: 20) {
                // Icon
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(.linearGradient(
                        colors: [.blue, .cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text("Crear Nuevo Proyecto")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Inicia un proyecto desde cero con arquetipos optimizados")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    // Tech icons
                    HStack(spacing: 8) {
                        Text("🤖") // Android
                        Text("🍎") // iOS
                        Text("🦋") // Flutter
                        Text("🐍") // Python
                        
                        Text("y más...")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.blue.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
        }
        .contentShape(Rectangle())
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.15), value: false)
        .onHover { hovering in
            NSCursor.pointingHand.set()
        }
    }
    
    private var openExistingProjectCard: some View {
        Button(action: {
            Task {
                await viewModel.openExistingProject()
            }
        }) {
            HStack(spacing: 20) {
                // Icon
                Image(systemName: "folder.circle.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(.linearGradient(
                        colors: [.green, .mint],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text("Abrir Proyecto Existente")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Continúa trabajando en un proyecto ya iniciado")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    // Features
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.green)
                            Text("Auto-detecta")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary.opacity(0.8))
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "cube.box")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.green)
                            Text("Carga módulos")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary.opacity(0.8))
                        }
                    }
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.green.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
        }
        .contentShape(Rectangle())
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.15), value: false)
        .onHover { hovering in
            NSCursor.pointingHand.set()
        }
    }
    
    private var recentProjectsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.linearGradient(
                        colors: [.orange, .yellow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                
                Text("Proyectos Recientes")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Count badge
                if !viewModel.recentProjects.isEmpty {
                    Text("\(viewModel.recentProjects.count)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
            }
            
            // Projects list with scroll
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.recentProjects) { project in
                        RecentProjectRow(
                            project: project,
                            onSelect: { viewModel.selectRecentProject(project) },
                            onRemove: { viewModel.removeRecentProject(project) }
                        )
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(maxHeight: 300) // Limit height to enable scroll
            .scrollBounceBehavior(.basedOnSize)
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.secondary.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct RecentProjectRow: View {
    let project: Project
    let onSelect: () -> Void
    let onRemove: () -> Void
    
    @State private var hovering = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Project Type Icon
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
                
                Text(project.type.icon)
                    .font(.system(size: 16))
            }
            
            // Project Info
            VStack(alignment: .leading, spacing: 4) {
                Text(project.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text(project.displayPath)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    
                    Text("•")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text(project.type.displayName)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text(project.relativeLastOpened)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Actions
            HStack(spacing: 8) {
                if hovering {
                    Button(action: onRemove) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.red.opacity(0.8))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .transition(.scale.combined(with: .opacity))
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.5))
                    .opacity(hovering ? 1 : 0.5)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            hovering 
                ? Color.secondary.opacity(0.1)
                : Color.clear
        )
        .cornerRadius(10)
        .onHover { isHovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                hovering = isHovering
            }
        }
        .onTapGesture {
            onSelect()
        }
        .cursor(.pointingHand)
    }
}

// MARK: - View Modifier for Cursor
extension View {
    func cursor(_ cursor: NSCursor) -> some View {
        self.onHover { hovering in
            if hovering {
                cursor.set()
            } else {
                NSCursor.arrow.set()
            }
        }
    }
}

#Preview {
    let viewModel = ProjectSelectionViewModel()
    return ProjectSelectionView(viewModel: viewModel)
}