import Foundation

// MARK: - FavoritesNFT State

enum FavoritesNFTState: Sendable {
    case initial
    case loading
    case loaded([FavoriteNFTItem])
    case empty
    case error(String)
}

// MARK: - Favorite NFT Item

struct FavoriteNFTItem: Identifiable, Sendable {
    let id: String
    let name: String
    let imageURL: URL?
    let rating: Int
    let price: Double
    var isLiked: Bool
}

// MARK: - FavoritesNFTViewModel

@MainActor
final class FavoritesNFTViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var state: FavoritesNFTState = .initial
    @Published private(set) var nfts: [FavoriteNFTItem] = []
    
    // MARK: - Dependencies
    
    private let nftService: MyNFTListService
    private let likedNFTIds: [String]
    
    // MARK: - Computed Properties
    
    var isEmpty: Bool {
        nfts.isEmpty
    }
    
    var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }
    
    // MARK: - Init
    
    init(
        likedIds: [String],
        nftService: MyNFTListService = MyNFTListServiceImpl(networkClient: DefaultNetworkClient())
    ) {
        self.likedNFTIds = likedIds
        self.nftService = nftService
        loadFavorites()
    }
    
    // MARK: - Public Methods
    
    func loadFavorites() {
        guard !likedNFTIds.isEmpty else {
            state = .empty
            return
        }
        
        state = .loading
        
        Task { @MainActor in
            do {
                let networkModels = try await nftService.loadNFTs(ids: likedNFTIds)
                
                nfts = networkModels.map { model in
                    FavoriteNFTItem(
                        id: model.id,
                        name: model.name,
                        imageURL: model.images.first.flatMap { URL(string: $0) },
                        rating: model.rating,
                        price: model.price,
                        isLiked: true
                    )
                }
                
                state = nfts.isEmpty ? .empty : .loaded(nfts)
            } catch {
                state = .error(Self.mapError(error))
            }
        }
    }
    
    func removeFromFavorites(nftId: String) {
        // Удаляем локально из списка
        nfts.removeAll { $0.id == nftId }
        
        if nfts.isEmpty {
            state = .empty
        } else {
            state = .loaded(nfts)
        }
        
        // TODO: Добавить API вызов для удаления из избранного на сервере
        // Task {
        //     try await profileService.updateLikes(likes: nfts.map { $0.id })
        // }
    }
    
    // MARK: - Private Methods
    
    private static func mapError(_ error: Error) -> String {
        switch error {
        case NetworkClientError.httpStatusCode(let code):
            return NSLocalizedString("Error.network", comment: "") + " (\(code))"
        case NetworkClientError.urlSessionError:
            return NSLocalizedString("Error.network", comment: "")
        case NetworkClientError.parsingError:
            return NSLocalizedString("Error.parsing", comment: "")
        default:
            return error.localizedDescription
        }
    }
}
