import Foundation

public struct NFTByIdRequest: NetworkRequest {
    public let nftId: String
    
    public init(nftId: String) {
        self.nftId = nftId
    }
    
    public var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/nft/\(nftId)")
    }
}
