import SwiftUI

struct CollectionView: View {
    
    let collection: CatalogCollection
    
    var body: some View {
        VStack(spacing: 16) {
            Text(collection.name)
                .font(.title)
            
            Text("NFT в коллекции: \(collection.nftCount)")
            .font(.subheadline)
        }
        .navigationTitle(collection.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}


