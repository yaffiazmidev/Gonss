import UIKit
import KipasKipasShared
import KipasKipasDonationBadge

public final class ListBadgeViewController: UICollectionViewController {
    
    private let hud = KKProgressHUD()
    
    private var badges: [BadgeViewModel] = [] {
        didSet {
            reloadAndInvalidateLayout()
            scrollToMyBadge()
        }
    }

    public var onLoad: (() -> Void)?
    public var onUpdate: ((_ isShowBadge: Bool) -> Void)?
    
    convenience init() {
        let layout = CollectionViewPagingLayout()
        layout.defaultAnimator = DefaultViewAnimator(2.0, curve: .easeInOut)
        self.init(collectionViewLayout: layout)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        onLoad?()
    }
    
    private func reloadAndInvalidateLayout() {
        collectionView.forceReloadData()
        pagingLayout?.invalidateLayoutInBatchUpdate()
    }
    
    private var pagingLayout: CollectionViewPagingLayout? {
        collectionView.collectionViewLayout as? CollectionViewPagingLayout
    }
    
    private func scrollToMyBadge() {
        guard let index = badges.firstIndex(where: { $0.isMyBadge == true }) else { return }
        pagingLayout?.setCurrentPage(index, animated: true)
    }
    
    private func cell(forItemAt index: Int) -> BadgeCell? {
        return collectionView.cellForItem(at: .init(item: index, section: 0)) as? BadgeCell
    }
    
    public override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return badges.count
    }
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: BadgeCell = collectionView.dequeueReusableCell(at: indexPath)
        
        if let badge = badges[safe: indexPath.item] {
            cell.configure(with: badge, delegate: self)
        }
        
        return cell
    }
}

extension ListBadgeViewController: ListBadgeView {
    public func display(_ viewModel: ListBadgeViewModel) {
        if viewModel.badges.isEmpty {
            collectionView.reloadEmpty()
        } else {
            badges = viewModel.badges
        }
    }
    
    public func display(_ isUpdateSuccessful: Bool) {
        if let currentPage = pagingLayout?.currentPage {
            cell(forItemAt: currentPage)?.updateBadgeCompleted(isUpdateSuccessful)
        }
        let toastMessage = isUpdateSuccessful ? "Badge berhasil di update" : "Badge tidak berhasil di update"
        showToast(with: toastMessage)
    }
}

extension ListBadgeViewController: ListBadgeLoadingView {
    public func display(_ viewModel: ListBadgeLoadingViewModel) {
        if viewModel.isLoading {
            hud.show(in: view)
        } else {
            hud.dismiss()
        }
    }
}

extension ListBadgeViewController: BadgeMessageViewDelegate {
    func onSwitchUpdate(_ isShowBadge: Bool) {
        // TODO: Remove `DispatchQueue`
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.onUpdate?(isShowBadge)
        }
    }
}

// MARK: UI
private extension ListBadgeViewController {
    func configureUI() {
        configureCollectionView()
    }
    
    func configureCollectionView() {
        collectionView.emptyView = EmptyView(message: "Badge donasi belum tersedia")
        collectionView.backgroundColor = UIColor(red: 0.20, green: 0.02, blue: 0.28, alpha: 1.00)
        collectionView.isPagingEnabled = true
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.clipsToBounds = false
        collectionView.registerCell(BadgeCell.self)
    }
}

private extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension UIWindow {
    static var current: UIWindow? {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return scene?.windows.first
    }
}


extension UIScreen {
    static var current: UIScreen? {
        UIWindow.current?.screen
    }
}
