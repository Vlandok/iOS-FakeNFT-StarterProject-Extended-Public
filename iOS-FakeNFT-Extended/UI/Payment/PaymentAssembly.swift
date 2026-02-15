import UIKit

final class PaymentAssembly {
    @MainActor
    func build(items: [BasketItem]) -> UIViewController {
        let networkClient = DefaultNetworkClient()
        let service = BasketServiceImpl(networkClient: networkClient)
        let router = PaymentRouterImpl()
        let presenter = PaymentPresenterImpl(service: service, router: router, items: items)
        let viewController = PaymentViewController(presenter: presenter)
        
        presenter.view = viewController
        router.viewController = viewController
        
        return viewController
    }
}
