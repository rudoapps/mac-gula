import SwiftUI

struct ProjectSelectionView: View {
    @StateObject private var viewModel: ProjectSelectionViewModel
    
    init(viewModel: ProjectSelectionViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            contentView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 800, height: 600)
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
    
    private var headerView: some View {
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
            .padding(.horizontal, 40)
            .padding(.top, 32)
            
            Divider()
                .padding(.horizontal, 40)
        }
        .background(.ultraThinMaterial)
    }
    
    private var contentView: some View {
        VStack(spacing: 40) {
            // Main Action Cards
            HStack(spacing: 40) {
                createNewProjectCard
                openExistingProjectCard
            }
            .padding(.top, 40)
            
            // Recent Projects Section
            if !viewModel.recentProjects.isEmpty {
                recentProjectsSection
            }
            
            Spacer()
        }
        .padding(.horizontal, 60)
    }
    
    private var createNewProjectCard: some View {
        Button(action: viewModel.createNewProject) {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 44, weight: .medium))
                        .foregroundStyle(.linearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                    
                    VStack(spacing: 4) {
                        Text("CREAR NUEVO")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("PROYECTO")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                }
                
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        Text("🤖")
                            .font(.system(size: 16))
                        Text("Android")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    HStack(spacing: 12) {
                        Text("🍎")
                            .font(.system(size: 16))
                        Text("iOS")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    HStack(spacing: 12) {
                        Text("🦋")
                            .font(.system(size: 16))
                        Text("Flutter")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    HStack(spacing: 12) {
                        Text("🐍")
                            .font(.system(size: 16))
                        Text("Python")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(width: 240, height: 280)
            .padding(24)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(.linearGradient(
                        colors: [.blue.opacity(0.5), .cyan.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.2), value: false)
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
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "folder.circle.fill")
                        .font(.system(size: 44, weight: .medium))
                        .foregroundStyle(.linearGradient(
                            colors: [.green, .mint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                    
                    VStack(spacing: 4) {
                        Text("ABRIR EXISTENTE")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("PROYECTO")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                }
                
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.green)
                        Text("Detectar tipo")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    HStack(spacing: 12) {
                        Image(systemName: "cube.box")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.green)
                        Text("Cargar módulos")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    HStack(spacing: 12) {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.green)
                        Text("Ver estructura")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(width: 240, height: 280)
            .padding(24)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(.linearGradient(
                        colors: [.green.opacity(0.5), .mint.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.2), value: false)
        .onHover { hovering in
            NSCursor.pointingHand.set()
        }
    }
    
    private var recentProjectsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.orange)
                Text("Proyectos Recientes")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            LazyVStack(spacing: 8) {
                ForEach(viewModel.recentProjects.prefix(5)) { project in
                    RecentProjectRow(
                        project: project,
                        onSelect: { viewModel.selectRecentProject(project) },
                        onRemove: { viewModel.removeRecentProject(project) }
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct RecentProjectRow: View {
    let project: Project
    let onSelect: () -> Void
    let onRemove: () -> Void
    
    @State private var hovering = false
    
    var body: some View {
        HStack(spacing: 12) {
            Text(project.type.icon)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(project.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Text(project.displayPath)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text("(\(project.type.displayName))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(project.relativeLastOpened)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if hovering {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(hovering ? Color(NSColor.controlAccentColor).opacity(0.1) : Color.clear)
        .cornerRadius(6)
        .onHover { isHovering in
            hovering = isHovering
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
        .frame(width: 800, height: 600)
}