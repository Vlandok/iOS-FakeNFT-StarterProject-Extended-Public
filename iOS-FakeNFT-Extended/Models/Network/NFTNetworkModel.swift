import Foundation

public struct NFTNetworkModel: Decodable, Sendable {
    public let id: String
    public let name: String
    public let images: [String]
    public let rating: Int
    public let description: String
    public let price: Double
    public let author: String
}
