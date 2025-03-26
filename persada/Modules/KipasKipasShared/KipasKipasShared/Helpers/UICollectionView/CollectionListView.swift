import UIKit

/**
 🚨 This class should not be modified
 */
open class CollectionListView: UICollectionView, UICollectionViewDataSourcePrefetching, UICollectionViewDelegateFlowLayout {
        
    private lazy var _dataSource: UICollectionViewDiffableDataSource<CollectionSectionController, CollectionCellController> = {
        let dataSource = UICollectionViewDiffableDataSource<CollectionSectionController, CollectionCellController>(
            collectionView: self,
            cellProvider: { (collectionView, index, controller) in
                controller.dataSource.collectionView(collectionView, cellForItemAt: index)
            }
        )
        dataSource.supplementaryViewProvider = nil
        return dataSource
    }()
    
 
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        configureCollectionView()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    private func configureCollectionView() {
        backgroundColor = .clear
        delegate = self
        dataSource = _dataSource
        prefetchDataSource = self
        isPrefetchingEnabled = true
    }
    
    public override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        if previous?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            reloadData()
        }
    }

    public func display(sections: [CollectionSectionController]) {
        var snapshot = NSDiffableDataSourceSnapshot<CollectionSectionController, CollectionCellController>()
        sections.forEach { section in
            snapshot.appendSections([section])
            snapshot.appendItems(section.cellControllers, toSection: section)
        }
                
        _dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath)?.delegate
        dl?.collectionView?(collectionView, didSelectItemAt: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath)?.delegate
        dl?.collectionView?(collectionView, willDisplay: cell, forItemAt: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
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
    
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(at: indexPath)?.dataSourcePrefetching
            dsp?.collectionView?(collectionView, cancelPrefetchingForItemsAt: [indexPath])
        }
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        indexPathsForVisibleItems.forEach { indexPath in
            let dl = cellController(at: indexPath)?.delegate
            dl?.scrollViewDidScroll?(scrollView)
        }
    }
    
    private func cellController(at indexPath: IndexPath) -> CollectionCellController? {
        _dataSource.itemIdentifier(for: indexPath)
    }
    
    public func numberOfItems(in section: Int) -> Int {
        guard let sectionController = sectionController(at: section) else {
            return 0
        }
        return _dataSource.snapshot().numberOfItems(inSection: sectionController)
    }
    
    public func sectionController(at section: Int) -> CollectionSectionController? {
        if #available(iOS 15.0, *) {
            return _dataSource.sectionIdentifier(for: section)
        } else {
            return _dataSource.snapshot().sectionIdentifiers[safe: section]
        }
    }
}
