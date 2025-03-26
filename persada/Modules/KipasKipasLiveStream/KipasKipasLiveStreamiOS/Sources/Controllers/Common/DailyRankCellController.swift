import UIKit
import KipasKipasShared
import KipasKipasLiveStream

final class DailyRankCellController: CellController {
    
    private let viewModel: LiveDailyRankViewModel
    private let selection: (String) -> Void
    private var cell: DailyRankCell?
    
    init(
        viewModel: LiveDailyRankViewModel,
        selection: @escaping (String) -> Void
    ) {
        self.viewModel = viewModel
        self.selection = selection
    }
    
    override func view(_ collectionView: UICollectionView, forItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cell = collectionView.dequeueReusableCell(at: indexPath)
        cell?.rankLabel.text = String(indexPath.item + 4)
        
        if let image = viewModel.imageURL, !image.isEmpty {
            cell?.imageView.setImage(with: image)
            cell?.imageView.contentMode = .scaleAspectFill
        }
        
        cell?.nameLabel.text = viewModel.name
        cell?.verifiedIcon.isHidden = viewModel.isVerified == false
        cell?.totalLikesLabel.text = viewModel.totalLikes
        cell?.totalLikesLabel.isHidden = viewModel.totalLikes == "0"
        
        return cell!
    }
    
    override func select() {
        selection(viewModel.userId)
    }
}
