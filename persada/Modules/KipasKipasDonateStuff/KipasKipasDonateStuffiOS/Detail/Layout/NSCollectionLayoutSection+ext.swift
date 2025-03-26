import UIKit

internal let PHOTO_SECTION_FRACTIONAL_HEIGHT: CGFloat = 0.4

extension NSCollectionLayoutSection {
    
    static func template(for type: DonationItemDetailSection) -> NSCollectionLayoutSection? {
        switch type {
        case .photos :
            return .itemPhotoSection
        case .info:
            return .itemInfoSection
        case .divider:
            return .dividerSection
        case .stakeholder:
            return .itemStakeholderSection
        case .description:
            return .itemDescriptionSection
        }
    }
    
    private static var itemPhotoSection: NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem.withEntireSize()
        let groupSize = NSCollectionLayoutSize.entireWidth(withHeight: .fractionalHeight(PHOTO_SECTION_FRACTIONAL_HEIGHT))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        
        return section
    }
    
    private static var itemInfoSection: NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem.entireWidth(withHeight: .estimated(105))
        let groupSize = NSCollectionLayoutSize.entireWidth(withHeight: .estimated(105))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }
    
    private static var dividerSection: NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem.entireWidth(withHeight: .fractionalHeight(1))
        let groupSize = NSCollectionLayoutSize.entireWidth(withHeight: .estimated(4))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }
    
    private static var itemStakeholderSection: NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem.entireWidth(withHeight: .estimated(62))
        let groupSize = NSCollectionLayoutSize.entireWidth(withHeight: .estimated(62))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }
    
    private static var itemDescriptionSection: NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem.entireWidth(withHeight: .estimated(100))
        let groupSize = NSCollectionLayoutSize.entireWidth(withHeight: .estimated(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }
}
