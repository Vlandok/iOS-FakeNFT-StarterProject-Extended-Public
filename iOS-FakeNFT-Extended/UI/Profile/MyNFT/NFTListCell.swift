import SwiftUI

struct NFTListCell: View {
    
    let nft: NFTItem
    
    var body: some View {
        HStack(spacing: 20) {
            nftImage
            
            VStack(alignment: .leading, spacing: 4) {
                Text(nft.name)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color(.ypBlack))
                
                ratingStars
                
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("от ")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(Color(.ypBlack))
                    Text(nft.author)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color(.ypBlack))
                }
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 2) {
                Text(NSLocalizedString("MyNFT.price", comment: ""))
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(.ypBlack))
                
                Text(String(format: "%.2f ETH", nft.price).replacingOccurrences(of: ".", with: ","))
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color(.ypBlack))
                    .lineLimit(1)
                    .fixedSize()
            }
        }
        .padding(.leading, 16)
        .padding(.trailing, 40)
        .padding(.vertical, 16)
    }
    
    private var nftImage: some View {
        ZStack(alignment: .topTrailing) {
            AsyncImage(url: nft.imageURL) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.ypLightGray))
                        .frame(width: 108, height: 108)
                        .overlay {
                            ProgressView()
                                .tint(Color(.ypBlack))
                        }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 108, height: 108)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                case .failure:
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.ypLightGray))
                        .frame(width: 108, height: 108)
                @unknown default:
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.ypLightGray))
                        .frame(width: 108, height: 108)
                }
            }
            
            Image("MyNFTFavouriteIcon")
                .renderingMode(.template)
                .foregroundColor(nft.isLiked ? Color(.ypRed) : Color(.ypWhite))
                .frame(width: 40, height: 40)
        }
    }
    
    private var ratingStars: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundColor(index <= nft.rating ? Color(.ypYellow) : Color(.ypLightGray))
            }
        }
    }
}
