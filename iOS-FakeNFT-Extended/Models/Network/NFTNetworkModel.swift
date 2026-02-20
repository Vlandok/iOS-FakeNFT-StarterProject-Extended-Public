import Foundation

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
