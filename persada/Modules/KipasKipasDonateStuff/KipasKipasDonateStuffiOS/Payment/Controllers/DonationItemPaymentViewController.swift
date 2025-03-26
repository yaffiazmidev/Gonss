import UIKit
import KipasKipasShared

final class DonationItemPaymentViewController: CollectionListController {
    
    private let BUTTON_CONTAINER_HEIGHT: CGFloat = 100
    
    private let paymentButton = KKLoadingButton()
    
    private var buttonViewBottomConstraint: NSLayoutConstraint? {
        didSet {
            buttonViewBottomConstraint?.isActive = true
        }
    }
    
    private var paymentURL: URL?
    
    let viewAdapter: DonationItemPaymentViewAdapter
    
    init(viewAdapter: DonationItemPaymentViewAdapter) {
        self.viewAdapter = viewAdapter
        super.init()
        self.viewAdapter.controller = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(
            color: .clear,
            isTransparent: true,
            backIndicator: .iconChevronLeft
        )
    }
    
    override func viewDidLoad() {
        configureUI()
        
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    // MARK: Private
    private func makeLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout(
            sectionProvider: { [unowned self] index, _ in
                guard let type = self.sectionType(at: index) else { return nil }
                return NSCollectionLayoutSection.template(for: type)
            }
        )
    }
    
    private func sectionType(at index: Int) -> DonationItemPaymentSection? {
        guard let section = sectionController(at: index) else { return nil }
        return .init(rawValue: section.sectionType)
    }
    
    private func showPaymentButton(_ isShowing: Bool) {
        let height = BUTTON_CONTAINER_HEIGHT
        
        UIView.animate(withDuration: 0.3) {
            if isShowing {
                self.buttonViewBottomConstraint?.constant = 0
                self.collectionView.contentInset.bottom = height
                self.view.layoutIfNeeded()
            } else {
                self.buttonViewBottomConstraint?.constant = height
                self.collectionView.contentInset.bottom = 30
            }
        }
    }
    
    private func updateUIWhenLoading(_ isLoading: Bool) {
        if isLoading {
            collectionView.backgroundColor = .white
            collectionView.contentInsetAdjustmentBehavior = .automatic
        } else {
            collectionView.backgroundColor = .alabaster
            collectionView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    // MARK: API
    func display(
        sections: [CollectionSectionController],
        paymentURL: URL?,
        isWaitingForPayment: Bool
    ) {
        display(sections: sections)
        showPaymentButton(isWaitingForPayment && !sections.isEmpty)
        self.paymentURL = paymentURL
    }
    
    func displayLoading(
        sections: [CollectionSectionController],
        isLoading: Bool
    ) {
        display(sections: sections)
        updateUIWhenLoading(isLoading)
    }
}

// MARK: UI
private extension DonationItemPaymentViewController {
    func configureUI() {
        configureCollectionView()
        configurePaymentButton()
    }
    
    func configureCollectionView() {
        collectionView.backgroundColor = .alabaster
        collectionView.setCollectionViewLayout(makeLayout(), animated: true)
        collectionView.alwaysBounceVertical = false
        collectionView.contentInset.bottom = BUTTON_CONTAINER_HEIGHT
        
        collectionView.registerCell(UICollectionViewCell.self)
        collectionView.registerCell(DonationItemPaymentHeaderCell.self)
        collectionView.registerCell(DonationItemPaymentInitiatorCell.self)
        collectionView.registerCell(DonationItemPaymentProductCell.self)
        collectionView.registerCell(DonationItemPaymentSummaryCell.self)
        collectionView.registerCell(CollectionHeaderFooterCell.self)
    }
    
    func configurePaymentButton() {
        paymentButton.indicatorPosition = .right
        paymentButton.indicator = MaterialLoadingIndicatorSimple(radius: 10)
        paymentButton.setBackgroundColor(.watermelon, for: .normal)
        paymentButton.indicator.color = .white
        paymentButton.titleLabel?.font = .roboto(.bold, size: 14)
        paymentButton.setTitle("Bayar Sekarang", for: .normal)
        paymentButton.setTitleColor(.white, for: .normal)
        paymentButton.layer.cornerRadius = 8
        paymentButton.clipsToBounds = true
        paymentButton.addTarget(self, action: #selector(didTapCheckoutButton), for: .touchUpInside)
        
        let container = UIView()
        container.backgroundColor = .white
        
        container.addSubview(paymentButton)
        paymentButton.anchors.edges.pin(insets: 12)
        
        buttonViewBottomConstraint = wrapWithBottomSafeAreaPaddingView(container, height: 16)
        buttonViewBottomConstraint?.constant = BUTTON_CONTAINER_HEIGHT
        
        container.anchors.edges.pin(axis: .horizontal)
        container.anchors.height.equal(64)
    }
    
    @objc func didTapCheckoutButton() {
        if let paymentURL = paymentURL, 
            UIApplication.shared.canOpenURL(paymentURL) {
            UIApplication.shared.open(paymentURL)
        }
    }
}

extension DonationItemPaymentViewController: ResourceErrorView {
    func display(error viewModel: ResourceErrorViewModel) {
        display(sections: [])
        showPaymentButton(false)
    }
}
