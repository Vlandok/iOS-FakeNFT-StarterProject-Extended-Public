import Foundation

@MainActor
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
            Task { await stateDidChange() }
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
        view?.showPaymentProgress()
        
        Task {
            do {
                // Имитация процесса оплаты
                try await Task.sleep(nanoseconds: 2_000_000_000)
                
                // Пытаемся очистить корзину на сервере, но игнорируем ошибку
                _ = try? await service.updateBasket(nftIds: [])
                
                view?.hidePaymentProgress()
                router.openSuccess()
            } catch {
                view?.hidePaymentProgress()
                router.showPaymentError { [weak self] in
                    self?.payWithCurrency(currency)
                }
            }
        }
    }
    
    private func stateDidChange() async {
        switch state {
        case .initial:
            break
        case .loading:
            view?.showLoading()
            await loadCurrencies()
        case .data(let currencies):
            view?.hideLoading()
            view?.displayCurrencies(currencies)
        case .failed(let error):
            view?.hideLoading()
            let errorModel = makeErrorModel(error)
            view?.showError(errorModel)
        }
    }
    
    private func loadCurrencies() async {
        do {
            let currencies = try await service.loadCurrencies()
            state = .data(currencies)
        } catch {
            // Временно: создаем тестовые валюты (картинки загрузятся из Assets по названию)
            let mockCurrencies = [
                Currency(
                    id: "1",
                    title: "BTC",
                    name: "Bitcoin",
                    image: URL(string: "https://placeholder.com/bitcoin")!
                ),
                Currency(
                    id: "2",
                    title: "ETH",
                    name: "Ethereum",
                    image: URL(string: "https://placeholder.com/ethereum")!
                ),
                Currency(
                    id: "3",
                    title: "USDT",
                    name: "Tether",
                    image: URL(string: "https://placeholder.com/tether")!
                ),
                Currency(
                    id: "4",
                    title: "DOGE",
                    name: "Dogecoin",
                    image: URL(string: "https://placeholder.com/dogecoin")!
                )
            ]
            state = .data(mockCurrencies)
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
