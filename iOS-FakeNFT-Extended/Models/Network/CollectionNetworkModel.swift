import Foundation

struct CollectionNetworkModel: Decodable {
    let id: String
    let name: String
    let cover: String
    let nfts: [String]
    let description: String
    let author: String
}

// MARK: - Domain Model
struct CatalogCollectionDomain: Identifiable, Hashable {
    let id: String
    let name: String
    let nftCount: Int
    let uniqueNftIds: [String]
    let coverUrl: URL
    let description: String
    let author: String
    
    init(from networkModel: CollectionNetworkModel) {
        self.id = networkModel.id
        self.name = networkModel.name
        self.uniqueNftIds = Array(Set(networkModel.nfts))
        self.nftCount = self.uniqueNftIds.count
        self.coverUrl = URL(string: networkModel.cover) ?? URL(string: "https://placehold.co/140")!
        self.description = networkModel.description
        self.author = networkModel.author
    }
}
