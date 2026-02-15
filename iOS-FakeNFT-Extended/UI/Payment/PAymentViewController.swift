import UIKit

protocol PaymentView: AnyObject, ErrorView, LoadingView {
    func displayCurrencies(_ currencies: [Currency])
    func showPaymentProgress()
    func hidePaymentProgress()
    func navigateToSuccess()
}

final class PaymentViewController: UIViewController {
    private let presenter: PaymentPresenter
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 7
        layout.minimumLineSpacing = 7
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(CurrencyCell.self, forCellWithReuseIdentifier: CurrencyCell.reuseIdentifier)
        cv.dataSource = self
        cv.delegate = self
        cv.backgroundColor = .white
        return cv
    }()
    
    private lazy var agreementButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Payment.agreement", comment: ""), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13)
        button.addTarget(self, action: #selector(agreementTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var payButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Payment.pay", comment: ""), for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(payTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    internal lazy var activityIndicator = UIActivityIndicatorView()
    private lazy var progressHUD: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.isHidden = true
        
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white
        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }()
    
    private var currencies: [Currency] = []
    private var selectedIndex: IndexPath?
    
    init(presenter: PaymentPresenter) {
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
        title = NSLocalizedString("Payment.title", comment: "")
        
        view.addSubview(collectionView)
        view.addSubview(agreementButton)
        view.addSubview(payButton)
        view.addSubview(activityIndicator)
        view.addSubview(progressHUD)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        agreementButton.translatesAutoresizingMaskIntoConstraints = false
        payButton.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        progressHUD.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: agreementButton.topAnchor, constant: -16),
            
            agreementButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            agreementButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            agreementButton.bottomAnchor.constraint(equalTo: payButton.topAnchor, constant: -16),
            
            payButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            payButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            payButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            payButton.heightAnchor.constraint(equalToConstant: 60),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            progressHUD.topAnchor.constraint(equalTo: view.topAnchor),
            progressHUD.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressHUD.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressHUD.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func agreementTapped() {
        presenter.agreementTapped()
    }
    
    @objc private func payTapped() {
        guard let selectedIndex = selectedIndex else { return }
        let currency = currencies[selectedIndex.row]
        presenter.payWithCurrency(currency)
    }
}

extension PaymentViewController: PaymentView {
    func displayCurrencies(_ currencies: [Currency]) {
        self.currencies = currencies
        collectionView.reloadData()
    }
    
    func showPaymentProgress() {
        progressHUD.isHidden = false
        view.isUserInteractionEnabled = false
    }
    
    func hidePaymentProgress() {
        progressHUD.isHidden = true
        view.isUserInteractionEnabled = true
    }
    
    func navigateToSuccess() {
        // Will be handled by router
    }
}

extension PaymentViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        currencies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CurrencyCell.reuseIdentifier,
            for: indexPath
        ) as? CurrencyCell else {
            return UICollectionViewCell()
        }
        
        let currency = currencies[indexPath.row]
        let isSelected = selectedIndex == indexPath
        cell.configure(with: currency, isSelected: isSelected)
        return cell
    }
}

extension PaymentViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let previousIndex = selectedIndex
        selectedIndex = indexPath
        payButton.isEnabled = true
        
        var indexesToReload = [indexPath]
        if let previous = previousIndex {
            indexesToReload.append(previous)
        }
        collectionView.reloadItems(at: indexesToReload)
    }
}

extension PaymentViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 7) / 2
        return CGSize(width: width, height: 76)
    }
}
