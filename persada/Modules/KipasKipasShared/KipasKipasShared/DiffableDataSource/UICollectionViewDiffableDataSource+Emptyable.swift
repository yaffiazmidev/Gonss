import UIKit

public class EmptyableDiffableDataSource<S, T>: UICollectionViewDiffableDataSource<S, T> where S: Hashable, T: Hashable {
    
    private var collectionView: UICollectionView
    private var emptyStateView: UIView?
    
    public init(
        collectionView: UICollectionView,
        cellProvider: @escaping UICollectionViewDiffableDataSource<S, T>.CellProvider,
        emptyStateView: UIView? = nil
    ) {
        self.collectionView = collectionView
        self.emptyStateView = emptyStateView
        super.init(collectionView: collectionView, cellProvider: cellProvider)
    }
    
    
    @available(iOS 15.0, *)
    public nonisolated override func applySnapshotUsingReloadData(_ snapshot: NSDiffableDataSourceSnapshot<S, T>, completion: (() -> Void)? = nil) {
        super.applySnapshotUsingReloadData(snapshot, completion: completion)
        Task {
            await setErrorViewIfNeeded(snapshot)
        }
    }
    
    public override func apply(_ snapshot: NSDiffableDataSourceSnapshot<S, T>, animatingDifferences: Bool = true, completion: (() -> Void)? = nil) {
        super.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
        setErrorViewIfNeeded(snapshot)
    }
    
    private func setErrorViewIfNeeded(_ snapshot: NSDiffableDataSourceSnapshot<S, T>) {
        guard let emptyView = emptyStateView else {
            return
        }
        
        if snapshot.itemIdentifiers.isEmpty {
            collectionView.isUserInteractionEnabled = false
            
            collectionView.addSubview(emptyView)
            emptyView.anchors.edges.pin(to: collectionView.layoutMarginsGuide)
        } else {
            collectionView.isUserInteractionEnabled = true
            emptyStateView?.removeFromSuperview()
        }
    }
    
    public var isEmpty: Bool {
        return snapshot().itemIdentifiers.isEmpty
    }
    
    public var emptyView: UIView? {
        return emptyStateView
    }
}
