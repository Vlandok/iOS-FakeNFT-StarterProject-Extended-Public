import UIKit
import Kingfisher

final class BasketItemCell: UITableViewCell {
    static let reuseIdentifier = "BasketItemCell"
    
    private var deleteAction: (() -> Void)?
    
    private lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        return label
    }()
    
    private lazy var ratingStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2
        return stack
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        return label
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        contentView.addSubview(nftImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(ratingStackView)
        contentView.addSubview(priceLabel)
        contentView.addSubview(deleteButton)
        
        nftImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingStackView.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nftImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nftImageView.widthAnchor.constraint(equalToConstant: 108),
            nftImageView.heightAnchor.constraint(equalToConstant: 108),
            
            nameLabel.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: 20),
            nameLabel.topAnchor.constraint(equalTo: nftImageView.topAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -8),
            
            ratingStackView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            ratingStackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            
            priceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: nftImageView.bottomAnchor, constant: -8),
            
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 40),
            deleteButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configure(with item: BasketItem, deleteAction: @escaping () -> Void) {
        self.deleteAction = deleteAction
        
        nameLabel.text = item.name
        priceLabel.text = String(format: "%.2f ETH", item.price)
        
        // Загружаем первую картинку из массива URL с помощью Kingfisher
        if let firstImageURL = item.images.first {
            nftImageView.kf.setImage(
                with: firstImageURL,
                placeholder: UIImage(systemName: "photo"),
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            )
        } else {
            nftImageView.image = UIImage(systemName: "photo")
        }
        
        setupRating(item.rating)
    }
    
    private func setupRating(_ rating: Int) {
        ratingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for i in 0..<5 {
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: i < rating ? "star.fill" : "star")
            imageView.tintColor = .systemYellow
            imageView.widthAnchor.constraint(equalToConstant: 12).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 12).isActive = true
            ratingStackView.addArrangedSubview(imageView)
        }
    }
    
    @objc private func deleteTapped() {
        deleteAction?()
    }
}
