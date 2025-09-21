import Foundation
import SwiftUI

@Observable
class FavoritesViewModel {
    var favorites: [FavoriteItem] = []
    
    func loadFavorites() {
        favorites = FavoriteItem.sampleFavorites
    }
    
    func removeFavorite(_ favorite: FavoriteItem) {
        favorites.removeAll { $0.id == favorite.id }
    }
    
    func addFavorite(_ favorite: FavoriteItem) {
        favorites.append(favorite)
    }
}