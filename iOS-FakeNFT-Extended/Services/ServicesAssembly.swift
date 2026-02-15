import Foundation

@Observable
@MainActor
final class ServicesAssembly {
    
    private let networkClient: NetworkClient
    private let nftStorage: NftStorage
    
    // MARK: - Cached Services
    
    private var _profileService: ProfileService?
    
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
}
