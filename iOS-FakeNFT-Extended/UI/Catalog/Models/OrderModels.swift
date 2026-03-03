import Foundation

struct OrderNetworkModel: Decodable {
    let id: String
    let nfts: [String]
}

struct OrderUpdateDTO: Encodable {
    let nfts: [String]
}
