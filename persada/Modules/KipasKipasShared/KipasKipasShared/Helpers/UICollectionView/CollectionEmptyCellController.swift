import UIKit

public final class CollectionEmptyCellController: NSObject, UICollectionViewDataSource {
    
    private var cell: CollectionEmptyCell?
    
    private let viewModel: CollectionEmptyViewModel
    
    public init(viewModel: CollectionEmptyViewModel) {
        self.viewModel = viewModel
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cell = collectionView.dequeueReusableCell(at: indexPath)
        cell?.configure(with: viewModel)
        return cell!
    }
}
