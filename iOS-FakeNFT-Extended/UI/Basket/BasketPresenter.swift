import Foundation
import UIKit

@MainActor
protocol BasketPresenter {
    func viewDidLoad()
    func deleteItem(at index: Int)
    func sortTapped()
    func payTapped()
    func markPaymentCompleted()
}

enum BasketState {
    case initial, loading, failed(Error), data([BasketItem]), empty
}

enum SortType: String {
    case byPrice = "Basket.sort.price"
    case byRating = "Basket.sort.rating"
    case byName = "Basket.sort.name"
}

final class BasketPresenterImpl: BasketPresenter {
    weak var view: BasketView?
    private let service: BasketService
    private let router: BasketRouter
    
    private var items: [BasketItem] = []
    private var currentSort: SortType = .byName
    private var hasCompletedPayment = false // Флаг успешной оплаты
    private var state = BasketState.initial {
        didSet {
            Task { await stateDidChange() }
        }
    }
    
    init(service: BasketService, router: BasketRouter) {
        self.service = service
        self.router = router
        loadSavedSort()
    }
    
    func viewDidLoad() {
        state = .loading
    }
    
    func deleteItem(at index: Int) {
        guard index < items.count else { return }
        let item = items[index]
        router.showDeleteConfirmation(itemName: item.name) { [weak self] in
            self?.confirmDelete(at: index)
        }
    }
    
    func sortTapped() {
        router.showSortOptions(current: currentSort) { [weak self] sortType in
            self?.applySorting(sortType)
        }
    }
    
    func payTapped() {
        router.openPayment(items: items)
    }
    
    func markPaymentCompleted() {
        hasCompletedPayment = true
    }
    
    private func stateDidChange() async {
        switch state {
        case .initial:
            break
        case .loading:
            view?.showLoading()
            await loadBasket()
        case .data(let items):
            view?.hideLoading()
            self.items = items
            applySorting(currentSort)
        case .empty:
            view?.hideLoading()
            view?.displayEmptyState()
        case .failed(let error):
            view?.hideLoading()
            let errorModel = makeErrorModel(error)
            view?.showError(errorModel)
        }
    }
    
    private func loadBasket() async {
        do {
            let basket = try await service.loadBasket()
            if basket.nfts.isEmpty {
                state = .empty
            } else {
                let items = try await service.loadNftDetails(ids: basket.nfts)
                state = .data(items)
            }
        } catch {
            // Если оплата прошла успешно, показываем пустую корзину
            if hasCompletedPayment {
                hasCompletedPayment = false // Сбрасываем флаг
                state = .empty
                return
            }
            
           
            let mockItems = [
                BasketItem(
                    id: "1",
                    name: "Archie",
                    rating: 5,
                    price: 1.57,
                    images: [URL(string: "https://placeholder.com/nft1")!]
                ),
                BasketItem(
                    id: "2",
                    name: "Astronaut",
                    rating: 4,
                    price: 2.19,
                    images: [URL(string: "https://placeholder.com/nft2")!]
                ),
                BasketItem(
                    id: "3",
                    name: "Beagle",
                    rating: 3,
                    price: 0.99,
                    images: [URL(string: "https://placeholder.com/nft3")!]
                )
            ]
            state = .data(mockItems)
        }
    }
    
    private func confirmDelete(at index: Int) {
        items.remove(at: index)
        
        if items.isEmpty {
            state = .empty
        } else {
            updateBasketOnServer()
            view?.displayItems(items)
            updateTotalPrice()
        }
    }
    
    private func updateBasketOnServer() {
        Task {
            let ids = items.map { $0.id }
            _ = try? await service.updateBasket(nftIds: ids)
        }
    }
    
    private func applySorting(_ sortType: SortType) {
        currentSort = sortType
        saveSortType(sortType)
        
        switch sortType {
        case .byPrice:
            items.sort { $0.price < $1.price }
        case .byRating:
            items.sort { $0.rating > $1.rating }
        case .byName:
            items.sort { $0.name < $1.name }
        }
        
        view?.displayItems(items)
        updateTotalPrice()
    }
    
    private func updateTotalPrice() {
        let total = items.reduce(0.0) { $0 + $1.price }
        let formatted = String(format: "%.2f ETH", total)
        view?.updateTotalPrice(formatted)
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
    
    private func makeErrorModel(_ error: Error) -> ErrorModel {
        let message: String
        switch error {
        case is NetworkClientError:
            message = NSLocalizedString("Error.network", comment: "")
        default:
            message = NSLocalizedString("Error.unknown", comment: "")
        }
        
        let actionText = NSLocalizedString("Error.repeat", comment: "")
        return ErrorModel(message: message, actionText: actionText) { [weak self] in
            self?.state = .loading
        }
    }
}
