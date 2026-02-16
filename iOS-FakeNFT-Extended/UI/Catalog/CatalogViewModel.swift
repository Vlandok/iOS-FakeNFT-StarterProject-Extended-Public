import Foundation
import SwiftUI

@MainActor
final class CatalogViewModel: ObservableObject {
    
    @Published private(set) var collections: [CatalogCollection] = []
    @Published var selectedCollection: CatalogCollection?
    
    private var originalCollections: [CatalogCollection] = []
    private var currentSort: CatalogSortType?
    
    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        let data = [
            CatalogCollection(
                name: "singulis epicuri",
                nftCount: 12,
                imageUrl: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Обложки_коллекций/Brown.png")!
            ),
            CatalogCollection(
                name: "unum reque",
                nftCount: 8,
                imageUrl: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Обложки_коллекций/White.png")!
            ),
            CatalogCollection(
                name: "quem varius",
                nftCount: 20,
                imageUrl: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Обложки_коллекций/Pink.png")!
            ),
            CatalogCollection(
                name: "option moderatius",
                nftCount: 5,
                imageUrl: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Обложки_коллекций/Blue.png")!
            ),
            CatalogCollection(
                name: "simul dolore",
                nftCount: 14,
                imageUrl: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Обложки_коллекций/Gray.png")!
            )
        ]
        
        originalCollections = data
        collections = data
    }
    
    func sortCollection(by type: CatalogSortType) {
        currentSort = type
        
        switch type {
        case .byName:
            collections = originalCollections.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        case .byNftCount:
            collections = originalCollections.sorted {
                $0.nftCount > $1.nftCount
            }
        }
    }
    
    func selectCollection(_ collection: CatalogCollection) {
        selectedCollection = collection
    }
}
