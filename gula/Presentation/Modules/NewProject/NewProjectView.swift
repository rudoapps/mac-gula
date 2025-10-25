import SwiftUI
import AppKit

@available(macOS 15.0, *)
struct NewProjectView: View {
    @State private var viewModel = NewProjectViewModel()
    @Environment(\.dismiss) private var dismiss
    
    let onProjectCreated: (Project) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            if viewModel.isCreating {
                creatingView
            } else {
                ScrollView(.vertical, showsIndicators: true) {
                    formView
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .frame(width: 650, height: 550)
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
        .alert("Error", isPresented: $viewModel.showingError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.blue)
                
                Text("Crear Nuevo Proyecto")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            Divider()
                .padding(.horizontal, 24)
        }
        .background(.ultraThinMaterial)
    }
    
    private var formView: some View {
        LazyVStack(spacing: 28) {
            // Project Name
            ProfessionalTextField(
                title: "Nombre del Proyecto",
                placeholder: "Mi Proyecto",
                icon: "folder.badge.plus",
                text: $viewModel.projectName
            )
            
            // Project Type Selection
            VStack(alignment: .leading, spacing: 10) {
                Text("Tipo de Proyecto")
                    .font(.headline)
                    .fontWeight(.medium)
                
                VStack(spacing: 6) {
                    ForEach(ProjectType.allCases) { type in
                        HStack {
                            Text(type.icon)
                                .font(.title2)

                            VStack(alignment: .leading) {
                                Text(type.displayName)
                                    .font(.headline)
                                Text(type.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if viewModel.selectedType == type {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(viewModel.selectedType == type ? Color.blue.opacity(0.1) : Color.clear)
                                .stroke(viewModel.selectedType == type ? Color.blue : Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.selectedType = type
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
            }
            
            // Location
            VStack(alignment: .leading, spacing: 8) {
                Text("Ubicación")
                    .font(.headline)
                    .fontWeight(.medium)
                
                HStack {
                    Text(viewModel.selectedLocationDisplay)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                    
                    Button("Cambiar") {
                        Task {
                            await viewModel.selectLocation()
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            // Python Stack (only for Python projects)
            if viewModel.selectedType == .python {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Stack de Python")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    VStack(spacing: 6) {
                        ForEach(PythonStack.allCases) { stack in
                            HStack {
                                Text(stack.icon)
                                    .font(.title2)

                                VStack(alignment: .leading) {
                                    Text(stack.displayName)
                                        .font(.headline)
                                    Text(stack.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                if viewModel.selectedPythonStack == stack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(viewModel.selectedPythonStack == stack ? Color.blue.opacity(0.1) : Color.clear)
                                    .stroke(viewModel.selectedPythonStack == stack ? Color.blue : Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.selectedPythonStack = stack
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
                }
            }
            
            // Package Name (only for mobile projects)
            if viewModel.selectedType != .python {
                ProfessionalTextField(
                    title: "Package Name",
                    placeholder: "com.empresa.miapp",
                    icon: "app.badge",
                    text: $viewModel.packageName
                )
            }

            // API Key Status (read-only, loaded automatically)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Clave de API")
                        .font(.headline)
                        .fontWeight(.medium)

                    if viewModel.isLoadingApiKey {
                        ProgressView()
                            .scaleEffect(0.7)
                    }
                }

                HStack {
                    Image(systemName: "key.fill")
                        .foregroundColor(.secondary)

                    Text("Cargada automáticamente desde tu cuenta")
                        .foregroundColor(.secondary)
                        .font(.subheadline)

                    Spacer()

                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(6)
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button("Cancelar") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .keyboardShortcut(.escape)
                
                Button("Crear Proyecto") {
                    Task {
                        if let project = await viewModel.createProject() {
                            onProjectCreated(project)
                            dismiss()
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.isValid)
                .keyboardShortcut(.return)
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 32)
        .padding(.top, 28)
        .padding(.bottom, 32)
    }
    
    private var creatingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Creando proyecto...")
                .font(.headline)
            
            Text(viewModel.creationProgress)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

