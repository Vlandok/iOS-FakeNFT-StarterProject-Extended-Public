import Foundation

struct BasketItem: Codable {
    let id: String
    let name: String
    let rating: Int
    let price: Double
    let images: [URL]
}

struct Basket: Codable {
    let nfts: [String]
}
