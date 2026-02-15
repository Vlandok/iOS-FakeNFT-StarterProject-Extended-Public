import Foundation

struct CurrenciesRequest: NetworkRequest {
    typealias Response = [Currency]
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/currencies")
    }
}
