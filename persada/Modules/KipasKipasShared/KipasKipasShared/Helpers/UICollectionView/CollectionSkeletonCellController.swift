import UIKit

public final class CollectionSkeletonCellController<Cell: UICollectionViewCell>: NSObject, UICollectionViewDataSource {
    
    private var cell: Cell?
    
    private let config: SkeletonConfig
    
    init(config: SkeletonConfig) {
        self.config = config
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cell = collectionView.dequeueReusableCell(at: indexPath)
        cell?.setAnimatedSkeletonView(true, config: config)
        return cell!
    }
}

public enum CollectionSkeletonCell<Cell: UICollectionViewCell> {
    public static func create(
        for type: String,
        config: SkeletonConfig = SkeletonConfig()
    ) -> CollectionSectionController {
        let view = CollectionSkeletonCellController<Cell>(config: config)
        let controller = CollectionCellController(view)
        return CollectionSectionController(
            cellControllers: [controller],
            sectionType: type
        )
    }
    
    public static func create(
        count: Int = 1,
        for type: String,
        config: SkeletonConfig = SkeletonConfig()
    ) -> [CollectionSectionController] {
        guard count >= 1 else { fatalError("Need at least 1 cell controller") }
        let controllers = (0...count).map { _ in
            let view = CollectionSkeletonCellController<Cell>(config: config)
            return CollectionCellController(view)
        }
        let section = CollectionSectionController(
            cellControllers: controllers,
            sectionType: type
        )
        return [section]
    }
}
