//
//  Created by BK @kitabisa.
//

import UIKit

public final class KBTabViewFixedLayout: KBTabViewLayout {
    internal override func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let dimension = 1.0 / CGFloat(numberOfItems)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(dimension), heightDimension: .absolute(layoutHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

