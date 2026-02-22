import SwiftUI

enum PaymentState {
    case initial, loading, failed(Error), data([Currency])
}

class PaymentViewModel: ObservableObject {
    @Published var currencies: [Currency] = []
    @Published var selectedCurrency: Currency?
    @Published var isProcessing = false
    @Published var showSuccess = false
    @Published var showAgreement = false
    
    private let items: [BasketItem]
    private let service: BasketService
    
    init(items: [BasketItem], service: BasketService) {
        self.items = items
        self.service = service
    }
    
    func loadCurrencies() {
        service.loadCurrencies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let currencies):
                    // Сортируем валюты в правильном порядке
                    let order = ["Bitcoin", "Dogecoin", "Tether", "Apecoin", "Solana", "Ethereum", "Cardano", "Shiba Inu"]
                    self.currencies = currencies.sorted { currency1, currency2 in
                        let index1 = order.firstIndex(of: currency1.title) ?? Int.max
                        let index2 = order.firstIndex(of: currency2.title) ?? Int.max
                        return index1 < index2
                    }
                case .failure:
                    self.currencies = []
                }
            }
        }
    }
    
    func selectCurrency(_ currency: Currency) {
        selectedCurrency = currency
    }
    
    func pay() {
        guard selectedCurrency != nil else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.isProcessing = true
        }
        
        // Имитация процесса оплаты с использованием GCD
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            
            // Очищаем корзину на сервере
            self.service.updateBasket(nftIds: []) { _ in
                // Даем серверу время на обработку
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.isProcessing = false
                    self.showSuccess = true
                }
            }
        }
    }
}
