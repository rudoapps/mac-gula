import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            if viewModel.favorites.isEmpty {
                EmptyFavoritesView()
            } else {
                FavoritesGrid(
                    favorites: $viewModel.favorites,
                    onRemove: viewModel.removeFavorite
                )
            }
        }
        .padding()
        .onAppear {
            viewModel.loadFavorites()
        }
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
    let onRemove: (FavoriteItem) -> Void
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach($favorites) { $favorite in
                    FavoriteCard(favorite: $favorite) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            onRemove(favorite)
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

#Preview {
    FavoritesView()
        .frame(width: 800, height: 600)
}