import SwiftUI

struct FavoritesNFTView: View {
    
    // MARK: - Environment
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - ViewModel
    
    @StateObject private var viewModel: FavoritesNFTViewModel
    
    // MARK: - Grid Layout
    
    private let columns = [
        GridItem(.flexible(), spacing: 7),
        GridItem(.flexible(), spacing: 7)
    ]
    
    // MARK: - Init
    
    init(likedIds: [String]) {
        _viewModel = StateObject(wrappedValue: FavoritesNFTViewModel(likedIds: likedIds))
    }
    
    // MARK: - Body
    
    var body: some View {
        content
            .background(Color(.ypWhite))
            .navigationTitle(viewModel.isEmpty ? "" : NSLocalizedString("Profile.favoriteNft", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    backButton
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
            nftGrid
        case .empty:
            emptyState
        case .error(let message):
            errorView(message: message)
        }
    }
    
    // MARK: - NFT Grid
    
    private var nftGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(viewModel.nfts) { nft in
                    FavoriteNFTCell(nft: nft) {
                        viewModel.removeFromFavorites(nftId: nft.id)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .tint(Color(.ypBlack))
                .scaleEffect(1.5)
            Spacer()
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack {
            Spacer()
            Text(NSLocalizedString("FavoritesNFT.empty", comment: ""))
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color(.ypBlack))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
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
                .font(.system(size: 17))
                .foregroundColor(Color(.ypBlack))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: viewModel.loadFavorites) {
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
    
    // MARK: - Back Button
    
    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color(.ypBlack))
        }
    }
}

// MARK: - Preview

#Preview("With Favorites") {
    NavigationStack {
        FavoritesNFTView(likedIds: ["594aaf01-5962-4ab7-a6b5-470ea37beb93"])
    }
}

#Preview("Empty") {
    NavigationStack {
        FavoritesNFTView(likedIds: [])
    }
}
