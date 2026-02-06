import Foundation

// MARK: - NftService (для детальной страницы NFT)

protocol NftService: Sendable {
    func loadNft(id: String) async throws -> Nft
}

actor NftServiceImpl: NftService {

    private let networkClient: NetworkClient
    private let storage: NftStorage

    init(networkClient: NetworkClient, storage: NftStorage) {
        self.networkClient = networkClient
        self.storage = storage
    }

    func loadNft(id: String) async throws -> Nft {
        if let nft = await storage.getNft(with: id) {
            return nft
        }

        let request = NFTRequest(id: id)
        let nft: Nft = try await networkClient.send(request: request)
        await storage.saveNft(nft)
        return nft
    }
}

// MARK: - MyNFTListService (для экрана "Мои NFT")

protocol MyNFTListService: Sendable {
    func loadNFT(id: String) async throws -> NFTNetworkModel
    func loadNFTs(ids: [String]) async throws -> [NFTNetworkModel]
}

actor MyNFTListServiceImpl: MyNFTListService {
    
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func loadNFT(id: String) async throws -> NFTNetworkModel {
        let request = NFTByIdRequest(nftId: id)
        return try await networkClient.send(request: request)
    }
    
    func loadNFTs(ids: [String]) async throws -> [NFTNetworkModel] {
        try await withThrowingTaskGroup(of: NFTNetworkModel.self) { group in
            for id in ids {
                group.addTask {
                    try await self.loadNFT(id: id)
                }
            }
            
            var results: [NFTNetworkModel] = []
            for try await nft in group {
                results.append(nft)
            }
            return results
        }
    }
}
