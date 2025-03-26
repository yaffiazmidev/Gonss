import UIKit
import KipasKipasShared
import KipasKipasDonateStuff

public final class DonationItemCheckoutViewController: CollectionListController {
    
    private let BUTTON_CONTAINER_HEIGHT: CGFloat = 100
    
    private let checkoutButton = KKLoadingButton()
    
    private var buttonViewBottomConstraint: NSLayoutConstraint? {
        didSet {
            buttonViewBottomConstraint?.isActive = true
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(
            title: title ?? "",
            backIndicator: .iconChevronLeft
        )
    }
    
    var onTapCheckoutButton: EmptyClosure?
    var onSuccessCheckout: EmptyClosure?
    
    public override func viewDidLoad() {
        configureUI()
        
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    private func makeLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout(
            sectionProvider: { [unowned self] index, _ in
                guard let type = self.sectionType(at: index) else { return nil }
                return NSCollectionLayoutSection.template(for: type)
            }
        )
    }
    
    private func sectionType(at index: Int) -> DonationItemCheckoutSection? {
        guard let section = sectionController(at: index) else { return nil }
        return .init(rawValue: section.sectionType)
    }
    
    private func hideCheckoutButton() {
        let height = BUTTON_CONTAINER_HEIGHT
        
        UIView.animate(withDuration: 0.3) {
            self.buttonViewBottomConstraint?.constant = height
            self.collectionView.contentInset.bottom = 30
        }
    }
}

// MARK: UI
private extension DonationItemCheckoutViewController {
    func configureUI() {
        configureCollectionView()
        configureDonateButton()
    }
    
    func configureCollectionView() {
        collectionView.backgroundColor = .alabaster
        collectionView.setCollectionViewLayout(makeLayout(), animated: true)
        
        collectionView.registerCell(UICollectionViewCell.self)
        collectionView.registerCell(DonationItemCheckoutProductCell.self)
        collectionView.registerCell(DonationItemCheckoutAddressCell.self)
        collectionView.registerCell(DonationItemCheckoutSummaryCell.self)
    }
    
    func configureDonateButton() {
        checkoutButton.indicatorPosition = .right
        checkoutButton.indicator = MaterialLoadingIndicatorSimple(radius: 10)
        checkoutButton.setBackgroundColor(.watermelon, for: .normal)
        checkoutButton.indicator.color = .white
        checkoutButton.titleLabel?.font = .roboto(.bold, size: 14)
        checkoutButton.setTitle("Pilih Metode Pembayaran", for: .normal)
        checkoutButton.setTitleColor(.white, for: .normal)
        checkoutButton.layer.cornerRadius = 8
        checkoutButton.clipsToBounds = true
        checkoutButton.addTarget(self, action: #selector(didTapCheckoutButton), for: .touchUpInside)
        
        let container = UIView()
        container.backgroundColor = .white
        
        container.addSubview(checkoutButton)
        checkoutButton.anchors.edges.pin(insets: 12)
        
        buttonViewBottomConstraint = wrapWithBottomSafeAreaPaddingView(container, height: 16)
        
        container.anchors.edges.pin(axis: .horizontal)
        container.anchors.height.equal(64)
    }
    
    @objc func didTapCheckoutButton() {
        onTapCheckoutButton?()
    }
}

// MARK: ResourceView, ResourceLoadingView, ResourceErrorView
extension DonationItemCheckoutViewController: ResourceView, ResourceLoadingView, ResourceErrorView {
    public func display(view viewModel: DonationItemCheckout) {
        onSuccessCheckout?()
        
        if let paymentURL = viewModel.redirectUrl.asURL() {
           if UIApplication.shared.canOpenURL(paymentURL) {
                UIApplication.shared.open(paymentURL)
                hideCheckoutButton()
            }
        }
    }
    
    public func display(loading viewModel: ResourceLoadingViewModel) {
        viewModel.isLoading ? checkoutButton.showLoader([]) : checkoutButton.hideLoader()
    }
    
    public func display(error viewModel: ResourceErrorViewModel) {
        showToast(with: viewModel.error?.message ?? "Terjadi kesalahan", verticalSpace: 70)
    }
}
