import UIKit
import KipasKipasShared

enum WinnerListSection: String {
    case empty
    case winners
}

extension WinnerListSection {
    static var skeletons: [CollectionSectionController] {
        return CollectionSkeletonCell<WinnerListCell>.create(
            count: 6,
            for: WinnerListSection.winners.rawValue,
            config: SkeletonConfig(
                backgroundColor: UIColor.softPeach,
                highlightColor: UIColor.softPeach.withAlphaComponent(0.5)
            )
        )
    }
}
