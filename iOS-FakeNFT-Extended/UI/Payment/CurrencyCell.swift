import UIKit
import Kingfisher

final class CurrencyCell: UICollectionViewCell {
    static let reuseIdentifier = "CurrencyCell"
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 6
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(red: 0.42, green: 0.69, blue: 0.20, alpha: 1.0)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(nameLabel)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: iconImageView.topAnchor, constant: 2),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            nameLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }
    
    func configure(with currency: Currency, isSelected: Bool) {
        titleLabel.text = currency.title
        nameLabel.text = currency.name
        
        // Сначала пробуем загрузить из Assets по названию валюты
        if let localImage = UIImage(named: currency.title) {
            iconImageView.image = localImage
        } else if let localImage = UIImage(named: currency.name) {
            iconImageView.image = localImage
        } else {
            // Если нет локальной, загружаем по URL через Kingfisher
            iconImageView.kf.setImage(with: currency.image)
        }
        
        if isSelected {
            containerView.layer.borderColor = UIColor.black.cgColor
            containerView.layer.borderWidth = 1
            containerView.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        } else {
            containerView.layer.borderColor = UIColor.clear.cgColor
            containerView.layer.borderWidth = 0
            containerView.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        }
    }
}
