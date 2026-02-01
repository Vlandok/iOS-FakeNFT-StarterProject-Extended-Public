import SwiftUI

struct ProfileView: View {
    
    // MARK: - ViewModel
    
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showWebView = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            content
                .background(Color(.ypWhite))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        editButton
                    }
                }
                .fullScreenCover(isPresented: $showWebView) {
                    if let url = viewModel.websiteURL {
                        WebViewScreen(url: url)
                    }
                }
        }
    }
    
    // MARK: - Content
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .initial, .loading:
            loadingView
        case .loaded:
            profileContent
        case .error(let message):
            errorView(message: message)
        }
    }
    
    // MARK: - Profile Content
    
    private var profileContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                profileHeader
                    .padding(.top, 20)
                
                if viewModel.hasWebsite {
                    websiteLink
                        .padding(.top, 12)
                }
                
                menuItems
                    .padding(.top, 40)
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 16) {
                avatarView
                
                Text(viewModel.userName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(.ypBlack))
                    .lineLimit(2)
                
                Spacer()
            }
            
            Text(viewModel.userDescription)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color(.ypBlack))
                .lineSpacing(2)
        }
    }
    
    // MARK: - Avatar
    
    private var avatarView: some View {
        AsyncImage(url: viewModel.userAvatarURL) { phase in
            switch phase {
            case .empty:
                loadingAvatar
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
            case .failure:
                defaultAvatar
            @unknown default:
                defaultAvatar
            }
        }
    }
    
    private var loadingAvatar: some View {
        Circle()
            .fill(Color(.ypBlack))
            .frame(width: 70, height: 70)
            .overlay(
                ProgressView()
                    .tint(Color(.ypWhite))
            )
    }
    
    private var defaultAvatar: some View {
        Image("ProfileUserDefaultAvatar")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 70, height: 70)
            .clipShape(Circle())
    }
    
    // MARK: - Website Link
    
    private var websiteLink: some View {
        Button(action: { showWebView = true }) {
            Text(viewModel.userWebsite)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color(.ypBlue))
        }
    }
    
    // MARK: - Menu Items
    
    private var menuItems: some View {
        VStack(spacing: 0) {
            ProfileMenuItem(
                title: NSLocalizedString("Profile.myNft", comment: ""),
                count: viewModel.myNftCount,
                action: viewModel.navigateToMyNft
            )
            
            ProfileMenuItem(
                title: NSLocalizedString("Profile.favoriteNft", comment: ""),
                count: viewModel.favoriteNftCount,
                action: viewModel.navigateToFavorites
            )
        }
    }
    
    // MARK: - Edit Button
    
    private var editButton: some View {
        Button(action: viewModel.navigateToEditProfile) {
            Image("EditProfile")
                .renderingMode(.template)
                .foregroundColor(Color(.ypBlack))
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Spacer()
        }
    }
    
    // MARK: - Error View
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(Color(.ypRed))
            
            Text(message)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Color(.ypBlack))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: viewModel.loadProfile) {
                Text(NSLocalizedString("Error.repeat", comment: ""))
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color(.ypWhite))
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color(.ypBlack))
                    .cornerRadius(16)
            }
            
            Spacer()
        }
    }
}

// MARK: - Profile Menu Item

struct ProfileMenuItem: View {
    let title: String
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text("\(title)  (\(count))")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color(.ypBlack))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(.ypBlack))
            }
            .padding(.vertical, 16)
        }
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
}
