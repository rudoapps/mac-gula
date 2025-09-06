import SwiftUI

struct DocumentsView: View {
    @State private var searchText = ""
    @State private var selectedDocument: Document?
    
    let documents = Document.sampleDocuments
    
    var filteredDocuments: [Document] {
        if searchText.isEmpty {
            return documents
        } else {
            return documents.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SearchBar(text: $searchText)
            
            DocumentsList(documents: filteredDocuments, selection: $selectedDocument)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Buscar documentos...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.regularMaterial)
        )
        .padding(.bottom, 16)
    }
}

struct DocumentsList: View {
    let documents: [Document]
    @Binding var selection: Document?
    
    var body: some View {
        List(documents, selection: $selection) { document in
            DocumentRow(document: document)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.regularMaterial)
                        .padding(.vertical, 2)
                )
        }
        .listStyle(PlainListStyle())
        .background(.clear)
    }
}

struct DocumentRow: View {
    let document: Document
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: document.icon)
                .font(.title3)
                .foregroundColor(document.iconColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(document.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Text(document.formattedSize)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(document.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Menu {
                Button("Abrir") {
                    
                }
                Button("Compartir") {
                    
                }
                Divider()
                Button("Eliminar", role: .destructive) {
                    
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.secondary)
            }
            .menuStyle(BorderlessButtonMenuStyle())
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

struct Document: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let size: Int
    let dateModified: Date
    let type: DocumentType
    
    var icon: String {
        switch type {
        case .text: return "doc.text.fill"
        case .pdf: return "doc.fill"
        case .image: return "photo.fill"
        case .video: return "video.fill"
        case .audio: return "music.note"
        }
    }
    
    var iconColor: Color {
        switch type {
        case .text: return .blue
        case .pdf: return .red
        case .image: return .green
        case .video: return .purple
        case .audio: return .orange
        }
    }
    
    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(size))
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: dateModified)
    }
}

enum DocumentType {
    case text, pdf, image, video, audio
}

extension Document {
    static let sampleDocuments = [
        Document(name: "Proyecto Final.docx", size: 2048000, dateModified: Date().addingTimeInterval(-3600), type: .text),
        Document(name: "Presentación.pdf", size: 5120000, dateModified: Date().addingTimeInterval(-7200), type: .pdf),
        Document(name: "Captura de pantalla.png", size: 1024000, dateModified: Date().addingTimeInterval(-10800), type: .image),
        Document(name: "Video tutorial.mp4", size: 52428800, dateModified: Date().addingTimeInterval(-14400), type: .video),
        Document(name: "Notas de audio.m4a", size: 8192000, dateModified: Date().addingTimeInterval(-18000), type: .audio),
        Document(name: "Informe mensual.xlsx", size: 1536000, dateModified: Date().addingTimeInterval(-21600), type: .text),
        Document(name: "Manual usuario.pdf", size: 3072000, dateModified: Date().addingTimeInterval(-25200), type: .pdf),
        Document(name: "Logo empresa.svg", size: 512000, dateModified: Date().addingTimeInterval(-28800), type: .image)
    ]
}

#Preview {
    DocumentsView()
        .frame(width: 800, height: 600)
}