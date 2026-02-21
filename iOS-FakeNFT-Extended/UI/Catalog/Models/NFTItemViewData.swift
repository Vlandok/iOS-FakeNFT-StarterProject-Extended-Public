import Foundation

struct NFTItemViewData: Identifiable, Hashable {
    let id: String
    let name: String
    let imageUrl: URL
    let rating: Int
    let price: Double
    var isFavorite: Bool
    var isInCart: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: NFTItemViewData, rhs: NFTItemViewData) -> Bool {
        lhs.id == rhs.id
    }
}
