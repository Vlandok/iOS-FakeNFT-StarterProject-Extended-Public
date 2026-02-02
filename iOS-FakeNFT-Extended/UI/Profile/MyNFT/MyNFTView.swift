import SwiftUI

struct MyNFTView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: MyNFTViewModel
    
    init(nftIds: [String] = [], likedIds: [String] = []) {
        _viewModel = StateObject(wrappedValue: MyNFTViewModel(nftIds: nftIds, likedIds: likedIds))
    }
    
    var body: some View {
        content
            .background(Color(.ypWhite))
            .navigationTitle(viewModel.isEmpty ? "" : NSLocalizedString("MyNFT.title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    backButton
                }
                if !viewModel.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        sortButton
                    }
                }
            }
            .confirmationDialog(
                NSLocalizedString("MyNFT.sort", comment: ""),
                isPresented: $viewModel.showSortOptions,
                titleVisibility: .visible
            ) {
                Button(NSLocalizedString("MyNFT.sortByPrice", comment: "")) {
                    viewModel.sortByPrice()
                }
                Button(NSLocalizedString("MyNFT.sortByRating", comment: "")) {
                    viewModel.sortByRating()
                }
                Button(NSLocalizedString("MyNFT.sortByName", comment: "")) {
                    viewModel.sortByName()
                }
                Button(NSLocalizedString("Common.cancel", comment: ""), role: .cancel) {}
            }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .initial, .loading:
            loadingView
        case .loaded:
            nftList
        case .empty:
            emptyState
        case .error(let message):
            errorView(message: message)
        }
    }
    
    private var nftList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.nfts) { nft in
                    NFTListCell(nft: nft)
                }
            }
            .padding(.top, 20)
        }
    }
    
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .tint(Color(.ypBlack))
                .scaleEffect(1.5)
            Spacer()
        }
    }
    
    private var emptyState: some View {
        VStack {
            Spacer()
            Text(NSLocalizedString("MyNFT.empty", comment: ""))
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color(.ypBlack))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
            Spacer()
        }
    }
    
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
            Spacer()
        }
    }
    
    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color(.ypBlack))
        }
    }
    
    private var sortButton: some View {
        Button {
            viewModel.showSortOptions = true
        } label: {
            Image("SortIcon")
                .renderingMode(.template)
                .foregroundColor(Color(.ypBlack))
        }
    }
}

#Preview("With NFTs") {
    NavigationStack {
        MyNFTView()
    }
}

#Preview("Empty") {
    NavigationStack {
        MyNFTView(nftIds: [])
    }
}
