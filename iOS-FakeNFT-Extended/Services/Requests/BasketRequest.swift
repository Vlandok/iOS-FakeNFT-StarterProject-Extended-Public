import Foundation

struct BasketRequest: NetworkRequest {
    typealias Response = Basket
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
}

struct UpdateBasketRequest: NetworkRequest {
    typealias Response = Basket
    
    let nftIds: [String]
    
    var httpMethod: HttpMethod { .put }
    var dto: Encodable? { BasketUpdateDTO(nfts: nftIds) }
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
}

private struct BasketUpdateDTO: Encodable {
    let nfts: [String]
}

