import UIKit
import Kingfisher

final class DeleteConfirmationViewController: UIViewController {
    
    private let item: BasketItem
    private let onConfirm: () -> Void
    
    private lazy var blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blur)
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        return imageView
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Вы уверены, что хотите\nудалить объект из корзины?"
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Удалить", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(UIColor(red: 0.96, green: 0.42, blue: 0.42, alpha: 1.0), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Вернуться", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        return button
    }()
    
    init(item: BasketItem, onConfirm: @escaping () -> Void) {
        self.item = item
        self.onConfirm = onConfirm
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadImage()
    }
    
    private func setupUI() {
        view.addSubview(blurView)
        view.addSubview(contentView)
        
        contentView.addSubview(imageView)
        contentView.addSubview(messageLabel)
        contentView.addSubview(buttonsStackView)
        
        buttonsStackView.addArrangedSubview(deleteButton)
        buttonsStackView.addArrangedSubview(cancelButton)
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 56),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -56),
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 108),
            imageView.heightAnchor.constraint(equalToConstant: 108),
            
            messageLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            buttonsStackView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            buttonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            buttonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            buttonsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func loadImage() {
        if let firstImageURL = item.images.first {
            imageView.kf.setImage(
                with: firstImageURL,
                placeholder: UIImage(systemName: "photo")
            )
        } else {
            imageView.image = UIImage(systemName: "photo")
        }
    }
    
    @objc private func deleteTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onConfirm()
        }
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}
