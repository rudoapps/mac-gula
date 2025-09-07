import SwiftUI

struct NewProjectView: View {
    @StateObject private var viewModel = NewProjectViewModel()
    @Environment(\.dismiss) private var dismiss
    
    let onProjectCreated: (Project) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            if viewModel.isCreating {
                creatingView
            } else {
                formView
            }
        }
        .frame(width: 600, height: 500)
        .alert("Error", isPresented: $viewModel.showingError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                
                Text("Crear Nuevo Proyecto")
                    .font(.title)
                    .fontWeight(.semibold)
            }
            .padding(.top, 20)
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
                .padding(.horizontal, 20)
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private var formView: some View {
        VStack(spacing: 24) {
            // Project Name
            VStack(alignment: .leading, spacing: 8) {
                Text("Nombre del Proyecto")
                    .font(.headline)
                
                TextField("Mi Proyecto", text: $viewModel.projectName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.body)
            }
            
            // Project Type Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Tipo de Proyecto")
                    .font(.headline)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(ProjectType.allCases) { type in
                        ProjectTypeCard(
                            type: type,
                            isSelected: viewModel.selectedType == type,
                            onTap: {
                                viewModel.selectedType = type
                            }
                        )
                    }
                }
            }
            
            // Location
            VStack(alignment: .leading, spacing: 8) {
                Text("Ubicación")
                    .font(.headline)
                
                HStack {
                    Text(viewModel.selectedLocationDisplay)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(6)
                    
                    Button("Cambiar") {
                        Task {
                            await viewModel.selectLocation()
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            // API Key
            VStack(alignment: .leading, spacing: 8) {
                Text("Clave de API")
                    .font(.headline)
                
                SecureField("Ingresa tu clave de API", text: $viewModel.apiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.body)
                
                Text("La clave de API es necesaria para descargar los arquetipos de proyecto desde los repositorios privados.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 16) {
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
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 40)
        .padding(.top, 20)
    }
    
    private var creatingView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Creando proyecto...")
                .font(.headline)
            
            Text(viewModel.creationProgress)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ProjectTypeCard: View {
    let type: ProjectType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Text(type.icon)
                    .font(.title)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(type.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(type.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
            }
            .padding(12)
            .background(isSelected ? Color.blue.opacity(0.1) : Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NewProjectView { _ in
        
    }
}