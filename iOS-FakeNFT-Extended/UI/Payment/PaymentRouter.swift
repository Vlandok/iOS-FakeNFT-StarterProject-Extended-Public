import UIKit
import WebKit

protocol PaymentRouter {
    func openAgreement()
    func openSuccess()
    func showPaymentError(onRetry: @escaping () -> Void)
}

final class PaymentRouterImpl: PaymentRouter {
    weak var viewController: UIViewController?
    
    func openAgreement() {
        let webVC = WebViewController(url: URL(string: "https://yandex.ru/legal/practicum_termsofuse/")!)
        viewController?.present(webVC, animated: true)
    }
    
    func openSuccess() {
        let assembly = PaymentSuccessAssembly()
        let vc = assembly.build()
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showPaymentError(onRetry: @escaping () -> Void) {
        let alert = UIAlertController(
            title: NSLocalizedString("Payment.error.title", comment: ""),
            message: NSLocalizedString("Payment.error.message", comment: ""),
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Payment.error.retry", comment: ""),
            style: .default
        ) { _ in
            onRetry()
        })
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Payment.error.cancel", comment: ""),
            style: .cancel
        ))
        
        viewController?.present(alert, animated: true)
    }
}

final class WebViewController: UIViewController {
    private let url: URL
    private lazy var webView = WKWebView()
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        webView.load(URLRequest(url: url))
    }
}
