import UIKit
import KipasKipasReport
import KipasKipasShared

protocol ReportCellControllerDelegate: AnyObject {
    func didSelectReason(_ reason: ReportReason)
}

final class KKReportCellController: CellController {
    
    private let item: ReportReason
    // TODO: Remove weak
    private weak var delegate: ReportCellControllerDelegate?
    
    private var cell: KKReportCell?
    
    init(item: ReportReason, delegate: ReportCellControllerDelegate) {
        self.item = item
        self.delegate = delegate
        super.init()
    }
    
    override func view(_ collectionView: UICollectionView, forItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: KKReportCell.identifier, for: indexPath) as? KKReportCell
        cell?.reasonLabel.text = item.value
        return cell!
    }
    
    override func select() {
        cell?.select()
        delegate?.didSelectReason(item)
    }
    
    override func deselect() {
        cell?.deselect()
    }
}
