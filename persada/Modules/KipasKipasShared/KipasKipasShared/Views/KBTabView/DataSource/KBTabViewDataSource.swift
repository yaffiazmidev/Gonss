//
//  Created by BK @kitabisa.
//

import UIKit

typealias DataSource<Item: KBTabViewItemable> = UICollectionViewDiffableDataSource<Int, Item>

final class KBTabViewDataSource<Item: KBTabViewItemable, Cell: KBTabViewBaseCell>: DataSource<Item> {
    
    init(
        collectionView: UICollectionView,
        provider: @escaping  UICollectionViewDiffableDataSource<Int, Item>.CellProvider
    ) {
        super.init(collectionView: collectionView, cellProvider: provider)
    }
    
    func reload(with items: [Item], animated: Bool = false, completion: (() -> Void)? = nil) {
        var snapshot = snapshot()
        
        // guard !snapshot.itemIdentifiers.elementsEqual(items) else { return }
        
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        snapshot.appendItems(items, toSection: 0)
        
        if #available(iOS 15.0, *) {
            applySnapshotUsingReloadData(snapshot)
        } else {
            apply(snapshot, animatingDifferences: animated, completion: completion)
        }
    }
}
