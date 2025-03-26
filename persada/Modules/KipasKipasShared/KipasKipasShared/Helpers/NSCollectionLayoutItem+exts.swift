import UIKit

extension NSCollectionLayoutItem {
    public static func withEntireSize() -> NSCollectionLayoutItem {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        return NSCollectionLayoutItem(layoutSize: itemSize)
    }
    
    public static func entireWidth(withHeight height: NSCollectionLayoutDimension) -> NSCollectionLayoutItem {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: height
        )
        return NSCollectionLayoutItem(layoutSize: itemSize)
    }
}
