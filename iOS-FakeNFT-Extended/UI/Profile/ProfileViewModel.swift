import Foundation
import Combine

// MARK: - Profile State

enum ProfileState {
    case initial
    case loading
    case loaded(Profile)
    case error(String)
}

// MARK: - Profile Model

struct Profile {
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
    
    // MARK: - Published Properties
    
    @Published private(set) var state: ProfileState = .initial
    @Published private(set) var profile: Profile?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    
    // private let profileService: ProfileService // TODO: Add when service is ready
    
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
    
    init() {
        loadMockData()
    }
    
    // MARK: - Public Methods
    
    func loadProfile() {
        state = .loading
        isLoading = true
        
        // TODO: Replace with real API call
        // Task {
        //     do {
        //         let profile = try await profileService.loadProfile()
        //         self.profile = profile
        //         self.state = .loaded(profile)
        //     } catch {
        //         self.state = .error(error.localizedDescription)
        //         self.errorMessage = error.localizedDescription
        //     }
        //     self.isLoading = false
        // }
        
        // Mock implementation
        loadMockData()
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
        // TODO: Implement navigation to Edit Profile screen
        print("Navigate to Edit Profile")
    }
    
    // MARK: - Private Methods
    
    private func loadMockData() {
        let mockProfile = Profile(
            id: "1",
            name: "Joaquin Phoenix",
            description: "Дизайнер из Казани, люблю цифровое искусство\nи бейглы. В моей коллекции уже 100+ NFT,\nи еще больше — на моём сайте. Открыт\nк коллаборациям.",
            website: "Joaquin Phoenix.com",
            avatarURL: URL(string: "https://code.s3.yandex.net/landings-v2-ios-developer/space.PNG"),
            nftsCount: 112,
            favoritesCount: 11
        )
        
        self.profile = mockProfile
        self.state = .loaded(mockProfile)
        self.isLoading = false
    }
}
