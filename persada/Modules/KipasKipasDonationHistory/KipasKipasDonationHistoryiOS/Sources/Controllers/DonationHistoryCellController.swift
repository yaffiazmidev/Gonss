import UIKit
import KipasKipasDonationHistory
import KipasKipasShared

final class DonationHistoryCellController: CellController {
    
    private let viewModel: DonationHistoryViewModel
    private var cell: DonationHistoryCell?
    
    init(viewModel: DonationHistoryViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    override func view(_ collectionView: UICollectionView, forItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let isCredit = viewModel.type == .credit
        
        cell = collectionView.dequeueReusableCell(at: indexPath)
        cell?.donorNameLabel.text = viewModel.accountName.capitalized
        cell?.donorNameLabel.isHidden = isCredit
        cell?.timestampLabel.text = viewModel.createdAt
        cell?.amountLabel.text = (isCredit ? "-" : "") + viewModel.nominal
        cell?.amountLabel.textColor = isCredit ? .brightRed : .azure
        cell?.feeLabel.text = viewModel.bankFee
        cell?.feeLabel.isHidden = isCredit
        
        return cell!
    }
}
