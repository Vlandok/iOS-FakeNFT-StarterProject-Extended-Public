import Foundation

// MARK: - ProfileService Protocol

protocol ProfileService: Sendable {
    func loadProfile(id: String) async throws -> Profile
    func updateProfile(id: String, update: ProfileUpdateDTO) async throws -> Profile
}

// MARK: - ProfileServiceImpl

/// Сервис для работы с профилем пользователя
/// Реализован как actor для потокобезопасности
actor ProfileServiceImpl: ProfileService {
    
    // MARK: - Dependencies
    
    private let networkClient: NetworkClient
    
    // MARK: - Cache
    
    private var cachedProfile: Profile?
    
    // MARK: - Init
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    // MARK: - Public Methods
    
    /// Загружает профиль пользователя
    /// - Parameter id: Идентификатор профиля
    /// - Returns: Модель профиля
    func loadProfile(id: String) async throws -> Profile {
        // Возвращаем кэш если есть
        if let cached = cachedProfile {
            return cached
        }
        
        let request = ProfileRequest(profileId: id)
        let networkModel: ProfileNetworkModel = try await networkClient.send(request: request)
        let profile = networkModel.toDomain()
        
        cachedProfile = profile
        return profile
    }
    
    /// Обновляет профиль пользователя
    /// - Parameters:
    ///   - id: Идентификатор профиля
    ///   - update: DTO с обновленными данными
    /// - Returns: Обновленная модель профиля
    func updateProfile(id: String, update: ProfileUpdateDTO) async throws -> Profile {
        let request = ProfileUpdateRequest(profileId: id, body: update)
        let networkModel: ProfileNetworkModel = try await networkClient.send(request: request)
        let profile = networkModel.toDomain()
        
        cachedProfile = profile
        return profile
    }
    
    /// Очищает кэш профиля
    func clearCache() {
        cachedProfile = nil
    }
}
