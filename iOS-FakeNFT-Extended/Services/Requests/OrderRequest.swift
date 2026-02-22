import Foundation

struct OrderGetRequest: NetworkRequest {
    let orderId: String
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/\(orderId)")
    }
}

struct OrderUpdateRequest: NetworkRequest {
    let orderId: String
    let body: OrderUpdateDTO
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/\(orderId)")
    }
    
    var httpMethod: HttpMethod { .put }
    var dto: Encodable? { body }
    var contentType: ContentType { .formUrlEncoded }
}
