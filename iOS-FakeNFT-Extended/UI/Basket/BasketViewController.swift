import UIKit

protocol BasketView: AnyObject, ErrorView, LoadingView {
    func displayItems(_ items: [BasketItem])
    func displayEmptyState()
    func updateTotalPrice(_ price: String)
}

final class BasketViewController: UIViewController {
    private let presenter: BasketPresenter
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(BasketItemCell.self, forCellReuseIdentifier: BasketItemCell.reuseIdentifier)
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        return table
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "cart.badge.minus")
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = NSLocalizedString("Basket.empty", comment: "")
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        view.isHidden = true
        return view
    }()
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()
    
    private lazy var totalLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    private lazy var payButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Basket.pay", comment: ""), for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(payTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var sortButton: UIBarButtonItem = {
        UIBarButtonItem(
            image: UIImage(systemName: "arrow.up.arrow.down"),
            style: .plain,
            target: self,
            action: #selector(sortTapped)
        )
    }()
    
    internal lazy var activityIndicator = UIActivityIndicatorView()
    private var items: [BasketItem] = []
    
    init(presenter: BasketPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = NSLocalizedString("Tab.basket", comment: "")
        navigationItem.rightBarButtonItem = sortButton
        
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(bottomView)
        view.addSubview(activityIndicator)
        
        bottomView.addSubview(payButton)
        bottomView.addSubview(totalLabel)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        payButton.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomView.topAnchor),
            
            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: bottomView.topAnchor),
            
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 100),
            
            totalLabel.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 12),
            totalLabel.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
            
            payButton.topAnchor.constraint(equalTo: totalLabel.bottomAnchor, constant: 8),
            payButton.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
            payButton.widthAnchor.constraint(equalToConstant: 240),
            payButton.heightAnchor.constraint(equalToConstant: 44),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func sortTapped() {
        presenter.sortTapped()
    }
    
    @objc private func payTapped() {
        presenter.payTapped()
    }
}

extension BasketViewController: BasketView {
    func displayItems(_ items: [BasketItem]) {
        self.items = items
        tableView.isHidden = false
        emptyStateView.isHidden = true
        bottomView.isHidden = false
        tableView.reloadData()
    }
    
    func displayEmptyState() {
        tableView.isHidden = true
        emptyStateView.isHidden = false
        bottomView.isHidden = true
    }
    
    func updateTotalPrice(_ price: String) {
        totalLabel.text = price
    }
}

extension BasketViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: BasketItemCell.reuseIdentifier,
            for: indexPath
        ) as? BasketItemCell else {
            return UITableViewCell()
        }
        
        let item = items[indexPath.row]
        cell.configure(with: item) { [weak self] in
            self?.presenter.deleteItem(at: indexPath.row)
        }
        return cell
    }
}

extension BasketViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        140
    }
}
