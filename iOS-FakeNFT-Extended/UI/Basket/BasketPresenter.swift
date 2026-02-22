import Foundation
import UIKit

protocol BasketPresenter {
    func viewDidLoad()
    func deleteItem(at index: Int)
    func sortTapped()
    func payTapped()
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
    private var state = BasketState.initial {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.stateDidChange()
            }
        }
    }
    
    init(service: BasketService, router: BasketRouter) {
        self.service = service
        self.router = router
        loadSavedSort()
        setupNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePaymentSuccess),
            name: NSNotification.Name("PaymentSuccess"),
            object: nil
        )
    }
    
    @objc private func handlePaymentSuccess() {
        // Очищаем корзину на сервере
        service.updateBasket(nftIds: []) { [weak self] result in
            DispatchQueue.main.async {
                self?.items.removeAll()
                self?.state = .empty
            }
        }
    }
    
    func viewDidLoad() {
        state = .loading
    }
    
    func deleteItem(at index: Int) {
        guard index < items.count else { return }
        let item = items[index]
        router.showDeleteConfirmation(item: item) { [weak self] in
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
    
    private func stateDidChange() {
        switch state {
        case .initial:
            break
        case .loading:
            view?.showLoading()
            loadBasket()
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
    
    private func loadBasket() {
        service.loadBasket { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let basket):
                if basket.nfts.isEmpty {
                    self.state = .empty
                } else {
                    self.service.loadNftDetails(ids: basket.nfts) { [weak self] detailsResult in
                        switch detailsResult {
                        case .success(let items):
                            self?.state = .data(items)
                        case .failure:
                            self?.state = .empty
                        }
                    }
                }
            case .failure:
                self.state = .empty
            }
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
        let ids = items.map { $0.id }
        service.updateBasket(nftIds: ids) { _ in }
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
