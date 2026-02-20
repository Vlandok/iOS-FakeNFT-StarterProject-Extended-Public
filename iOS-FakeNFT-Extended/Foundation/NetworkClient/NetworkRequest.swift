import Foundation

public enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public enum ContentType {
    case json
    case formUrlEncoded
}

public protocol NetworkRequest {
    var endpoint: URL? { get }
    var httpMethod: HttpMethod { get }
    var dto: Encodable? { get }
    var contentType: ContentType { get }
}

// default values
public extension NetworkRequest {
    var httpMethod: HttpMethod { .get }
    var dto: Encodable? { nil }
    var contentType: ContentType { .json }
}
