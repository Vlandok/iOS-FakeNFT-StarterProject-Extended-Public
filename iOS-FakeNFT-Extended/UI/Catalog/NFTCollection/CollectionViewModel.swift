import SwiftUI

@MainActor
final class CollectionViewModel: ObservableObject {
    
    enum State {
        case initial
        case loading
        case loaded([NFTItemViewData])
        case error(String)
    }
    
    @Published private(set) var state: State = .initial
    @Published private var profile: Profile?
    
    let collection: CatalogCollectionDomain
    
    private let nftService: CollectionNFTService
    private let profileService: ProfileService
    private let networkClient: NetworkClient
    
    var collectionName: String { collection.name }
    var authorName: String { collection.author }
    var description: String { collection.description }
    var headerImageUrl: URL { collection.coverUrl }
    
    init(
        collection: CatalogCollectionDomain,
        nftService: CollectionNFTService,
        profileService: ProfileService,
        networkClient: NetworkClient
    ) {
        self.collection = collection
        self.nftService = nftService
        self.profileService = profileService
        self.networkClient = networkClient
        
        loadData()
    }
    
    func updateServices(
        nftService: CollectionNFTService,
        profileService: ProfileService,
        networkClient: NetworkClient
    ) async {
        let viewModel = CollectionViewModel(
            collection: collection,
            nftService: nftService,
            profileService: profileService,
            networkClient: networkClient
        )
        
        await MainActor.run {
            self.state = viewModel.state
            self.profile = viewModel.profile
        }
    }
    
    func loadData() {
        state = .loading
        
        Task { @MainActor in
            do {
                async let nftsTask = nftService.loadNFTs(ids: collection.uniqueNftIds)
                async let profileTask = profileService.loadProfile(id: "1")
                
                let (nftModels, profile) = try await (nftsTask, profileTask)
                
                self.profile = profile
                
                let likedIds = Set(profile.likeIds)
                
                let items = nftModels.map { nft in
                    NFTItemViewData(
                        id: nft.id,
                        name: nft.name,
                        imageUrl: URL(string: nft.images.first ?? "") ?? URL(string: "https://placehold.co/108")!,
                        rating: nft.rating,
                        price: nft.price,
                        isFavorite: likedIds.contains(nft.id),
                        isInCart: false
                    )
                }
                
                state = .loaded(items)
                
            } catch {
                state = .error(Self.mapError(error))
            }
        }
    }
    
    func toggleFavorite(for item: NFTItemViewData) {
        guard let profile = profile else { return }
        
        var newLikes = Set(profile.likeIds)
        if newLikes.contains(item.id) {
            newLikes.remove(item.id)
        } else {
            newLikes.insert(item.id)
        }
        
        updateItemFavoriteStatus(itemId: item.id, isFavorite: newLikes.contains(item.id))
        
        Task { @MainActor in
            do {
                let update = ProfileUpdateDTO(likes: Array(newLikes))
                let updatedProfile = try await profileService.updateProfile(id: "1", update: update)
                self.profile = updatedProfile
            } catch {
                loadData()
            }
        }
    }
    
    func toggleCart(for item: NFTItemViewData) {
        updateItemCartStatus(itemId: item.id, isInCart: !item.isInCart)
        
        Task {
            do {
                let getRequest = OrderGetRequest(orderId: "1")
                let currentOrder: OrderNetworkModel = try await networkClient.send(request: getRequest)
                
                var updatedIds = Set(currentOrder.nfts)
                if updatedIds.contains(item.id) {
                    updatedIds.remove(item.id)
                } else {
                    updatedIds.insert(item.id)
                }
                
                let updateDTO = OrderUpdateDTO(nfts: Array(updatedIds))
                let updateRequest = OrderUpdateRequest(orderId: "1", body: updateDTO)
                let _: OrderNetworkModel = try await networkClient.send(request: updateRequest)
                
            } catch {
                await MainActor.run {
                    updateItemCartStatus(itemId: item.id, isInCart: item.isInCart)
                }
            }
        }
    }
    
    private func updateItemFavoriteStatus(itemId: String, isFavorite: Bool) {
        guard case .loaded(var items) = state else { return }
        
        if let index = items.firstIndex(where: { $0.id == itemId }) {
            items[index].isFavorite = isFavorite
            state = .loaded(items)
        }
    }
    
    private func updateItemCartStatus(itemId: String, isInCart: Bool) {
        guard case .loaded(var items) = state else { return }
        
        if let index = items.firstIndex(where: { $0.id == itemId }) {
            items[index].isInCart = isInCart
            state = .loaded(items)
        }
    }
    
    private static func mapError(_ error: Error) -> String {
        switch error {
        case NetworkClientError.httpStatusCode(let code):
            return "Ошибка сервера: \(code)"
        case NetworkClientError.urlSessionError:
            return "Нет соединения с интернетом"
        case NetworkClientError.parsingError:
            return "Ошибка обработки данных"
        default:
            return error.localizedDescription
        }
    }
}
