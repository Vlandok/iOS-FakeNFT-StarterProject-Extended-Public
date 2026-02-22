import UIKit

final class PaymentSuccessViewController: UIViewController {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "56_digital_art_x4")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Успех! Оплата прошла,поздравляем с покупкой!"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Success.back", comment: ""), for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(imageView)
        view.addSubview(messageLabel)
        view.addSubview(backButton)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 68),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 278),
            imageView.heightAnchor.constraint(equalToConstant: 278),
            
            messageLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36),
            
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            backButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func backTapped() {
        // Отправляем уведомление об успешной оплате для очистки корзины
        NotificationCenter.default.post(name: NSNotification.Name("PaymentSuccess"), object: nil)
        navigationController?.popToRootViewController(animated: true)
    }
}
