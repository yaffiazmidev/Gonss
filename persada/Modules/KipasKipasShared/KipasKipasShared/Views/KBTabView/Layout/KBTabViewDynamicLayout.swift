//
//  Created by BK @kitabisa.
//

import UIKit

public final class KBTabViewDynamicLayout: KBTabViewLayout {
    
    public var spacing: CGFloat = 0 {
        didSet {
            setNeedsUpdate()
        }
    }
    
    public var contentInsets: NSDirectionalEdgeInsets = .zero {
        didSet {
            setNeedsUpdate()
        }
    }
    
    public var estimatedItemWidth: CGFloat = 250 {
        didSet {
            setNeedsUpdate()
        }
    }
    
    internal override func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(estimatedItemWidth), heightDimension: .absolute(layoutHeight))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = contentInsets
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

