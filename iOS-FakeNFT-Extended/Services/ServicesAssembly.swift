import Foundation

@Observable
@MainActor
final class ServicesAssembly {
    
    let networkClient: NetworkClient
    private let nftStorage: NftStorage
    
    // MARK: - Cached Services
    
    private var _profileService: ProfileService?
    private var _collectionsService: CollectionsService?
    private var _collectionNFTService: CollectionNFTService?
    
    init(
        networkClient: NetworkClient,
        nftStorage: NftStorage
    ) {
        self.networkClient = networkClient
        self.nftStorage = nftStorage
    }
    
    var nftService: NftService {
        NftServiceImpl(
            networkClient: networkClient,
            storage: nftStorage
        )
    }
    
    
    var profileService: ProfileService {
        if let service = _profileService {
            return service
        }
        let service = ProfileServiceImpl(networkClient: networkClient)
        _profileService = service
        return service
    }
    
    var basketService: BasketService {
        BasketServiceImpl(networkClient: networkClient)
    }
    
    var collectionsService: CollectionsService {
        if let service = _collectionsService {
            return service
        }
        let service = CollectionsServiceImpl(networkClient: networkClient)
        _collectionsService = service
        return service
    }
    
    var collectionNFTService: CollectionNFTService {
        if let service = _collectionNFTService {
            return service
        }
        let service = CollectionNFTServiceImpl(networkClient: networkClient)
        _collectionNFTService = service
        return service
    }
}
