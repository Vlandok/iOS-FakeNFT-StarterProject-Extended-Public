import Foundation

// MARK: - Profile State

enum ProfileState: Sendable {
    case initial
    case loading
    case loaded(Profile)
    case error(String)
}

// MARK: - Profile Model

public struct Profile: Sendable {
    public let id: String
    public let name: String
    public let description: String
    public let website: String
    public let avatarURL: URL?
    public let nftIds: [String]
    public let likeIds: [String]
    
    public var nftsCount: Int { nftIds.count }
    public var favoritesCount: Int { likeIds.count }
}

// MARK: - ProfileViewModel

@MainActor
final class ProfileViewModel: ObservableObject {
    
    // MARK: - Constants
    
    private enum Constants {
        static let defaultProfileId = "1"
    }
    
    // MARK: - Published Properties
    
    @Published private(set) var state: ProfileState = .initial
    @Published private(set) var profile: Profile?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let profileService: ProfileService
    
    // MARK: - Computed Properties
    
    var userName: String {
        profile?.name ?? ""
    }
    
    var userDescription: String {
        profile?.description ?? ""
    }
    
    var userWebsite: String {
        profile?.website ?? ""
    }
    
    var userAvatarURL: URL? {
        profile?.avatarURL
    }
    
    var myNftCount: Int {
        profile?.nftsCount ?? 0
    }
    
    var favoriteNftCount: Int {
        profile?.favoritesCount ?? 0
    }
    
    var nftIds: [String] {
        profile?.nftIds ?? []
    }
    
    var likeIds: [String] {
        profile?.likeIds ?? []
    }
    
    var hasWebsite: Bool {
        !userWebsite.isEmpty
    }
    
    var websiteURL: URL? {
        guard let urlString = profile?.website, !urlString.isEmpty else { return nil }
        let fullUrlString = urlString.hasPrefix("http") ? urlString : "https://\(urlString)"
        guard let encodedString = fullUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: encodedString)
    }
    
    // MARK: - Init
    
    init(profileService: ProfileService = ProfileServiceImpl(networkClient: DefaultNetworkClient())) {
        self.profileService = profileService
        loadProfile()
    }
    
    // MARK: - Public Methods
    
    func loadProfile() {
        state = .loading
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            do {
                let profile = try await profileService.loadProfile(id: Constants.defaultProfileId)
                self.profile = profile
                self.state = .loaded(profile)
            } catch {
                let message = Self.mapError(error)
                self.state = .error(message)
                self.errorMessage = message
            }
            self.isLoading = false
        }
    }
    
    func updateProfile(_ profile: Profile) {
        self.profile = profile
        self.state = .loaded(profile)
    }
    
    func updateLikes(_ newLikes: [String]) {
        guard let currentProfile = profile else { return }
        
        let updatedProfile = Profile(
            id: currentProfile.id,
            name: currentProfile.name,
            description: currentProfile.description,
            website: currentProfile.website,
            avatarURL: currentProfile.avatarURL,
            nftIds: currentProfile.nftIds,
            likeIds: newLikes
        )
        
        self.profile = updatedProfile
        self.state = .loaded(updatedProfile)
    }
    
    // MARK: - Private Methods
    
    private static func mapError(_ error: Error) -> String {
        switch error {
        case NetworkClientError.httpStatusCode(let code):
            return NSLocalizedString("Error.network", comment: "") + " (\(code))"
        case NetworkClientError.urlSessionError:
            return NSLocalizedString("Error.network", comment: "")
        case NetworkClientError.parsingError:
            return NSLocalizedString("Error.parsing", comment: "")
        default:
            return error.localizedDescription
        }
    }
}
