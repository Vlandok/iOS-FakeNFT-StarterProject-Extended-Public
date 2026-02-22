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
    
    private lazy var agreementLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        
        let text = "Совершая покупку, вы соглашаетесь с условиями"
        let linkText = "Пользовательского соглашения"
        let fullText = "\(text) \(linkText)"
        
        let attributedString = NSMutableAttributedString(string: fullText)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 13), range: NSRange(location: 0, length: fullText.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: NSRange(location: text.count + 1, length: linkText.count))
        
        label.attributedText = attributedString
        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(agreementTapped))
        label.addGestureRecognizer(tapGesture)
        
        return label
    }()
    
    private lazy var bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        return view
    }()
    
    private lazy var payButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Оплатить", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(payTapped), for: .touchUpInside)
        button.isEnabled = false
        button.alpha = 0.5
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Скрываем таббар
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Показываем таббар обратно
        tabBarController?.tabBar.isHidden = false
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Выберите способ оплаты"
        
        // Добавляем кнопку назад
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "Light"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        view.addSubview(collectionView)
        view.addSubview(bottomContainerView)
        view.addSubview(activityIndicator)
        view.addSubview(progressHUD)
        
        bottomContainerView.addSubview(agreementLabel)
        bottomContainerView.addSubview(payButton)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
        agreementLabel.translatesAutoresizingMaskIntoConstraints = false
        payButton.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        progressHUD.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: -16),
            
            bottomContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            agreementLabel.topAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: 16),
            agreementLabel.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 16),
            agreementLabel.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -16),
            
            payButton.topAnchor.constraint(equalTo: agreementLabel.bottomAnchor, constant: 16),
            payButton.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 16),
            payButton.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -16),
            payButton.heightAnchor.constraint(equalToConstant: 60),
            payButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            progressHUD.topAnchor.constraint(equalTo: view.topAnchor),
            progressHUD.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressHUD.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressHUD.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
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
        payButton.alpha = 1.0
        
        var indexesToReload = [indexPath]
        if let previous = previousIndex {
            indexesToReload.append(previous)
        }
        collectionView.reloadItems(at: indexesToReload)
    }
}

extension PaymentViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = 168
        let height: CGFloat = 48
        return CGSize(width: width, height: height)
    }
}
