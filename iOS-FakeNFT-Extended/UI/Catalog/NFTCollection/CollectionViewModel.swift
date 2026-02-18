import SwiftUI

@MainActor
final class CollectionViewModel: ObservableObject {
    
    // MARK: - Header
    let collectionName: String
    let authorName: String
    let description: String
    let headerImageUrl: URL
    
    // MARK: - NFTs
    @Published private(set) var items: [NFTItemViewData] = []
    @Published private(set) var isLoading = false
    
    // MARK: - Init
    init(
        collectionName: String,
        authorName: String,
        description: String,
        headerImageUrl: URL
    ) {
        self.collectionName = collectionName
        self.authorName = authorName
        self.description = description
        self.headerImageUrl = headerImageUrl
        
        loadMockNFTs()
    }
    
    // MARK: - Actions
    func toggleFavorite(for item: NFTItemViewData) {
        guard let index = items.firstIndex(of: item) else { return }
        items[index].isFavorite.toggle()
    }
    
    func toggleCart(for item: NFTItemViewData) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].isInCart.toggle()
    }
    
    // MARK: - Mock data
    private func loadMockNFTs() {
        items = (1...10).map { index in
            NFTItemViewData(
                id: UUID().uuidString,
                name: "NFT \(index)",
                imageUrl: URL(
                    string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/1.png"
                )!,
                rating: Int.random(in: 1...5),
                price: .random(in: 1...10),
                isFavorite: false,
                isInCart: false
            )
        }
    }
}
