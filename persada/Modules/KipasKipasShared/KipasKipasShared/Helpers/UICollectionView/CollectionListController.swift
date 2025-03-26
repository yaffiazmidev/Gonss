import UIKit

/**
 🚨 This class should not be modified
 */
open class CollectionListController: UICollectionViewController, UICollectionViewDataSourcePrefetching, UICollectionViewDelegateFlowLayout, NavigationAppearance, NavigationAppearanceUpdatable {
    
    public var emptyMessage: String?
    
    private lazy var dataSource: EmptyableDiffableDataSource<CollectionSectionController, CollectionCellController> = {
        let dataSource = EmptyableDiffableDataSource<CollectionSectionController, CollectionCellController>(
            collectionView: collectionView,
            cellProvider: { (collectionView, index, controller) in
                controller.dataSource.collectionView(collectionView, cellForItemAt: index)
            },
            emptyStateView: EmptyView(message: emptyMessage ?? "")
        )
        dataSource.supplementaryViewProvider = nil
        return dataSource
    }()
    
    private(set) public lazy var refreshView = UIRefreshControl()
    
    private(set) public lazy var statusBarView: UIView = {
        let view = UIView(frame: statusBarFrame)
        view.isOpaque = false
        view.backgroundColor = .clear
        return view
    }()
    
    private(set) public lazy var titleView: UILabel = {
        let label = UILabel()
        label.font = .roboto(.medium, size: 15)
        label.isHidden = true
        label.numberOfLines = 2
        label.textAlignment = .left
        label.textColor = .night
        label.backgroundColor = .clear
        return label
    }()
    
    public var onRefresh: (() -> Void)?
    
    public init() {
        super.init(collectionViewLayout: UICollectionViewLayout())
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        configureCollectionView()
        refresh()
    }
    
    private func configureCollectionView() {
        collectionView.dataSource = dataSource
        collectionView.prefetchDataSource = self
    }
    
    public override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        if previous?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            collectionView.reloadData()
        }
    }
    
    private func refresh() {
        onRefresh?()
    }
    
    deinit {
        display(sections: [])
    }
    
    open func display(
        sections: [CollectionSectionController],
        isScrollEnabled: Bool = true
    ) {
        var snapshot = NSDiffableDataSourceSnapshot<CollectionSectionController, CollectionCellController>()
        sections.forEach { section in
            snapshot.appendSections([section])
            snapshot.appendItems(section.cellControllers, toSection: section)
        }
        
        collectionView.isScrollEnabled = isScrollEnabled
                
        if #available(iOS 15.0, *) {
            dataSource.applySnapshotUsingReloadData(snapshot, completion: nil)
        } else {
            dataSource.apply(snapshot)
        }
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath)?.delegate
        dl?.collectionView?(collectionView, didSelectItemAt: indexPath)
    }
    
    public override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath)?.delegate
        dl?.collectionView?(collectionView, willDisplay: cell, forItemAt: indexPath)
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath)?.delegate
        dl?.collectionView?(collectionView, didEndDisplaying: cell, forItemAt: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(at: indexPath)?.dataSourcePrefetching
            dsp?.collectionView(collectionView, prefetchItemsAt: [indexPath])
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dl = cellController(at: indexPath)?.delegateFlowLayout
        return dl?.collectionView?(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath) ?? .zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView? {
       return nil
    }
    
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(at: indexPath)?.dataSourcePrefetching
            dsp?.collectionView?(collectionView, cancelPrefetchingForItemsAt: [indexPath])
        }
    }
    
    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        collectionView.indexPathsForVisibleItems.forEach { indexPath in
            let dl = cellController(at: indexPath)?.delegate
            dl?.scrollViewDidScroll?(scrollView)
        }
    }
    
    open override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        collectionView.indexPathsForVisibleItems.forEach { indexPath in
            let dl = cellController(at: indexPath)?.delegate
            dl?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
        }
    }
    
    private func cellController(at indexPath: IndexPath) -> CollectionCellController? {
        dataSource.itemIdentifier(for: indexPath)
    }
    
    public func numberOfItems(in section: Int) -> Int {
        guard let sectionController = sectionController(at: section) else {
            return 0
        }
        return dataSource.snapshot().numberOfItems(inSection: sectionController)
    }
    
    public func sectionController(at section: Int) -> CollectionSectionController? {
        if #available(iOS 15.0, *) {
            return dataSource.sectionIdentifier(for: section)
        } else {
            return dataSource.snapshot().sectionIdentifiers[safe: section]
        }
    }
}

private extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
