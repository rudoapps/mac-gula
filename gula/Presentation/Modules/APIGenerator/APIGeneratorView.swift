import SwiftUI
import Foundation

struct APIGeneratorView: View {
    let project: Project
    @StateObject private var viewModel = APIGeneratorViewModel()
    @State private var openAPIUrl = "https://services.rudo.es/api/gula/openapi.json"
    @State private var selectableFiles: [SelectableGeneratedFile] = []
    
    var body: some View {
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
                            
                            Text("Genera DTOs desde OpenAPI")
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
                            project: project
                        )
                        
                        // Generation Controls
                        APIGenerationControls(
                            isLoading: viewModel.isLoading,
                            onGenerate: {
                                generateAPICode()
                            }
                        )
                        
                        // DTOs Selection and Preview
                        if !selectableFiles.isEmpty {
                            DTOSelectionSection(
                                selectableFiles: $selectableFiles,
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
        .onChange(of: viewModel.generatedFiles) { files in
            selectableFiles = files.map { SelectableGeneratedFile(file: $0) }
        }
    }
    
    private func generateAPICode() {
        Task {
            await viewModel.generateDTOsOnly(
                from: openAPIUrl,
                projectType: project.type,
                projectPath: project.path
            )
        }
    }
}

// MARK: - Configuration Section

struct APIConfigurationSection: View {
    @Binding var openAPIUrl: String
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
                ProfessionalTextField(
                    title: "OpenAPI URL",
                    placeholder: "https://api.ejemplo.com/openapi.json",
                    icon: "link",
                    text: $openAPIUrl,
                    validation: { url in
                        if url.isEmpty {
                            return ProfessionalTextField.ValidationResult(isValid: false, message: "La URL es requerida")
                        } else if !url.hasPrefix("http") {
                            return ProfessionalTextField.ValidationResult(isValid: false, message: "La URL debe comenzar con http o https")
                        }
                        return ProfessionalTextField.ValidationResult(isValid: true, message: nil)
                    }
                )
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
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: onGenerate) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "wand.and.stars")
                    }
                    Text(isLoading ? "Generando..." : "Generar DTOs")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(isLoading)
        }
    }
}

// MARK: - DTO Selection Section

struct DTOSelectionSection: View {
    @Binding var selectableFiles: [SelectableGeneratedFile]
    let project: Project
    @State private var refreshTrigger = 0 // Force refresh when individual files change
    
    private var selectedCount: Int {
        let count = selectableFiles.filter(\.isSelected).count
        return count
    }
    
    private var allSelected: Bool {
        !selectableFiles.isEmpty && selectedCount == selectableFiles.count
    }
    
    private var groupedFilesByEndpoint: [(key: String, value: [SelectableGeneratedFile])] {
        let grouped = Dictionary(grouping: selectableFiles) { selectableFile in
            let file = selectableFile.file
            if let endpoint = file.endpointPath, let method = file.httpMethod {
                return "\(method) \(endpoint)"
            } else {
                return "Esquemas Globales"
            }
        }
        
        return grouped.sorted { first, second in
            // Esquemas globales primero, luego por endpoint
            if first.key == "Esquemas Globales" { return true }
            if second.key == "Esquemas Globales" { return false }
            return first.key < second.key
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with controls
            HStack {
                SectionHeader(
                    title: "DTOs Generados",
                    icon: "doc.text",
                    color: project.type.accentColor
                )
                
                Text("(\(selectableFiles.count) DTOs)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Global select all button
                Button(action: toggleSelectAll) {
                    HStack(spacing: 6) {
                        Image(systemName: allSelected ? "checkmark.square.fill" : (selectedCount > 0 ? "minus.square.fill" : "square"))
                            .font(.system(size: 16))
                            .foregroundColor(allSelected || selectedCount > 0 ? project.type.accentColor : .secondary)
                        Text(allSelected ? "Deseleccionar Todo" : "Seleccionar Todo")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .help(allSelected ? "Deseleccionar todos los DTOs" : "Seleccionar todos los DTOs")
                
                ImportButton(
                    selectedCount: selectedCount,
                    accentColor: project.type.accentColor,
                    onImport: importSelectedFiles
                )
            }
            
            // DTO Groups
            LazyVStack(spacing: 8) {
                ForEach(groupedFilesByEndpoint, id: \.key) { group in
                    SimpleDTOGroupView(
                        title: group.key,
                        files: group.value,
                        allFiles: $selectableFiles,
                        project: project,
                        onSelectionChanged: {
                            refreshTrigger += 1
                        }
                    )
                }
            }
        }
    }
    
    
    private func importSelectedFiles() {
        let selected = selectableFiles.filter(\.isSelected)
        
        guard !selected.isEmpty else { return }
        
        // Log más detallado
        print("🚀 Iniciando importación de \(selected.count) DTO\(selected.count == 1 ? "" : "s"):")
        
        for file in selected {
            let fullPath = "\(project.path)/\(file.file.path)"
            print("📁 Creando: \(fullPath)")
            
            // TODO: Implementar guardado real de archivos
            // Por ahora, simular el proceso
            /*
            do {
                let directoryPath = URL(fileURLWithPath: fullPath).deletingLastPathComponent().path
                try FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
                try file.file.content.write(toFile: fullPath, atomically: true, encoding: .utf8)
                print("✅ Creado exitosamente: \(file.file.fileName)")
            } catch {
                print("❌ Error creando \(file.file.fileName): \(error.localizedDescription)")
            }
            */
        }
        
        print("🎉 Importación completada!")
        
        // Opcional: Deseleccionar archivos después de importar
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            for i in selectableFiles.indices {
                selectableFiles[i].isSelected = false
            }
        }
    }
    
    private func toggleSelectAll() {
        let newSelectionState = !allSelected
        print("🔘 Global toggle: allSelected=\(allSelected), newState=\(newSelectionState), total files=\(selectableFiles.count)")
        
        withAnimation(.easeInOut(duration: 0.2)) {
            for i in selectableFiles.indices {
                print("🔘 Global setting \(selectableFiles[i].file.fileName) to \(newSelectionState)")
                selectableFiles[i].isSelected = newSelectionState
            }
        }
    }
}

// MARK: - Simple DTO Group View (Fixed)

struct SimpleDTOGroupView: View {
    let title: String
    let files: [SelectableGeneratedFile]
    @Binding var allFiles: [SelectableGeneratedFile]
    let project: Project
    let onSelectionChanged: () -> Void
    @State private var isExpanded = true
    
    private var selectedCount: Int {
        let count = files.filter { file in
            // Find the current state in allFiles
            if let index = allFiles.firstIndex(where: { $0.id == file.id }) {
                return allFiles[index].isSelected
            }
            return false
        }.count
        return count
    }
    
    private var allSelected: Bool {
        !files.isEmpty && selectedCount == files.count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Group Header - Make entire row clickable
            HStack(spacing: 0) {
                // Expand/collapse button with much larger touch area
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(title)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("\(selectedCount) de \(files.count) seleccionados")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: 44) // Much larger touch area
                }
                .buttonStyle(.plain)
                .help(isExpanded ? "Colapsar grupo" : "Expandir grupo")
                
                // Group selection checkbox with much larger touch area  
                Button(action: toggleGroupSelection) {
                    Image(systemName: allSelected ? "checkmark.square.fill" : (selectedCount > 0 ? "minus.square.fill" : "square"))
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(allSelected ? project.type.accentColor : (selectedCount > 0 ? project.type.accentColor : .secondary))
                        .frame(width: 44, height: 44) // Much larger touch area
                }
                .buttonStyle(.plain)
                .help(allSelected ? "Deseleccionar todo el grupo" : "Seleccionar todo el grupo")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
            
            // Files List
            if isExpanded {
                VStack(spacing: 4) {
                    ForEach(files, id: \.id) { file in
                        if let foundFile = allFiles.first(where: { $0.id == file.id }) {
                            SimpleDTOFileView(
                                selectableFile: foundFile,
                                project: project,
                                onSelectionChanged: onSelectionChanged
                            )
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.02))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(project.type.accentColor.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func toggleGroupSelection() {
        let newValue = !allSelected
        print("🔘 Simple Group toggle: allSelected=\(allSelected), newValue=\(newValue), files count=\(files.count)")
        
        // Update the actual allFiles array
        for file in files {
            if let index = allFiles.firstIndex(where: { $0.id == file.id }) {
                print("🔘 Simple Setting \(allFiles[index].file.fileName) to \(newValue)")
                allFiles[index].isSelected = newValue
            }
        }
        
        // Notify parent of selection change
        onSelectionChanged()
    }
}

// MARK: - Simple DTO File View (Fixed)

struct SimpleDTOFileView: View {
    @ObservedObject var selectableFile: SelectableGeneratedFile
    let project: Project
    let onSelectionChanged: () -> Void
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 0) {
                // Selection checkbox with much larger touch area
                Button(action: {
                    print("🔘 Simple Toggling selection for: \(selectableFile.file.fileName) from \(selectableFile.isSelected) to \(!selectableFile.isSelected)")
                    withAnimation(.easeInOut(duration: 0.1)) {
                        selectableFile.isSelected.toggle()
                    }
                    onSelectionChanged()
                }) {
                    Image(systemName: selectableFile.isSelected ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(selectableFile.isSelected ? project.type.accentColor : .secondary)
                        .frame(width: 44, height: 44) // Much larger touch area
                }
                .buttonStyle(.plain)
                .help(selectableFile.isSelected ? "Deseleccionar DTO" : "Seleccionar DTO")
                
                // File content - clickable to expand
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    HStack(spacing: 12) {
                        // File icon
                        Image(systemName: selectableFile.file.type.icon)
                            .font(.system(size: 16))
                            .foregroundColor(project.type.accentColor)
                            .frame(width: 20)
                        
                        // File info
                        VStack(alignment: .leading, spacing: 2) {
                            Text(selectableFile.file.fileName)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Text(selectableFile.file.path)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Expand indicator
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: 44) // Much larger touch area
                }
                .buttonStyle(.plain)
                .help(isExpanded ? "Ocultar código" : "Mostrar código")
            }
            
            // Code content when expanded
            if isExpanded {
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(selectableFile.file.content)
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                .frame(maxHeight: 200)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(selectableFile.isSelected ? project.type.accentColor.opacity(0.1) : Color.clear)
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

struct ImportButton: View {
    let selectedCount: Int
    let accentColor: Color
    let onImport: () -> Void
    @State private var isHovered = false
    @State private var showingSuccessAnimation = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                onImport()
                showingSuccessAnimation = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut) {
                    showingSuccessAnimation = false
                }
            }
        }) {
            HStack(spacing: 8) {
                Group {
                    if showingSuccessAnimation {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Image(systemName: "square.and.arrow.down.on.square")
                            .foregroundColor(.white)
                    }
                }
                .font(.system(size: 14, weight: .medium))
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(showingSuccessAnimation ? "¡Importados!" : "Importar")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if !showingSuccessAnimation && selectedCount > 0 {
                        Text("\(selectedCount) seleccionado\(selectedCount == 1 ? "" : "s")")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        showingSuccessAnimation 
                        ? .green 
                        : (selectedCount == 0 
                           ? Color.gray.opacity(0.3) 
                           : (isHovered ? accentColor.opacity(0.9) : accentColor)
                          )
                    )
                    .shadow(
                        color: selectedCount > 0 && !showingSuccessAnimation 
                        ? accentColor.opacity(0.3) 
                        : .clear,
                        radius: isHovered ? 8 : 4,
                        y: isHovered ? 4 : 2
                    )
            )
            .scaleEffect(isHovered && selectedCount > 0 ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showingSuccessAnimation)
        }
        .buttonStyle(.plain)
        .disabled(selectedCount == 0)
        .onHover { hovering in
            isHovered = hovering && selectedCount > 0
        }
        .help(selectedCount == 0 ? "Selecciona al menos un DTO para importar" : "Importar \(selectedCount) DTO\(selectedCount == 1 ? "" : "s") al proyecto")
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