import UIKit
import KipasKipasShared

func makeDonationItemDetailLoadingSections() -> [CollectionSectionController] {
    let skeletons = [
        CollectionSkeletonCell<DonationItemDetailImageCell>.create(
            for: DonationItemDetailSection.photos.rawValue
        ),
        CollectionSkeletonCell<DonationItemDetailInfoCell>.create(
            for: DonationItemDetailSection.info.rawValue
        ),
        CollectionSkeletonCell<DonationItemDetailStakeholderCell>.create(
            for: DonationItemDetailSection.stakeholder.rawValue
        )
    ]
    
    let descriptionSkeletons = (1...5).map { _ in
        return CollectionSkeletonCell<DonationItemDetailDescriptionCell>.create(
            for: DonationItemDetailSection.description.rawValue
        )
    }
    return skeletons + descriptionSkeletons
}
