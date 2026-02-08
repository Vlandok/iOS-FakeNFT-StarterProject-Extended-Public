import SwiftUI

struct FavoriteNFTCell: View {
    
    // MARK: - Constants
    
    private enum Constants {
        static let imageSize: CGFloat = 80
        static let cornerRadius: CGFloat = 12
        static let likeButtonSize: CGFloat = 30
        static let spacing: CGFloat = 12
    }
    
    // MARK: - Properties
    
    let nft: FavoriteNFTItem
    let onLikeTapped: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .center, spacing: Constants.spacing) {
            nftImage
            nftInfo
        }
    }
    
    // MARK: - NFT Image
    
    private var nftImage: some View {
        ZStack(alignment: .topTrailing) {
            AsyncImage(url: nft.imageURL) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .fill(Color(.ypLightGray))
                        .frame(width: Constants.imageSize, height: Constants.imageSize)
                        .overlay {
                            ProgressView()
                                .tint(Color(.ypBlack))
                        }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: Constants.imageSize, height: Constants.imageSize)
                        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                case .failure:
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .fill(Color(.ypLightGray))
                        .frame(width: Constants.imageSize, height: Constants.imageSize)
                @unknown default:
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .fill(Color(.ypLightGray))
                        .frame(width: Constants.imageSize, height: Constants.imageSize)
                }
            }
            
            likeButton
        }
    }
    
    // MARK: - Like Button
    
    private var likeButton: some View {
        Button(action: onLikeTapped) {
            Image("MyNFTFavouriteIcon")
                .renderingMode(.template)
                .foregroundColor(nft.isLiked ? Color(.ypRed) : Color(.ypWhite))
        }
        .frame(width: Constants.likeButtonSize, height: Constants.likeButtonSize)
    }
    
    // MARK: - NFT Info
    
    private var nftInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(nft.name)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color(.ypBlack))
                .lineLimit(1)
            
            ratingStars
            
            Text(formatPrice(nft.price))
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color(.ypBlack))
                .lineLimit(1)
        }
    }
    
    // MARK: - Rating Stars
    
    private var ratingStars: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundColor(index <= nft.rating ? Color(.ypYellow) : Color(.ypLightGray))
            }
        }
    }
    
    // MARK: - Helpers
    
    private func formatPrice(_ price: Double) -> String {
        String(format: "%.2f ETH", price).replacingOccurrences(of: ".", with: ",")
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 12) {
            FavoriteNFTCell(
                nft: FavoriteNFTItem(
                    id: "1",
                    name: "Archie",
                    imageURL: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/1.png"),
                    rating: 1,
                    price: 1.78,
                    isLiked: true
                ),
                onLikeTapped: {}
            )
            
            FavoriteNFTCell(
                nft: FavoriteNFTItem(
                    id: "2",
                    name: "Pixi",
                    imageURL: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/1.png"),
                    rating: 3,
                    price: 1.78,
                    isLiked: true
                ),
                onLikeTapped: {}
            )
        }
    }
    .padding()
}
