import UIKit

open class CellController: NSObject {
    private let id: UUID
    
    open var isSelected: Bool = false
    
    open var isLoading: Bool = false
    
    public init(id: UUID = UUID()) {
        self.id = id
    }
    
    static func == (lhs: CellController, rhs: CellController) -> Bool {
        return lhs.id == rhs.id
    }
    
    open func view(_ collectionView: UICollectionView, forItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    open func select() {}
    open func deselect() {}
}
