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
}

/// DTO для обновления профиля
struct ProfileUpdateDTO: Encodable, Sendable {
    let name: String?
    let description: String?
    let website: String?
    let avatar: String?
    let likes: [String]?
    
    init(
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
