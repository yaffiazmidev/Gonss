import UIKit
import KipasKipasShared

enum DonationItemPaymentSection: String {
    case header
    case initiator
    case product
    case summary
    case divider
}

extension DonationItemPaymentSection {
    static var skeletons: [CollectionSectionController] {
        let skeletons = [
            CollectionSkeletonCell<DonationItemPaymentInitiatorCell>.create(
                for: DonationItemPaymentSection.initiator.rawValue
            )
        ]
        
        let productSkeletons = (1...3).map { _ in
            CollectionSkeletonCell<DonationItemPaymentProductCell>.create(
                for: DonationItemPaymentSection.product.rawValue
            )
        }
        
        let summarySkeletons = (1...8).map { _ in
            CollectionSkeletonCell<DonationItemPaymentSummaryCell>.create(
                for: DonationItemPaymentSection.summary.rawValue
            )
        }
        
        return skeletons + productSkeletons + summarySkeletons
    }
}

extension NSCollectionLayoutSection {
    
    static func template(for type: DonationItemPaymentSection) -> NSCollectionLayoutSection? {
        switch type {
        case .header:
            return .headerSection
        case .initiator:
            return .initiatorSection
        case .divider:
            return .dividerSection
        case .product:
            return .productSection
        case .summary:
            return .summarySection
        }
    }
    
    private static var headerSection: NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem.entireWidth(withHeight: .estimated(30))
        let groupSize = NSCollectionLayoutSize.entireWidth(withHeight: .estimated(30))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }
    
    private static var initiatorSection: NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem.entireWidth(withHeight: .estimated(150))
        let groupSize = NSCollectionLayoutSize.entireWidth(withHeight: .estimated(150))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }
    
    private static var dividerSection: NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem.withEntireSize()
        let groupSize = NSCollectionLayoutSize.entireWidth(withHeight: .estimated(8))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }
    
    private static var productSection: NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem.entireWidth(withHeight: .estimated(80))
        let groupSize = NSCollectionLayoutSize.entireWidth(withHeight: .estimated(80))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }
    
    private static var summarySection: NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem.entireWidth(withHeight: .estimated(40))
        let groupSize = NSCollectionLayoutSize.entireWidth(withHeight: .estimated(40))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }
}
