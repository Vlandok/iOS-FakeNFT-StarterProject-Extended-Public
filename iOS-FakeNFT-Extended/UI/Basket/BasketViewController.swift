import SwiftUI

struct BasketSwiftUIView: View {
    @StateObject private var viewModel: BasketViewModel
    @State private var hasAppeared = false
    @Binding var isTabBarVisible: Bool
    
    init(service: BasketService, isTabBarVisible: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: BasketViewModel(service: service))
        _isTabBarVisible = isTabBarVisible
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.items.isEmpty && !viewModel.isLoading {
                    emptyStateView
                } else {
                    basketContentView
                        .id(viewModel.sortTrigger) // Пересоздаём при изменении sortTrigger
                }
                
                if viewModel.isLoading {
                    ProgressView()
                }
            }
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
                    print("[BasketView] INFO: User selected sort by price")
                    viewModel.sortBy(.byPrice)
                }
                Button(NSLocalizedString("Basket.sort.rating", comment: "")) {
                    print("[BasketView] INFO: User selected sort by rating")
                    viewModel.sortBy(.byRating)
                }
                Button(NSLocalizedString("Basket.sort.name", comment: "")) {
                    print("[BasketView] INFO: User selected sort by name")
                    viewModel.sortBy(.byName)
                }
                Button(NSLocalizedString("Basket.sort.cancel", comment: ""), role: .cancel) {
                    print("[BasketView] INFO: User cancelled sort")
                }
            }
            .fullScreenCover(item: $viewModel.itemToDelete) { item in
                DeleteConfirmationSwiftUIView(item: item) {
                    viewModel.confirmDelete(item)
                }
                .background(BackgroundClearView())
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshBasket"))) { _ in
                print("[BasketView] INFO: Received RefreshBasket notification")
                hasAppeared = false 
                viewModel.loadBasket()
            }
            .onAppear {
                // Загружаем только при первом появлении
                if !hasAppeared {
                    print("[BasketView] INFO: First appearance, loading basket")
                    hasAppeared = true
                    viewModel.loadBasket()
                }
                isTabBarVisible = true
            }
            .toolbar(isTabBarVisible ? .visible : .hidden, for: .tabBar)
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
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.items, id: \.id) { item in
                        BasketItemRow(item: item) {
                            viewModel.itemToDelete = item
                        }
                    }
                }
            }
            .id(viewModel.sortTrigger) // Пересоздаём список при изменении sortTrigger
            
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
                
                NavigationLink(destination: PaymentSwiftUIView(items: viewModel.items, service: viewModel.service, isTabBarVisible: $isTabBarVisible)) {
                    Text(NSLocalizedString("Basket.pay", comment: ""))
                        .font(.custom("SFProText-Bold", size: 17))
                        .foregroundColor(.white)
                        .frame(width: 240, height: 44)
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
                Image("Cart")
                    .renderingMode(.template)
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .frame(height: 140)
    }
}
