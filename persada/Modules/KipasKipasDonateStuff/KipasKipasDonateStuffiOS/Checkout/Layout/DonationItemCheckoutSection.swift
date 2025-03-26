import UIKit

enum DonationItemCheckoutSection: String {
    case product
    case address
    case summary
    case divider
}

extension NSCollectionLayoutSection {
    
    static func template(for type: DonationItemCheckoutSection) -> NSCollectionLayoutSection? {
        switch type {
        case .product:
            return .productSection
        case .address:
            return .addressSection
        case .summary:
            return .summarySection
        case .divider:
            return .dividerSection
        }
    }
    
    private static var productSection: NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem.entireWidth(withHeight: .estimated(74))
        let groupSize = NSCollectionLayoutSize.entireWidth(withHeight: .estimated(74))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }
    
    private static var dividerSection: NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem.entireWidth(withHeight: .estimated(4))
        let groupSize = NSCollectionLayoutSize.entireWidth(withHeight: .estimated(4))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }
    
    private static var addressSection: NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem.entireWidth(withHeight: .estimated(80))
        let groupSize = NSCollectionLayoutSize.entireWidth(withHeight: .estimated(80))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }
    
    private static var summarySection: NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem.entireWidth(withHeight: .estimated(25))
        let groupSize = NSCollectionLayoutSize.entireWidth(withHeight: .estimated(25))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }
}
