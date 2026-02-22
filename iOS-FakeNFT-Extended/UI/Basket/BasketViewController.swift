import SwiftUI

struct BasketSwiftUIView: View {
    @StateObject private var viewModel: BasketViewModel
    @State private var refreshID = UUID()
    
    init(service: BasketService) {
        _viewModel = StateObject(wrappedValue: BasketViewModel(service: service))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.items.isEmpty && !viewModel.isLoading {
                    emptyStateView
                } else {
                    basketContentView
                }
                
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .id(refreshID)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !viewModel.items.isEmpty {
                        Button(action: { viewModel.showSortOptions = true }) {
                            Image("SortIcon")
                                .renderingMode(.template)
                                .foregroundColor(.black)
                        }
                    }
                }
            }
            .confirmationDialog("Сортировка", isPresented: $viewModel.showSortOptions) {
                Button(NSLocalizedString("Basket.sort.price", comment: "")) {
                    viewModel.sortBy(.byPrice)
                }
                Button(NSLocalizedString("Basket.sort.rating", comment: "")) {
                    viewModel.sortBy(.byRating)
                }
                Button(NSLocalizedString("Basket.sort.name", comment: "")) {
                    viewModel.sortBy(.byName)
                }
                Button(NSLocalizedString("Basket.sort.cancel", comment: ""), role: .cancel) {}
            }
            .fullScreenCover(item: $viewModel.itemToDelete) { item in
                DeleteConfirmationSwiftUIView(item: item) {
                    viewModel.confirmDelete(item)
                }
                .background(BackgroundClearView())
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshBasket"))) { _ in
                print("🎬 [BasketView] RefreshBasket notification received")
                refreshID = UUID()
                print("🎬 [BasketView] New refreshID: \(refreshID)")
                viewModel.loadBasket()
            }
            .toolbar(.visible, for: .tabBar)
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            Text(NSLocalizedString("Basket.empty", comment: ""))
                .font(.custom("SFProText-Bold", size: 17))
            Spacer()
        }
    }
    
    private var basketContentView: some View {
        VStack(spacing: 0) {
            List {
                ForEach(viewModel.items) { item in
                    BasketItemRow(item: item) {
                        viewModel.itemToDelete = item
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                }
            }
            .listStyle(.plain)
            
            bottomPanel
        }
    }
    
    private var bottomPanel: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(viewModel.items.count) NFT")
                        .font(.custom("SFProText-Regular", size: 15))
                        .foregroundColor(.black)
                    
                    Text(viewModel.totalPrice)
                        .font(.custom("SFProText-Bold", size: 17))
                        .foregroundColor(Color(red: 0.42, green: 0.69, blue: 0.20))
                }
                
                Spacer()
                
                NavigationLink(destination: PaymentSwiftUIView(items: viewModel.items, service: viewModel.service)) {
                    Text(NSLocalizedString("Basket.pay", comment: ""))
                        .font(.custom("SFProText-Bold", size: 17))
                        .foregroundColor(.white)
                        .frame(width: 240, height: 60)
                        .background(Color.black)
                        .cornerRadius(16)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(height: 76)
            .background(Color(red: 0.98, green: 0.98, blue: 0.98))
        }
    }
}

struct BasketItemRow: View {
    let item: BasketItem
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            AsyncImage(url: item.images.first) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "photo")
                    .foregroundColor(.gray)
            }
            .frame(width: 108, height: 108)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.custom("SFProText-Bold", size: 17))
                    .foregroundColor(.black)
                
                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < item.rating ? "star.fill" : "star")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                    }
                }
                
                Spacer()
                
                Text("Цена")
                    .font(.custom("SFProText-Regular", size: 13))
                    .foregroundColor(.black)
                
                Text(String(format: "%.2f ETH", item.price))
                    .font(.custom("SFProText-Bold", size: 17))
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .frame(height: 140)
    }
}
