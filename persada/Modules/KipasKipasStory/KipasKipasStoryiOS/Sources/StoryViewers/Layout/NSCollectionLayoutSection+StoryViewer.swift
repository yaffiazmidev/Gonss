import UIKit
import KipasKipasShared

extension NSCollectionLayoutSection {
    
    static func layout(for section: StoryViewersSection) -> NSCollectionLayoutSection? {
        switch section {
        case .empty:
            return storyViewersEmptySection
        case .viewers:
            return storyViewersSection
        }
    }
    
    private static var storyViewersEmptySection: NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem.entireWidth(withHeight: .fractionalHeight(0.8))
        let groupSize = NSCollectionLayoutSize.withEntireSize()
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }
    
    private static var storyViewersSection: NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem.withEntireSize()
        let groupSize = NSCollectionLayoutSize.entireWidth(withHeight: .absolute(65))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 4
        
        return section
    }
}
