import SwiftUI

struct CatalogCollectionCell: View {
    let collection: CatalogCollection
    
    var body: some View {
        VStack(alignment: .leading,spacing: 4) {
            AsyncImage(url: collection.imageUrl) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Color.gray
                    
                @unknown default:
                    Color.gray
                }
            }
            
            .frame(height: 179)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            HStack() {
                Text(collection.name)
                    .font(.system(size: 17, weight: .bold))
                    .lineLimit(1)
                Text("(\(collection.nftCount))")
                    .font(.system(size: 17, weight: .bold))
                
                Spacer()
            }
        }
        .padding(.horizontal, 16)
    }
}
#Preview {
    CatalogCollectionCell(
        collection: CatalogCollection(
            name: "test nft",
            nftCount: 12,
            imageUrl: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Обложки_коллекций/Gray.png")!
        )
    )
}

