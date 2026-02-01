import Foundation

// MARK: - Profile State

enum ProfileState: Sendable {
    case initial
    case loading
    case loaded(Profile)
    case error(String)
}

// MARK: - Profile Model

struct Profile: Sendable {
    let id: String
    let name: String
    let description: String
    let website: String
    let avatarURL: URL?
    let nftsCount: Int
    let favoritesCount: Int
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
    @Published var showEditProfile: Bool = false
    
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
        
        Task {
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
    
    func navigateToMyNft() {
        // TODO: Implement navigation to My NFT screen
        print("Navigate to My NFT")
    }
    
    func navigateToFavorites() {
        // TODO: Implement navigation to Favorites screen
        print("Navigate to Favorites")
    }
    
    func navigateToEditProfile() {
        showEditProfile = true
    }
    
    func updateProfile(_ profile: Profile) {
        self.profile = profile
        self.state = .loaded(profile)
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
