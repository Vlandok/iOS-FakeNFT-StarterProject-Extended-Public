import Foundation

struct CatalogCollection: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let nftCount: Int
    let imageUrl: URL
}
