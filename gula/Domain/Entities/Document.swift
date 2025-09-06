import Foundation
import SwiftUI

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