import Foundation

protocol CollectionsService: Sendable {
    func loadCollections() async throws -> [CollectionNetworkModel]
}

protocol CollectionNFTService: Sendable {
    func loadNFTs(ids: [String]) async throws -> [NFTNetworkModel]
}

actor CollectionsServiceImpl: CollectionsService {
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func loadCollections() async throws -> [CollectionNetworkModel] {
        let request = CollectionsRequest()
        return try await networkClient.send(request: request)
    }
}

actor CollectionNFTServiceImpl: CollectionNFTService {
    private let networkClient: NetworkClient
    private var cache: [String: NFTNetworkModel] = [:]
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func loadNFTs(ids: [String]) async throws -> [NFTNetworkModel] {
        let uniqueIds = Array(Set(ids))
        
        var results: [NFTNetworkModel] = []
        var idsToLoad: [String] = []
        
        for id in uniqueIds {
            if let cached = cache[id] {
                results.append(cached)
            } else {
                idsToLoad.append(id)
            }
        }
        
        if !idsToLoad.isEmpty {
            try await withThrowingTaskGroup(of: NFTNetworkModel.self) { group in
                for id in idsToLoad {
                    group.addTask {
                        let request = NFTByIdRequest(nftId: id)
                        return try await self.networkClient.send(request: request)
                    }
                }
                
                for try await nft in group {
                    cache[nft.id] = nft
                    results.append(nft)
                }
            }
        }
        
        return results
    }
}
