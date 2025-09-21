import Foundation
import SwiftUI

enum DocumentAction {
    case open
    case share
    case delete
}

@Observable
class DocumentsViewModel {
    var searchText = ""
    var selectedDocument: Document?
    var documents: [Document] = Document.sampleDocuments
    
    var filteredDocuments: [Document] {
        if searchText.isEmpty {
            return documents
        } else {
            return documents.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    func handleDocumentAction(_ action: DocumentAction, _ document: Document) {
        switch action {
        case .open:
            openDocument(document)
        case .share:
            shareDocument(document)
        case .delete:
            deleteDocument(document)
        }
    }
    
    private func openDocument(_ document: Document) {
        // TODO: Implement open document logic
        print("Opening document: \(document.name)")
    }
    
    private func shareDocument(_ document: Document) {
        // TODO: Implement share document logic
        print("Sharing document: \(document.name)")
    }
    
    private func deleteDocument(_ document: Document) {
        // TODO: Implement delete document logic
        documents.removeAll { $0.id == document.id }
        print("Deleted document: \(document.name)")
    }
}