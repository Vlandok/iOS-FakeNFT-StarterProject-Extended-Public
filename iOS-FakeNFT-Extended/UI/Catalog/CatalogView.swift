import SwiftUI

struct CatalogView: View {
    
    @StateObject private var viewModel: CatalogViewModel
    @State private var isSortDialogPresented = false
    
    @Environment(ServicesAssembly.self) private var servicesAssembly
    
    init() {
        let tempService = CollectionsServiceImpl(networkClient: DefaultNetworkClient())
        _viewModel = StateObject(wrappedValue: CatalogViewModel(collectionsService: tempService))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .initial, .loading:
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.ypBlack)
                case .loaded(let collections):
                    content(collections)
                case .error(let message):
                    errorView(message: message)
                }
            }
            .navigationDestination(
                item: $viewModel.selectedCollection
            ) { collection in
                CollectionView(collection: collection)
                    .toolbar(.hidden, for: .tabBar)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    sortButton
                }
            }
            .toolbarBackground(.white, for: .navigationBar)
        }
        .task {
            await viewModel.updateService(servicesAssembly.collectionsService)
        }
    }
    
    private func content(_ collections: [CatalogCollectionDomain]) -> some View {
        ScrollView {
            LazyVStack(spacing: 21) {
                ForEach(collections) { collection in
                    CatalogCollectionCell(collection: collection)
                        .onTapGesture {
                            viewModel.selectCollection(collection)
                        }
                }
            }
            .padding(.top, 16)
        }
    }
    
    private var sortButton: some View {
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
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.ypRed)
            
            Text(message)
                .font(.system(size: 17))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: viewModel.retry) {
                Text("Повторить")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.black)
                    .cornerRadius(16)
            }
            
            Spacer()
        }
    }
}
