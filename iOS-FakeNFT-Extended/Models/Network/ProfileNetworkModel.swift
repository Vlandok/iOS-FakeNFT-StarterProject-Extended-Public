import Foundation

/// Сетевая модель профиля пользователя
/// Используется для декодирования ответа API
struct ProfileNetworkModel: Decodable, Sendable {
    let id: String
    let name: String
    let avatar: String
    let description: String
    let website: String
    let nfts: [String]
    let likes: [String]
}

// MARK: - Mapping to Domain Model

extension ProfileNetworkModel {
    func toDomain() -> Profile {
        Profile(
            id: id,
            name: name,
            description: description,
            website: website,
            avatarURL: URL(string: avatar),
            nftIds: nfts,
            likeIds: likes
        )
    }
}
