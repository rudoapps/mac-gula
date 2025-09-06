import SwiftUI

struct FavoritesView: View {
    @State private var favorites: [FavoriteItem] = FavoriteItem.sampleFavorites
    
    var body: some View {
        VStack(spacing: 20) {
            if favorites.isEmpty {
                EmptyFavoritesView()
            } else {
                FavoritesGrid(favorites: $favorites)
            }
        }
        .padding()
    }
}

struct EmptyFavoritesView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.slash")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("No hay favoritos")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Text("Los elementos que marques como favoritos aparecerán aquí")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FavoritesGrid: View {
    @Binding var favorites: [FavoriteItem]
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach($favorites) { $favorite in
                    FavoriteCard(favorite: $favorite) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            favorites.removeAll { $0.id == favorite.id }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct FavoriteCard: View {
    @Binding var favorite: FavoriteItem
    let onRemove: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                Button(action: onRemove) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.title3)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Image(systemName: favorite.icon)
                .font(.system(size: 32))
                .foregroundColor(favorite.iconColor)
            
            VStack(spacing: 4) {
                Text(favorite.name)
                    .font(.headline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                Text(favorite.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
            }
            
            Text(favorite.formattedDate)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.quaternary, lineWidth: 1)
        )
        .scaleEffect(favorite.isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: favorite.isPressed)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                favorite.isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    favorite.isPressed = false
                }
            }
        }
    }
}

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

#Preview {
    FavoritesView()
        .frame(width: 800, height: 600)
}