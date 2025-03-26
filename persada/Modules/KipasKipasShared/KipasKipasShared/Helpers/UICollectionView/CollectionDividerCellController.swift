import UIKit

public typealias Divider = CollectionDividerCellController

public final class CollectionDividerCellController: NSObject, UICollectionViewDataSource {
    
    private let view = UIView()
    private let color: UIColor
    private let height: CGFloat
    
    private var cell: UICollectionViewCell?
    
    public init(
        color: UIColor,
        height: CGFloat
    ) {
        self.color = color
        self.height = height
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cell = collectionView.dequeueReusableCell(at: indexPath)
        
        cell?.addSubview(view)
        view.backgroundColor = color
        view.anchors.top.pin()
        view.anchors.edges.pin(axis: .horizontal)
        view.anchors.height.equal(height)

        return cell!
    }
}

