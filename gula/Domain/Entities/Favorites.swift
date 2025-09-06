import Foundation
import SwiftUI

struct FavoriteItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let category: String
    let icon: String
    let iconColor: Color
    let dateAdded: Date
    var isPressed = false
    
    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: dateAdded, relativeTo: Date())
    }
    
    static func == (lhs: FavoriteItem, rhs: FavoriteItem) -> Bool {
        lhs.id == rhs.id
    }
}

extension FavoriteItem {
    static let sampleFavorites = [
        FavoriteItem(name: "Proyecto Gula", category: "Proyecto", icon: "folder.fill", iconColor: .blue, dateAdded: Date().addingTimeInterval(-86400)),
        FavoriteItem(name: "Diseño UI/UX", category: "Documento", icon: "doc.text.fill", iconColor: .green, dateAdded: Date().addingTimeInterval(-172800)),
        FavoriteItem(name: "Tutorial SwiftUI", category: "Video", icon: "video.fill", iconColor: .purple, dateAdded: Date().addingTimeInterval(-259200)),
        FavoriteItem(name: "Notas Reunión", category: "Documento", icon: "note.text", iconColor: .orange, dateAdded: Date().addingTimeInterval(-345600)),
        FavoriteItem(name: "Mockups App", category: "Imagen", icon: "photo.fill", iconColor: .pink, dateAdded: Date().addingTimeInterval(-432000)),
        FavoriteItem(name: "Base de Datos", category: "Archivo", icon: "server.rack", iconColor: .cyan, dateAdded: Date().addingTimeInterval(-518400))
    ]
}