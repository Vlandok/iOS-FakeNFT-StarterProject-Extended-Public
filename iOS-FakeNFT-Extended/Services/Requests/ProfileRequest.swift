import Foundation

/// Запрос на получение профиля пользователя
struct ProfileRequest: NetworkRequest {
    
    let profileId: String
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/\(profileId)")
    }
}

/// Запрос на обновление профиля пользователя
struct ProfileUpdateRequest: NetworkRequest {
    
    let profileId: String
    let body: ProfileUpdateDTO
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/\(profileId)")
    }
    
    var httpMethod: HttpMethod { .put }
    
    var dto: Encodable? { body }
    
    var contentType: ContentType { .formUrlEncoded }
}

/// DTO для обновления профиля
public struct ProfileUpdateDTO: Encodable, Sendable {
    public let name: String?
    public let description: String?
    public let website: String?
    public let avatar: String?
    public let likes: [String]?
    
    public init(
        name: String? = nil,
        description: String? = nil,
        website: String? = nil,
        avatar: String? = nil,
        likes: [String]? = nil
    ) {
        self.name = name
        self.description = description
        self.website = website
        self.avatar = avatar
        self.likes = likes
    }
}
