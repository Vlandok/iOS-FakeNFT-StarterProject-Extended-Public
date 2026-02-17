import Foundation

struct NFTItemViewData: Identifiable, Hashable {
    let id: String
    let name: String
    let imageUrl: URL
    let rating: Int
    let price: Int
    var isFavorite: Bool
    var isInCart: Bool
}

