import Foundation

public protocol BasketService {
    func loadBasket() async throws -> Basket
    func updateBasket(nftIds: [String]) async throws -> Basket
    func loadNftDetails(ids: [String]) async throws -> [BasketItem]
    func loadCurrencies() async throws -> [Currency]
}

final class BasketServiceImpl: BasketService {
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func loadBasket() async throws -> Basket {
        print("[BasketService] INFO: Sending GET request to load basket")
        let request = BasketRequest()
        let basket: Basket = try await networkClient.send(request: request)
        print("[BasketService] INFO: Basket loaded with \(basket.nfts.count) NFT IDs")
        return basket
    }
    
    func updateBasket(nftIds: [String]) async throws -> Basket {
        print("[BasketService] INFO: Sending PUT request to update basket with \(nftIds.count) items")
        let request = UpdateBasketRequest(nftIds: nftIds)
        let basket: Basket = try await networkClient.send(request: request)
        print("[BasketService] INFO: Basket updated successfully")
        return basket
    }
    
    func loadNftDetails(ids: [String]) async throws -> [BasketItem] {
        print("[BasketService] INFO: Loading details for \(ids.count) NFTs in parallel")
        
        let items = try await withThrowingTaskGroup(of: BasketItem.self) { group in
            for id in ids {
                group.addTask {
                    print("[BasketService] DEBUG: Loading NFT with ID: \(id)")
                    let request = NFTByIdRequest(nftId: id)
                    let nft: NFTNetworkModel = try await self.networkClient.send(request: request)
                    
                    let imageUrls = nft.images.compactMap { URL(string: $0) }
                    
                    return BasketItem(
                        id: nft.id,
                        name: nft.name,
                        rating: nft.rating,
                        price: nft.price,
                        images: imageUrls
                    )
                }
            }
            
            var items: [BasketItem] = []
            for try await item in group {
                items.append(item)
            }
            return items
        }
        
        print("[BasketService] INFO: Successfully loaded \(items.count) NFT details")
        return items
    }
    
    func loadCurrencies() async throws -> [Currency] {
        print("[BasketService] INFO: Loading available currencies")
        let request = CurrenciesRequest()
        let currencies: [Currency] = try await networkClient.send(request: request)
        print("[BasketService] INFO: Loaded \(currencies.count) currencies")
        return currencies
    }
}
