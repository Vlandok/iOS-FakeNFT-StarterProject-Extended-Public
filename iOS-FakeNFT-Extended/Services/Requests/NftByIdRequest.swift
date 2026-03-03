import Foundation

public struct NFTRequest: NetworkRequest {

    public let id: String
    
    public init(id: String) {
        self.id = id
    }

    public var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/nft/\(id)")
    }
}
