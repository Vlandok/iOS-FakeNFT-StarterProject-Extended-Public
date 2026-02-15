import UIKit

final class BasketAssembly {
    @MainActor
    func build(service: BasketService) -> UIViewController {
        let router = BasketRouterImpl()
        let presenter = BasketPresenterImpl(service: service, router: router)
        let viewController = BasketViewController(presenter: presenter)
        
        presenter.view = viewController
        router.viewController = viewController
        
        return UINavigationController(rootViewController: viewController)
    }
}
