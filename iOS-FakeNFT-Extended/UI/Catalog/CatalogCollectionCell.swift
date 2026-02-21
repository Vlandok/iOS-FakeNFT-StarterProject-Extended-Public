import SwiftUI

struct CatalogCollectionCell: View {
    let collection: CatalogCollectionDomain
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            AsyncImage(url: collection.coverUrl) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .tint(.ypBlack)
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
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            HStack {
                Text(collection.name)
                    .font(.system(size: 17, weight: .bold))
                    .lineLimit(1)
                Text("(\(collection.nftCount))")
                    .font(.system(size: 17, weight: .bold))
                
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
    }
}
