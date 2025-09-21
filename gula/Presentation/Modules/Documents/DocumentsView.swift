import SwiftUI

struct DocumentsView: View {
    @State private var viewModel = DocumentsViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            SearchBar(text: $viewModel.searchText)
            
            DocumentsList(
                documents: viewModel.filteredDocuments,
                selection: $viewModel.selectedDocument,
                onDocumentAction: viewModel.handleDocumentAction
            )
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.secondary.opacity(0.08))
                        .frame(width: 28, height: 28)
                    
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                TextField("Buscar documentos...", text: $text)
                    .font(.system(size: 14, weight: .medium))
                    .textFieldStyle(.plain)
                
                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.regularMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color.secondary.opacity(0.2), lineWidth: 1)
            )
        }
        .padding(.bottom, 16)
    }
}

struct DocumentsList: View {
    let documents: [Document]
    @Binding var selection: Document?
    let onDocumentAction: (DocumentAction, Document) -> Void
    
    var body: some View {
        List(documents, selection: $selection) { document in
            DocumentRow(
                document: document,
                onAction: { action in
                    onDocumentAction(action, document)
                }
            )
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
    let onAction: (DocumentAction) -> Void
    
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
                    onAction(.open)
                }
                Button("Compartir") {
                    onAction(.share)
                }
                Divider()
                Button("Eliminar", role: .destructive) {
                    onAction(.delete)
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

#Preview {
    DocumentsView()
        .frame(width: 800, height: 600)
}