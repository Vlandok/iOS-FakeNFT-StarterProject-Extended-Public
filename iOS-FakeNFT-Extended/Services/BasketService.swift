import Foundation

public protocol BasketService {
    func loadBasket() async throws -> Basket
    func updateBasket(nftIds: [String]) async throws -> Basket
    func loadNftDetails(ids: [String]) async throws -> [BasketItem]
    func loadCurrencies() async throws -> [Currency]
}

@MainActor
final class BasketServiceImpl: BasketService {
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func loadBasket() async throws -> Basket {
        let request = BasketRequest()
        return try await networkClient.send(request: request)
    }
    
    func updateBasket(nftIds: [String]) async throws -> Basket {
        let request = UpdateBasketRequest(nftIds: nftIds)
        return try await networkClient.send(request: request)
    }
    
    func loadNftDetails(ids: [String]) async throws -> [BasketItem] {
        try await withThrowingTaskGroup(of: BasketItem?.self) { group in
            for id in ids {
                group.addTask {
                    let request = NFTRequest(id: id)
                    let nft: Nft = try await self.networkClient.send(request: request)
                    return BasketItem(
                        id: nft.id,
                        name: "NFT #\(nft.id)",
                        rating: Int.random(in: 1...5),
                        price: Double.random(in: 0.1...10.0),
                        images: nft.images
                    )
                }
            }
            
            var items: [BasketItem] = []
            for try await item in group {
                if let item = item {
                    items.append(item)
                }
            }
            return items
        }
    }
    
    func loadCurrencies() async throws -> [Currency] {
        let request = CurrenciesRequest()
        return try await networkClient.send(request: request)
    }
}
