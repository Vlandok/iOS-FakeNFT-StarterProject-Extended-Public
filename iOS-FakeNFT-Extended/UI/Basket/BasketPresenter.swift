import SwiftUI

enum BasketState {
    case initial, loading, failed(Error), data([BasketItem]), empty
}

enum SortType: String {
    case byPrice = "Basket.sort.price"
    case byRating = "Basket.sort.rating"
    case byName = "Basket.sort.name"
}

class BasketViewModel: ObservableObject {
    @Published var items: [BasketItem] = []
    @Published var isLoading = false
    @Published var showSortOptions = false
    @Published var itemToDelete: BasketItem?
    @Published var errorMessage: String?
    
    let service: BasketService
    private var currentSort: SortType = .byName
    
    var totalPrice: String {
        let total = items.reduce(0.0) { $0 + $1.price }
        return String(format: "%.2f ETH", total)
    }
    
    init(service: BasketService) {
        self.service = service
        loadSavedSort()
    }
    
    func loadBasket() {
        print("📦 [BasketViewModel] ========== START loadBasket ==========")
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = true
            print("📦 [BasketViewModel] Set isLoading = true")
        }
        
        service.loadBasket { [weak self] result in
            guard let self = self else { 
                print("📦 [BasketViewModel] ❌ self is nil in loadBasket callback")
                return 
            }
            
            switch result {
            case .success(let basket):
                print("📦 [BasketViewModel] ✅ Basket loaded successfully")
                print("📦 [BasketViewModel] Basket.nfts count: \(basket.nfts.count)")
                print("📦 [BasketViewModel] Basket.nfts IDs: \(basket.nfts)")
                
                if basket.nfts.isEmpty {
                    DispatchQueue.main.async {
                        self.items = []
                        self.isLoading = false
                        print("📦 [BasketViewModel] Basket is EMPTY - showing empty state")
                    }
                } else {
                    print("📦 [BasketViewModel] Loading NFT details for \(basket.nfts.count) items...")
                    self.service.loadNftDetails(ids: basket.nfts) { [weak self] detailsResult in
                        DispatchQueue.main.async {
                            guard let self = self else { 
                                print("📦 [BasketViewModel] ❌ self is nil in loadNftDetails callback")
                                return 
                            }
                            self.isLoading = false
                            
                            switch detailsResult {
                            case .success(let items):
                                print("📦 [BasketViewModel] ✅ Loaded \(items.count) NFT details")
                                items.forEach { item in
                                    print("📦 [BasketViewModel]   - \(item.name) (\(item.id))")
                                }
                                self.items = items
                                self.applySorting(self.currentSort)
                                print("📦 [BasketViewModel] Applied sorting: \(self.currentSort)")
                            case .failure(let error):
                                print("📦 [BasketViewModel] ❌ Failed to load NFT details: \(error)")
                                self.items = []
                            }
                        }
                    }
                }
            case .failure(let error):
                print("📦 [BasketViewModel] ❌ Failed to load basket: \(error)")
                DispatchQueue.main.async {
                    self.items = []
                    self.isLoading = false
                }
            }
        }
        print("📦 [BasketViewModel] ========== END loadBasket (async) ==========")
    }
    
    func confirmDelete(_ item: BasketItem) {
        items.removeAll { $0.id == item.id }
        updateBasketOnServer()
        itemToDelete = nil
    }
    
    func sortBy(_ sortType: SortType) {
        currentSort = sortType
        saveSortType(sortType)
        applySorting(sortType)
    }
    
    private func applySorting(_ sortType: SortType) {
        switch sortType {
        case .byPrice:
            items.sort { $0.price < $1.price }
        case .byRating:
            items.sort { $0.rating > $1.rating }
        case .byName:
            items.sort { $0.name < $1.name }
        }
    }
    
    private func updateBasketOnServer() {
        let ids = items.map { $0.id }
        service.updateBasket(nftIds: ids) { _ in }
    }
    
    private func saveSortType(_ sortType: SortType) {
        UserDefaults.standard.set(sortType.rawValue, forKey: "basket_sort_type")
    }
    
    private func loadSavedSort() {
        if let saved = UserDefaults.standard.string(forKey: "basket_sort_type"),
           let sortType = SortType(rawValue: saved) {
            currentSort = sortType
        }
    }
}

extension BasketItem: Identifiable {}
