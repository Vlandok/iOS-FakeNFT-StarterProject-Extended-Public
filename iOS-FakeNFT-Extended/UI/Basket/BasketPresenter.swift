import SwiftUI

enum BasketState {
    case initial, loading, failed(Error), data([BasketItem]), empty
}

enum SortType: String {
    case byPrice = "Basket.sort.price"
    case byRating = "Basket.sort.rating"
    case byName = "Basket.sort.name"
}

@MainActor
class BasketViewModel: ObservableObject {
    @Published var items: [BasketItem] = [] {
        willSet {
            print("[BasketViewModel] DEBUG: items willSet - old count: \(items.count), new count: \(newValue.count)")
            if items.count == newValue.count {
                print("[BasketViewModel] DEBUG: Order changed - old first: \(items.first?.name ?? "none"), new first: \(newValue.first?.name ?? "none")")
            }
        }
    }
    @Published var isLoading = false
    @Published var showSortOptions = false
    @Published var itemToDelete: BasketItem?
    @Published var errorMessage: String?
    @Published var sortTrigger = 0 // Вспомогательная переменная для принудительного обновления
    
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
        Task {
            print("[BasketViewModel] INFO: Starting basket load")
            isLoading = true
            
            do {
                let basket = try await service.loadBasket()
                print("[BasketViewModel] INFO: Basket loaded successfully with \(basket.nfts.count) items")
                
                if basket.nfts.isEmpty {
                    print("[BasketViewModel] INFO: Basket is empty, showing empty state")
                    items = []
                } else {
                    print("[BasketViewModel] INFO: Loading NFT details for \(basket.nfts.count) items")
                    let loadedItems = try await service.loadNftDetails(ids: basket.nfts)
                    print("[BasketViewModel] INFO: Successfully loaded \(loadedItems.count) NFT details")
                    items = loadedItems
                    applySorting(currentSort)
                    print("[BasketViewModel] INFO: Applied sorting: \(currentSort.rawValue)")
                }
            } catch {
                print("[BasketViewModel] ERROR: Failed to load basket - \(error.localizedDescription)")
                items = []
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
            print("[BasketViewModel] INFO: Basket load completed")
        }
    }
    
    func confirmDelete(_ item: BasketItem) {
        print("[BasketViewModel] INFO: Deleting item: \(item.id)")
        items.removeAll { $0.id == item.id }
        updateBasketOnServer()
        itemToDelete = nil
    }
    
    func sortBy(_ sortType: SortType) {
        currentSort = sortType
        saveSortType(sortType)
        
        // Сохраняем текущие данные
        let currentItems = items
        
        // Очищаем список для триггера обновления UI
        items = []
        
        // Применяем сортировку
        Task {
            switch sortType {
            case .byPrice:
                items = currentItems.sorted(by: { $0.price > $1.price })
            case .byRating:
                items = currentItems.sorted(by: { $0.rating > $1.rating })
            case .byName:
                items = currentItems.sorted(by: { $0.name < $1.name })
            }
            
            print("[BasketViewModel] INFO: Sorted by \(sortType.rawValue)")
            for (i, item) in items.enumerated() {
                print("  [\(i)] \(item.name) - price: \(item.price), rating: \(item.rating)")
            }
        }
    }
    
    private func applySorting(_ sortType: SortType) {
        let sortedItems: [BasketItem]
        switch sortType {
        case .byPrice:
            sortedItems = items.sorted { $0.price < $1.price }
        case .byRating:
            sortedItems = items.sorted { $0.rating > $1.rating }
        case .byName:
            sortedItems = items.sorted { $0.name < $1.name }
        }
        items = sortedItems
    }
    
    private func updateBasketOnServer() {
        let ids = items.map { $0.id }
        print("[BasketViewModel] INFO: Updating basket on server with \(ids.count) items")
        Task {
            do {
                try await service.updateBasket(nftIds: ids)
                print("[BasketViewModel] INFO: Basket updated successfully on server")
            } catch {
                print("[BasketViewModel] ERROR: Failed to update basket on server - \(error.localizedDescription)")
            }
        }
    }
    
    private func saveSortType(_ sortType: SortType) {
        UserDefaults.standard.set(sortType.rawValue, forKey: "basket_sort_type")
    }
    
    private func loadSavedSort() {
        if let saved = UserDefaults.standard.string(forKey: "basket_sort_type"),
           let sortType = SortType(rawValue: saved) {
            currentSort = sortType
            print("[BasketViewModel] INFO: Loaded saved sort type: \(sortType.rawValue)")
        }
    }
}

extension BasketItem: Identifiable {}
