import UIKit
import KipasKipasNotification
import KipasKipasShared

public protocol NotificationSystemCellControllerDelegate: AnyObject {
    func didSelectIsRead(item: NotificationSystemItem)
}

public final class NotificationSystemCellController: CellController {
    
    private var viewModel: NotificationSystemItem
    private var cell: NotificationSystemItemCell?
    private var delegate: NotificationSystemCellControllerDelegate?
    private let selection: (String) -> Void
    
    public init(
        viewModel: NotificationSystemItem,
        delegate: NotificationSystemCellControllerDelegate,
        selection: @escaping (String) -> Void
    ) {
        self.viewModel = viewModel
        self.delegate = delegate
        self.selection = selection
        super.init()
    }
   
    public override func view(_ collectionView: UICollectionView, forItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        cell = collectionView.dequeueReusableCell(at: indexPath)
//        cell?.configure(
//            types: viewModel.types,
//            title: viewModel.title,
//            description: viewModel.subTitle,
//            isRead: viewModel.isRead,
//            epoch: viewModel.createdAt
//        )
        return cell!
    }
    
    public override func select() {
//        if viewModel.types == "account" && viewModel.isRead == false {
//            delegate?.didSelectIsRead(item: viewModel)
//            cell?.select()
//        } else if viewModel.types == "hotroom" {
//            selection(viewModel.id)
//        }
    }
    
    public override func deselect() {
        cell?.deselect()
    }
}
     
