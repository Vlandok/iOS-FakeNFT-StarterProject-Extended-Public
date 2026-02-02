import Foundation

struct NFTByIdRequest: NetworkRequest {
    let nftId: String
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/nft/\(nftId)")
    }
}
