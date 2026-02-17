import SwiftUI

struct CollectionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CollectionViewModel
    
    private let headerHeight: CGFloat = 320
    
    init(collection: CatalogCollection) {
        _viewModel = StateObject(
            wrappedValue: CollectionViewModel(
                collectionName: collection.name,
                authorName: "John Doe",
                description: "Персиковый — как облака над закатным солнцем в океане. В этой коллекции совмещены трогательная нежность и живая игривость сказочных зефирных зверей.",
                headerImageUrl: collection.imageUrl
            )
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
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
                
                Text(viewModel.collectionName)
                    .font(.system(size: 22, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.horizontal, .top], 16)
                
                HStack(spacing: 4) {
                    Text("Автор коллекции:")
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                    
                    Button {
                        // TODO: Переход на профиль автора
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
                
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3),
                    spacing: 16
                ) {
                    ForEach(viewModel.items) { item in
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
        }
        .overlay(alignment: .topLeading) {
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
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}


