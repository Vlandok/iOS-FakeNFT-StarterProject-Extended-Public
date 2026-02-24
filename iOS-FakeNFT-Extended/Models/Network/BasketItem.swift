import Foundation

public struct BasketItem: Codable {
    public let id: String
    public let name: String
    public let rating: Int
    public let price: Double
    public let images: [URL]
}

public struct Basket: Codable {
    public let nfts: [String]
}
