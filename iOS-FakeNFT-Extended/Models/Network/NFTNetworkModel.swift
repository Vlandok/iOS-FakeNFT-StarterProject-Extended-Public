import Foundation

public struct NFTNetworkModel: Decodable, Sendable {
    public let id: String
    public let name: String
    public let images: [String]
    public let rating: Int
    public let description: String
    public let price: Double
    public let author: String
    struct NFTNetworkModel: Decodable, Hashable {
        let id: String
        let name: String
        let images: [String]
        let rating: Int
        let price: Double
        let author: String
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: NFTNetworkModel, rhs: NFTNetworkModel) -> Bool {
            lhs.id == rhs.id
        }
    }
}
