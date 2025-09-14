import SwiftUI
import Foundation

struct APIGeneratorView: View {
    let project: Project
    @StateObject private var viewModel = APIGeneratorViewModel()
    @State private var openAPIUrl = "https://services.rudo.es/api/gula/openapi.json"
    @State private var generatedCode = ""
    @State private var selectedFramework: NetworkingFramework = .urlSession
    @State private var selectedArchitecture: Architecture = .cleanArchitecture
    @State private var showingPreview = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "network")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(project.type.accentColor)
                        
                        VStack(alignment: .leading) {
                            Text("API Code Generator")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Genera DTOs y servicios desde OpenAPI")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Configuration Section
                        APIConfigurationSection(
                            openAPIUrl: $openAPIUrl,
                            framework: $selectedFramework,
                            architecture: $selectedArchitecture,
                            project: project
                        )
                        
                        // Generation Controls
                        APIGenerationControls(
                            isLoading: viewModel.isLoading,
                            onGenerate: {
                                generateAPICode()
                            },
                            onPreview: {
                                showingPreview = true
                            }
                        )
                        
                        // Generated Code Preview
                        if !viewModel.generatedFiles.isEmpty {
                            APICodePreview(
                                files: viewModel.generatedFiles,
                                project: project
                            )
                        }
                        
                        // Error Display
                        if let error = viewModel.errorMessage {
                            ErrorBanner(message: error)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("API Generator")
        .sheet(isPresented: $showingPreview) {
            APIPreviewSheet(
                files: viewModel.generatedFiles,
                project: project
            )
        }
    }
    
    private func generateAPICode() {
        Task {
            await viewModel.generateAPI(
                from: openAPIUrl,
                framework: selectedFramework,
                architecture: selectedArchitecture,
                projectType: project.type,
                projectPath: project.path
            )
        }
    }
}

// MARK: - Configuration Section

struct APIConfigurationSection: View {
    @Binding var openAPIUrl: String
    @Binding var framework: NetworkingFramework
    @Binding var architecture: Architecture
    let project: Project
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Configuración",
                icon: "gear",
                color: project.type.accentColor
            )
            
            VStack(spacing: 12) {
                // OpenAPI URL
                VStack(alignment: .leading, spacing: 6) {
                    Label("OpenAPI URL", systemImage: "link")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("https://api.ejemplo.com/openapi.json", text: $openAPIUrl)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Framework Selection
                VStack(alignment: .leading, spacing: 6) {
                    Label("Framework de Red", systemImage: "network")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Picker("Framework", selection: $framework) {
                        ForEach(NetworkingFramework.allCases, id: \.self) { fw in
                            HStack {
                                Image(systemName: fw.icon)
                                Text(fw.displayName)
                            }.tag(fw)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Architecture Selection
                VStack(alignment: .leading, spacing: 6) {
                    Label("Arquitectura", systemImage: "building.columns")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Picker("Arquitectura", selection: $architecture) {
                        ForEach(Architecture.allCases, id: \.self) { arch in
                            HStack {
                                Image(systemName: arch.icon)
                                Text(arch.displayName)
                            }.tag(arch)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
            )
        }
    }
}

// MARK: - Generation Controls

struct APIGenerationControls: View {
    let isLoading: Bool
    let onGenerate: () -> Void
    let onPreview: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                Button(action: onGenerate) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "wand.and.stars")
                        }
                        Text(isLoading ? "Generando..." : "Generar API")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading)
                
                Button(action: onPreview) {
                    HStack {
                        Image(systemName: "eye")
                        Text("Vista Previa")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .controlSize(.large)
        }
    }
}

// MARK: - Code Preview

struct APICodePreview: View {
    let files: [GeneratedFile]
    let project: Project
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Código Generado",
                icon: "doc.text",
                color: project.type.accentColor
            )
            
            LazyVStack(spacing: 12) {
                ForEach(files, id: \.path) { file in
                    GeneratedFileCard(file: file, project: project)
                }
            }
        }
    }
}

// MARK: - Generated File Card

struct GeneratedFileCard: View {
    let file: GeneratedFile
    let project: Project
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: file.type.icon)
                    .foregroundColor(project.type.accentColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(file.fileName)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text(file.type.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
            }
            
            if isExpanded {
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(file.content)
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                .frame(maxHeight: 200)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(project.type.accentColor.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Supporting Views

struct SectionHeader: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
        }
    }
}

struct ErrorBanner: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.red)
            Text(message)
                .foregroundColor(.red)
            Spacer()
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
}


#Preview {
    APIGeneratorView(project: Project(name: "Sample", path: "/path", type: .ios))
}