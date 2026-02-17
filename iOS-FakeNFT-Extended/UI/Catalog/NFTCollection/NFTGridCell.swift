import SwiftUI

struct NFTGridCell: View {
    
    let item: NFTItemViewData
    let onFavoriteTap: () -> Void
    let onAddToCartTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: item.imageUrl) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Color.gray
                    }
                }
                .frame(width: 108, height: 108)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Button(action: onFavoriteTap) {
                    Image(item.isFavorite ? "HeartActive" : "HeartNoActive")
                }
            }
            
            RatingView(rating: item.rating)
            
            Text(item.name)
                .font(.system(size: 17, weight: .bold))
                .lineLimit(1)
            
            Text("\(item.price) ETH")
                .font(.system(size: 10, weight: .medium))
            
            Spacer()
        }
        .overlay(alignment: .bottomTrailing) {
            Button(action: onAddToCartTap) {
                Image(item.isInCart ? "CartAdd" : "Cart")
                    .frame(width: 40, height: 40)
                    .padding(.bottom, 14)
            }
        }
    }
}
