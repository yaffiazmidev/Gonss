import UIKit
import KipasKipasShared

public final class DonationItemDetailViewController: CollectionListController {
    
    private let BUTTON_CONTAINER_HEIGHT: CGFloat = 100
    
    private let buttonView = DonationItemDetailButtonView()
    
    private var buttonViewBottomConstraint: NSLayoutConstraint? {
        didSet {
            buttonViewBottomConstraint?.isActive = true
        }
    }
    
    private var quantity: Int = 1
    private var onTapDonate: EmptyClosure?
    
    private let role: DonationItemRole
    
    let detailAdapter: DonationItemDetailViewAdapter
    
    init(
        role: DonationItemRole,
        detailAdapter: DonationItemDetailViewAdapter
    ) {
        self.role = role
        self.detailAdapter = detailAdapter
        super.init()
        self.detailAdapter.delegate = self
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(
            color: .clear,
            isTransparent: true
        )
    }

    public override func viewDidLoad() {
        configureUI()
        
        super.viewDidLoad()
        view.backgroundColor = .white
        
        titleView.numberOfLines = 1
        navigationItem.titleView = titleView
    }
    
    // MARK: Privates
    private func makeLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout(
            sectionProvider: { [unowned self] index, _ in
                guard let type = self.sectionType(at: index) else { return nil }
                return NSCollectionLayoutSection.template(for: type)
            }
        )
    }
    
    private func sectionType(at index: Int) -> DonationItemDetailSection? {
        guard let section = sectionController(at: index) else { return nil }
        return .init(rawValue: section.sectionType)
    }
    
    private func showButtonView(_ isShowing: Bool) {
        let height = BUTTON_CONTAINER_HEIGHT
        let role = role
        
        UIView.animate(withDuration: 0.3) {
            if isShowing && role == .donor {
                self.buttonViewBottomConstraint?.constant = 0
                self.collectionView.contentInset.bottom = height
                self.view.layoutIfNeeded()
            } else {
                self.buttonViewBottomConstraint?.constant = height
                self.collectionView.contentInset.bottom = 30
            }
        }
    }
    
    public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        let newNavbarColor: UIColor
        let newBackIcon: UIImage?
        
        if scrollView.contentOffset.y > view.bounds.height * PHOTO_SECTION_FRACTIONAL_HEIGHT {
            newNavbarColor = .white
            newBackIcon = .iconArrowLeftCircleWhite
            titleView.isHidden = false
            navigationController?.setNavBarBorder(with: .softPeach)
            
        } else {
            newNavbarColor = .clear
            newBackIcon = .iconArrowLeftCircleBlack
            titleView.isHidden = true
            navigationController?.removeNavBarBorder()
        }
        
        if newNavbarColor != previousNavbarColor {
            updateNavigationBarColor(newNavbarColor) { [weak self] in
                self?.statusBarView.backgroundColor = newNavbarColor
                self?.configureDismissablePresentation(backIcon: newBackIcon)
            }
            previousNavbarColor = newNavbarColor
        }
    }
}

// MARK: UI
private extension DonationItemDetailViewController {
    func configureUI() {
        configureStatusBarView()
        configureCollectionView()
        configureButtonView()
    }
    
    func configureStatusBarView() {
        view.addSubview(statusBarView)
    }
    
    func configureCollectionView() {
        refreshView.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
        emptyMessage = "Detail produk kosong"
        
        collectionView.backgroundColor = .white
        collectionView.setCollectionViewLayout(makeLayout(), animated: true)
        collectionView.refreshControl = refreshView
        collectionView.contentInsetAdjustmentBehavior = .never
        
        collectionView.registerCell(UICollectionViewCell.self)
        collectionView.registerCell(DonationItemDetailImageCell.self)
        collectionView.registerCell(DonationItemDetailInfoCell.self)
        collectionView.registerCell(DonationItemDetailStakeholderCell.self)
        collectionView.registerCell(DonationItemDetailDescriptionCell.self)
    }
    
    func configureButtonView() {
        buttonView.delegate = self
        buttonViewBottomConstraint = wrapWithBottomSafeAreaPaddingView(buttonView, height: 16)
        buttonViewBottomConstraint?.constant = BUTTON_CONTAINER_HEIGHT
        buttonView.anchors.edges.pin(axis: .horizontal)
        buttonView.anchors.height.equal(64)
    }
    
    @objc func didPullToRefresh() {
        refreshView.setLoading(true, backgroundColor: .softPeach)
        onRefresh?()
    }
}

// MARK: DonationItemDetailButtonViewDelegate
extension DonationItemDetailViewController: DonationItemDetailButtonViewDelegate {
    func didTapDonateButton() {
        onTapDonate?()
    }
    
    func didStepperValueChange(value: Int) {
        quantity = value
    }
}

// MARK: DonationItemDetailViewAdapterDelegate
extension DonationItemDetailViewController: DonationItemDetailViewAdapterDelegate {
    func display(
        sections: [CollectionSectionController],
        isProgressCompleted: Bool,
        isLoading: Bool
    ) {
        display(sections: sections)
        showButtonView(isProgressCompleted == false && isLoading == false)
        navigationController?.setNavigationBarHidden(isLoading, animated: true)
    
        if isLoading == false {
            buttonView.resetStepper()
            refreshView.setLoading(false)
            collectionView.setContentOffset(.zero, animated: false)
        }
    }
    
    func display(action donate: @escaping Closure<Int>) {
        onTapDonate = { [unowned self] in
            donate(quantity)
        }
    }
    
    func display(title: String) {
        titleView.text = title
    }
}

// MARK: ResourceErrorView
extension DonationItemDetailViewController: ResourceErrorView {
    public func display(error errorViewModel: ResourceErrorViewModel) {
        display(sections: [])
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
