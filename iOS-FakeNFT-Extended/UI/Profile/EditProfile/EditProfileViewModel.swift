import Foundation

// MARK: - EditProfileViewModel

@MainActor
final class EditProfileViewModel: ObservableObject {
    
    // MARK: - Constants
    
    private enum Constants {
        /// ID профиля для API endpoint (всегда "1" согласно API)
        static let profileEndpointId = "1"
    }
    
    // MARK: - Published Properties
    
    @Published var name: String
    @Published var description: String
    @Published var website: String
    @Published var avatarURLString: String
    
    @Published var isLoading: Bool = false
    @Published var showPhotoActionSheet: Bool = false
    @Published var showPhotoURLAlert: Bool = false
    @Published var showExitConfirmation: Bool = false
    @Published var photoURLInput: String = ""
    
    @Published private(set) var isSaveSuccessful: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let profileService: ProfileService
    private let originalProfile: Profile
    private let onSave: ((Profile) -> Void)?
    
    // MARK: - Computed Properties
    
    var avatarURL: URL? {
        URL(string: avatarURLString)
    }
    
    var hasChanges: Bool {
        name != originalProfile.name ||
        description != originalProfile.description ||
        website != originalProfile.website ||
        avatarURLString != (originalProfile.avatarURL?.absoluteString ?? "")
    }
    
    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // MARK: - Init
    
    init(
        profile: Profile,
        profileService: ProfileService = ProfileServiceImpl(networkClient: DefaultNetworkClient()),
        onSave: ((Profile) -> Void)? = nil
    ) {
        self.originalProfile = profile
        self.profileService = profileService
        self.onSave = onSave
        
        self.name = profile.name
        self.description = profile.description
        self.website = profile.website
        self.avatarURLString = profile.avatarURL?.absoluteString ?? ""
    }
    
    // MARK: - Public Methods
    
    func saveProfile() {
        guard canSave else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let update = ProfileUpdateDTO(
                    name: name,
                    description: description,
                    website: website,
                    avatar: avatarURLString.isEmpty ? nil : avatarURLString
                )
                
                let updatedProfile = try await profileService.updateProfile(
                    id: Constants.profileEndpointId,
                    update: update
                )
                
                onSave?(updatedProfile)
                isSaveSuccessful = true
            } catch {
                errorMessage = Self.mapError(error)
            }
            isLoading = false
        }
    }
    
    func changePhotoTapped() {
        showPhotoActionSheet = true
    }
    
    func changePhotoURLSelected() {
        photoURLInput = avatarURLString
        showPhotoURLAlert = true
    }
    
    func deletePhotoSelected() {
        avatarURLString = ""
    }
    
    func savePhotoURL() {
        avatarURLString = photoURLInput
    }
    
    func backButtonTapped() -> Bool {
        if hasChanges {
            showExitConfirmation = true
            return false
        }
        return true
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
