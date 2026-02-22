import Foundation

protocol NftStorage: AnyObject {
    func saveNft(_ nft: Nft) async
    func getNft(with id: String) async -> Nft?
}

public actor NftStorageImpl: NftStorage {
    private var storage: [String: Nft] = [:]
    
    public init() {}

    public func saveNft(_ nft: Nft) async {
        storage[nft.id] = nft
    }

    public func getNft(with id: String) async -> Nft? {
        storage[id]
    }
}
