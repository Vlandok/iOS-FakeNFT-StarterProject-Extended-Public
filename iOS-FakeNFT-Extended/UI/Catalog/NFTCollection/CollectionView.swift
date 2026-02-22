import SwiftUI

struct CollectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ServicesAssembly.self) private var servicesAssembly
    @StateObject private var viewModel: CollectionViewModel
    
    private let headerHeight: CGFloat = 320
    
    init(collection: CatalogCollectionDomain) {
        let tempNftService = CollectionNFTServiceImpl(networkClient: DefaultNetworkClient())
        let tempProfileService = ProfileServiceImpl(networkClient: DefaultNetworkClient())
        let tempNetworkClient = DefaultNetworkClient()
        
        _viewModel = StateObject(
            wrappedValue: CollectionViewModel(
                collection: collection,
                nftService: tempNftService,
                profileService: tempProfileService,
                networkClient: tempNetworkClient
            )
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerImage
                collectionInfo
                
                Group {
                    switch viewModel.state {
                    case .initial, .loading:
                        loadingView
                    case .loaded(let items):
                        nftGrid(items)
                    case .error(let message):
                        errorView(message: message)
                    }
                }
            }
        }
        .overlay(alignment: .topLeading) {
            backButton
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.updateServices(
                nftService: servicesAssembly.collectionNFTService,
                profileService: servicesAssembly.profileService,
                networkClient: servicesAssembly.networkClient
            )
        }
    }
    
    private var headerImage: some View {
        AsyncImage(url: viewModel.headerImageUrl) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            default:
                Color.gray
            }
        }
        .frame(height: headerHeight)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var collectionInfo: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(viewModel.collectionName)
                .font(.system(size: 22, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.horizontal, .top], 16)
            
            HStack(spacing: 4) {
                Text(NSLocalizedString("Collection.author", comment: ""))
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                
                Button {
                    
                } label: {
                    Text(viewModel.authorName)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.blue)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 13)
            
            Text(viewModel.description)
                .font(.system(size: 13))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
                .padding(.top, 5)
        }
    }
    
    private func nftGrid(_ items: [NFTItemViewData]) -> some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3),
            spacing: 16
        ) {
            ForEach(items) { item in
                NFTGridCell(
                    item: item,
                    onFavoriteTap: {
                        viewModel.toggleFavorite(for: item)
                    },
                    onAddToCartTap: {
                        viewModel.toggleCart(for: item)
                    }
                )
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var loadingView: some View {
        ProgressView()
            .scaleEffect(1.5)
            .padding(.top, 50)
            .tint(.ypBlack)
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text(message)
                .font(.system(size: 17))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: viewModel.loadData) {
                Text("Повторить")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.black)
                    .cornerRadius(16)
            }
        }
        .padding(.top, 50)
    }
    
    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.black)
                .padding(16)
        }
        .padding(.top, 50)
        .padding(.leading, 16)
    }
}
