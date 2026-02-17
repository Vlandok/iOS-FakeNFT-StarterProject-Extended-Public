import SwiftUI

struct CatalogView: View {
    
    @StateObject private var viewModel = CatalogViewModel()
    @State private var isSortDialogPresented = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 21) {
                    ForEach(viewModel.collections) { collection in
                        CatalogCollectionCell(collection: collection)
                            .onTapGesture {
                                viewModel.selectCollection(collection)
                            }
                    }
                }
                .padding(.top, 16)
            }
            .navigationDestination(
                item: $viewModel.selectedCollection
            ) { collection in
                CollectionView(collection: collection)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isSortDialogPresented = true
                    } label: {
                        Image(.sortIcon)
                            .resizable()
                            .frame(width: 42, height: 42)
                    }
                    .confirmationDialog(
                        NSLocalizedString("Catalog.sortTitle", comment: ""),
                        isPresented: $isSortDialogPresented,
                        titleVisibility: .visible
                    ) {
                        Button("Catalog.sortByName") {
                            viewModel.sortCollection(by: .byName)
                        }
                        
                        Button("Catalog.sortByNftCount") {
                            viewModel.sortCollection(by: .byNftCount)
                        }
                        
                        Button("Catalog.cancelButton", role: .cancel) { }
                    }
                }
            }
            .toolbarBackground(.white, for: .navigationBar)
        }
    }
}

#Preview {
    TabBarView()
}
