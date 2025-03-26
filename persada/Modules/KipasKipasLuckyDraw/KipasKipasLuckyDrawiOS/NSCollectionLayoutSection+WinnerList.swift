import UIKit
import KipasKipasShared

extension NSCollectionLayoutSection {
    static func layout(for section: WinnerListSection) -> NSCollectionLayoutSection? {
        switch section {
        case .empty:
            return emptySection
        case .winners:
            return winnersSection
        }
    }
    
    private static var emptySection: NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem.entireWidth(withHeight: .fractionalHeight(0.8))
        let groupSize = NSCollectionLayoutSize.withEntireSize()
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }
    
    private static var winnersSection: NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem.withEntireSize()
        let groupSize = NSCollectionLayoutSize.entireWidth(withHeight: .absolute(26))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        
        return section
    }
}
