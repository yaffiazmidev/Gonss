import UIKit

public struct CollectionCellController {
    public let id: AnyHashable
    public let dataSource: UICollectionViewDataSource
    public let delegate: UICollectionViewDelegate?
    public let delegateFlowLayout: UICollectionViewDelegateFlowLayout?
    public let dataSourcePrefetching: UICollectionViewDataSourcePrefetching?
    
    public init(
        id: AnyHashable = UUID(),
        _ dataSource: UICollectionViewDataSource
    ) {
        self.id = id
        self.dataSource = dataSource
        self.delegate = dataSource as? UICollectionViewDelegate
        self.delegateFlowLayout = dataSource as? UICollectionViewDelegateFlowLayout
        self.dataSourcePrefetching = dataSource as? UICollectionViewDataSourcePrefetching
    }
}

extension CollectionCellController: Equatable {
    public static func == (lhs: CollectionCellController, rhs: CollectionCellController) -> Bool {
        lhs.id == rhs.id
    }
}

extension CollectionCellController: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
