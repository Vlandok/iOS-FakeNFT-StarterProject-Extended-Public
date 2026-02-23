import SwiftUI

enum PaymentState {
    case initial, loading, failed(Error), data([Currency])
}

@MainActor
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
        Task {
            print("[PaymentViewModel] INFO: Loading currencies")
            do {
                let loadedCurrencies = try await service.loadCurrencies()
                print("[PaymentViewModel] INFO: Loaded \(loadedCurrencies.count) currencies")
                
                // Сортируем валюты в правильном порядке
                let order = ["Bitcoin", "Dogecoin", "Tether", "Apecoin", "Solana", "Ethereum", "Cardano", "Shiba Inu"]
                currencies = loadedCurrencies.sorted { currency1, currency2 in
                    let index1 = order.firstIndex(of: currency1.title) ?? Int.max
                    let index2 = order.firstIndex(of: currency2.title) ?? Int.max
                    return index1 < index2
                }
                print("[PaymentViewModel] INFO: Currencies sorted")
            } catch {
                print("[PaymentViewModel] ERROR: Failed to load currencies - \(error.localizedDescription)")
                currencies = []
            }
        }
    }
    
    func selectCurrency(_ currency: Currency) {
        print("[PaymentViewModel] INFO: Selected currency: \(currency.title)")
        selectedCurrency = currency
    }
    
    func pay() {
        guard selectedCurrency != nil else {
            print("[PaymentViewModel] WARNING: Payment attempted without selected currency")
            return
        }
        
        Task {
            print("[PaymentViewModel] INFO: Starting payment process")
            isProcessing = true
            
            // Имитация процесса оплаты
            print("[PaymentViewModel] INFO: Processing payment (2 seconds)")
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            // Очищаем корзину на сервере
            print("[PaymentViewModel] INFO: Clearing basket on server")
            do {
                try await service.updateBasket(nftIds: [])
                print("[PaymentViewModel] INFO: Basket cleared successfully")
            } catch {
                print("[PaymentViewModel] ERROR: Failed to clear basket - \(error.localizedDescription)")
            }
            
            // Даем серверу время на обработку
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            isProcessing = false
            showSuccess = true
            print("[PaymentViewModel] INFO: Payment completed successfully")
        }
    }
}
