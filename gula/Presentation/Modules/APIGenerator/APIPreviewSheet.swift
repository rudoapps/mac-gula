import SwiftUI

struct APIPreviewSheet: View {
    let files: [GeneratedFile]
    let project: Project
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFile: GeneratedFile?
    @State private var searchText = ""
    
    var filteredFiles: [GeneratedFile] {
        if searchText.isEmpty {
            return files
        }
        return files.filter { file in
            file.fileName.localizedCaseInsensitiveContains(searchText) ||
            file.content.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationSplitView {
            // File List Sidebar
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "doc.text")
                            .font(.title2)
                            .foregroundColor(project.type.accentColor)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Archivos Generados")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("\(files.count) archivos")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Cerrar") {
                            dismiss()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    
                    // Search
                    SearchField(text: $searchText)
                }
                .padding()
                .background(.regularMaterial)
                
                Divider()
                
                // File Tree
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(groupedFiles, id: \.key) { group in
                            FileGroupSection(
                                title: group.key,
                                files: group.value,
                                selectedFile: $selectedFile,
                                project: project
                            )
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .frame(minWidth: 280, idealWidth: 320)
            
        } detail: {
            // File Content Detail
            if let selectedFile = selectedFile {
                FileDetailView(file: selectedFile, project: project)
            } else {
                FileSelectionPlaceholder(project: project)
            }
        }
        .onAppear {
            // Select first file by default
            if selectedFile == nil, let firstFile = files.first {
                selectedFile = firstFile
            }
        }
    }
    
    private var groupedFiles: [(key: String, value: [GeneratedFile])] {
        let grouped = Dictionary(grouping: filteredFiles) { file in
            file.type.description
        }
        
        return grouped.sorted { first, second in
            let order = ["Data Transfer Object", "Network Service", "Repository", "Use Case", "Domain Model"]
            let firstIndex = order.firstIndex(of: first.key) ?? Int.max
            let secondIndex = order.firstIndex(of: second.key) ?? Int.max
            return firstIndex < secondIndex
        }
    }
}

// MARK: - File Group Section

struct FileGroupSection: View {
    let title: String
    let files: [GeneratedFile]
    @Binding var selectedFile: GeneratedFile?
    let project: Project
    @State private var isExpanded = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Group Header
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                    
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(files.count)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            .background(Color.gray.opacity(0.05))
            
            // Files List
            if isExpanded {
                VStack(spacing: 1) {
                    ForEach(files, id: \.path) { file in
                        FileRow(
                            file: file,
                            isSelected: selectedFile?.path == file.path,
                            project: project,
                            onSelect: {
                                selectedFile = file
                            }
                        )
                    }
                }
            }
        }
    }
}

// MARK: - File Row

struct FileRow: View {
    let file: GeneratedFile
    let isSelected: Bool
    let project: Project
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: file.type.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(project.type.accentColor)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(file.fileName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(isSelected ? .white : .primary)
                        .lineLimit(1)
                    
                    Text(file.path)
                        .font(.system(size: 11))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? project.type.accentColor : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Search Field

struct SearchField: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Buscar archivos...", text: $text)
                .textFieldStyle(.plain)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - File Detail View

struct FileDetailView: View {
    let file: GeneratedFile
    let project: Project
    @State private var showingCopiedAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: file.type.icon)
                        .font(.title2)
                        .foregroundColor(project.type.accentColor)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(file.fileName)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(file.path)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Action Buttons
                    HStack(spacing: 8) {
                        Button(action: copyToClipboard) {
                            Label("Copiar", systemImage: "doc.on.doc")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        
                        Button(action: saveToProject) {
                            Label("Guardar", systemImage: "square.and.arrow.down")
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                }
                
                // File Stats
                HStack(spacing: 16) {
                    FileStatView(
                        title: "Líneas",
                        value: "\(file.content.components(separatedBy: .newlines).count)",
                        icon: "text.alignleft"
                    )
                    
                    FileStatView(
                        title: "Caracteres",
                        value: "\(file.content.count)",
                        icon: "textformat.size"
                    )
                    
                    FileStatView(
                        title: "Tipo",
                        value: file.type.description,
                        icon: file.type.icon
                    )
                }
            }
            .padding()
            .background(.regularMaterial)
            
            Divider()
            
            // Code Content
            ScrollView([.horizontal, .vertical]) {
                Text(file.content)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .background(Color.gray.opacity(0.05))
        }
        .alert("Copiado", isPresented: $showingCopiedAlert) {
            Button("OK") { }
        } message: {
            Text("El código ha sido copiado al portapapeles")
        }
    }
    
    private func copyToClipboard() {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(file.content, forType: .string)
        showingCopiedAlert = true
        #endif
    }
    
    private func saveToProject() {
        // TODO: Implement save to project functionality
        print("Saving file to project: \(file.path)")
    }
}

// MARK: - File Stat View

struct FileStatView: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 13, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Selection Placeholder

struct FileSelectionPlaceholder: View {
    let project: Project
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundColor(project.type.accentColor.opacity(0.3))
            
            VStack(spacing: 4) {
                Text("Selecciona un archivo")
                    .font(.headline)
                
                Text("Elige un archivo de la lista para ver su contenido")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
    }
}

#Preview {
    APIPreviewSheet(
        files: [
            GeneratedFile(
                fileName: "RepositoryResponse.swift",
                path: "Network/DTOs/RepositoryResponse.swift",
                content: """
                import Foundation

                struct RepositoryResponse: Codable {
                    let id: Int
                    let name: String
                    let alias: String
                    let url: String
                }
                """,
                type: .dto
            ),
            GeneratedFile(
                fileName: "APIService.swift",
                path: "Network/Services/APIService.swift",
                content: """
                import Foundation

                protocol APIServiceProtocol {
                    func getRepositories() async throws -> [RepositoryResponse]
                }
                """,
                type: .service
            )
        ],
        project: Project(name: "Sample", path: "/path", type: .ios)
    )
}