import UIKit

protocol BasketRouter {
    func showDeleteConfirmation(itemName: String, onConfirm: @escaping () -> Void)
    func showSortOptions(current: SortType, onSelect: @escaping (SortType) -> Void)
    func openPayment(items: [BasketItem])
}

final class BasketRouterImpl: BasketRouter {
    weak var viewController: UIViewController?
    
    func showDeleteConfirmation(itemName: String, onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(
            title: NSLocalizedString("Basket.delete.title", comment: ""),
            message: String(format: NSLocalizedString("Basket.delete.message", comment: ""), itemName),
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Basket.delete.confirm", comment: ""),
            style: .destructive
        ) { _ in
            onConfirm()
        })
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Basket.delete.cancel", comment: ""),
            style: .cancel
        ))
        
        viewController?.present(alert, animated: true)
    }
    
    func showSortOptions(current: SortType, onSelect: @escaping (SortType) -> Void) {
        let alert = UIAlertController(
            title: NSLocalizedString("Basket.sort.title", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let sortTypes: [SortType] = [.byPrice, .byRating, .byName]
        
        for sortType in sortTypes {
            let action = UIAlertAction(
                title: NSLocalizedString(sortType.rawValue, comment: ""),
                style: .default
            ) { _ in
                onSelect(sortType)
            }
            
            if sortType == current {
                action.setValue(true, forKey: "checked")
            }
            
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Basket.sort.cancel", comment: ""),
            style: .cancel
        ))
        
        viewController?.present(alert, animated: true)
    }
    
    @MainActor func openPayment(items: [BasketItem]) {
        let assembly = PaymentAssembly()
        let vc = assembly.build(items: items)
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
