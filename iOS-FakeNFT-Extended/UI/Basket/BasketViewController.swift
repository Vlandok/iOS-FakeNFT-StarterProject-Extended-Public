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
        
        let label = UILabel()
        label.text = NSLocalizedString("Basket.empty", comment: "")
        label.textAlignment = .center
        label.font = UIFont(name: "SFProText-Bold", size: 17) ?? .systemFont(ofSize: 17, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        view.isHidden = true
        return view
    }()
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0) // Светло-серый
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private lazy var nftCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SFProText-Regular", size: 15) ?? .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private lazy var totalLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SFProText-Bold", size: 17) ?? .systemFont(ofSize: 17, weight: .bold)
        label.textColor = UIColor(red: 0.42, green: 0.69, blue: 0.20, alpha: 1.0) // Зеленый
        return label
    }()
    
    private lazy var payButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Basket.pay", comment: ""), for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProText-Bold", size: 17) ?? .systemFont(ofSize: 17, weight: .bold)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(payTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var sortButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(named: "SortIcon"),
            style: .plain,
            target: self,
            action: #selector(sortTapped)
        )
        button.tintColor = .black
        return button
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
        // Убираем title
        navigationItem.rightBarButtonItem = sortButton
        
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(bottomView)
        view.addSubview(activityIndicator)
        
        bottomView.addSubview(nftCountLabel)
        bottomView.addSubview(totalLabel)
        bottomView.addSubview(payButton)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        nftCountLabel.translatesAutoresizingMaskIntoConstraints = false
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
            bottomView.heightAnchor.constraint(equalToConstant: 76),
            
            nftCountLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 16),
            nftCountLabel.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor, constant: -10),
            
            totalLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 16),
            totalLabel.topAnchor.constraint(equalTo: nftCountLabel.bottomAnchor, constant: 2),
            
            payButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -16),
            payButton.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            payButton.widthAnchor.constraint(equalToConstant: 240),
            payButton.heightAnchor.constraint(equalToConstant: 60),
            
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
        navigationItem.rightBarButtonItem = sortButton
        
        // Обновляем количество NFT
        nftCountLabel.text = "\(items.count) NFT"
        
        tableView.reloadData()
    }
    
    func displayEmptyState() {
        tableView.isHidden = true
        emptyStateView.isHidden = false
        bottomView.isHidden = true
        navigationItem.rightBarButtonItem = nil
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
