import Foundation

protocol PaymentPresenter {
    func viewDidLoad()
    func agreementTapped()
    func payWithCurrency(_ currency: Currency)
}

enum PaymentState {
    case initial, loading, failed(Error), data([Currency])
}

final class PaymentPresenterImpl: PaymentPresenter {
    weak var view: PaymentView?
    private let service: BasketService
    private let router: PaymentRouter
    private let items: [BasketItem]
    
    private var state = PaymentState.initial {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.stateDidChange()
            }
        }
    }
    
    init(service: BasketService, router: PaymentRouter, items: [BasketItem]) {
        self.service = service
        self.router = router
        self.items = items
    }
    
    func viewDidLoad() {
        state = .loading
    }
    
    func agreementTapped() {
        router.openAgreement()
    }
    
    func payWithCurrency(_ currency: Currency) {
        DispatchQueue.main.async { [weak self] in
            self?.view?.showPaymentProgress()
        }
        
        // Имитация процесса оплаты
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            
            // Пытаемся очистить корзину на сервере
            self.service.updateBasket(nftIds: []) { _ in }
            
            DispatchQueue.main.async {
                self.view?.hidePaymentProgress()
                self.router.openSuccess()
            }
        }
    }
    
    private func stateDidChange() {
        switch state {
        case .initial:
            break
        case .loading:
            view?.showLoading()
            loadCurrencies()
        case .data(let currencies):
            view?.hideLoading()
            view?.displayCurrencies(currencies)
        case .failed(let error):
            view?.hideLoading()
            let errorModel = makeErrorModel(error)
            view?.showError(errorModel)
        }
    }
    
    private func loadCurrencies() {
        service.loadCurrencies { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let currencies):
                self.state = .data(currencies)
            case .success(let currencies):
                // Сортируем валюты в правильном порядке
                let order = ["Bitcoin", "Dogecoin", "Tether", "Apecoin", "Solana", "Ethereum", "Cardano", "Shiba Inu"]
                let sortedCurrencies = currencies.sorted { currency1, currency2 in
                    let index1 = order.firstIndex(of: currency1.title) ?? Int.max
                    let index2 = order.firstIndex(of: currency2.title) ?? Int.max
                    return index1 < index2
                }
                self.state = .data(sortedCurrencies)
            case .failure:
                self.state = .data([])
            }
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
