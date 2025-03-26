import UIKit
import KipasKipasDonationRank
import KipasKipasShared
import Kingfisher

protocol DonationGlobalRankCellControllerDelegate {
    func prefetchImages(completion: @escaping ([URL]) -> Void)
    func didCancelRequestLoadImage()
}

final class DonationGlobalRankCellController: CellController {
    
    private let item: DonationGlobalRankItem
    private let delegate: DonationGlobalRankCellControllerDelegate
    
    private var cell: DonationRankCell?
    
    init(
        item: DonationGlobalRankItem,
        delegate: DonationGlobalRankCellControllerDelegate
    ) {
        self.item = item
        self.delegate = delegate
    }
    
    override func view(_ collectionView: UICollectionView, forItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cell = collectionView.dequeueReusableCell(at: indexPath)
        cell?.nameLabel.text = item.name
        cell?.usernameLabel.text = item.username
        cell?.usernameLabel.isHidden = item.isShowBadge == false
        cell?.imageView.rank = item.rank
        cell?.imageView.shouldShowBadge = item.isShowBadge
        
        return cell!
    }
    
    func prefetch() {
        cell?.imageView.userImageView.kf.indicatorType = .activity
        
        let retry = DelayRetryStrategy(maxRetryCount: 3, retryInterval: .seconds(3))

        delegate.prefetchImages { [weak self] urls in
            guard let self = self else { return }
            
            let badgeURL = urls.first { $0.absoluteString == self.item.badgeURL + "?x-oss-process=image/format,png/resize,w_200" }
            self.cell?.imageView.badgeImageView.kf.setImage(
                with: badgeURL,
                options: [.cacheOriginalImage, .waitForCache, .retryStrategy(retry)]
            )
            
            guard self.item.isShowBadge else { return }
            
            let profileImageURL =  urls.first { $0.absoluteString == self.item.profileImageURL + "?x-oss-process=image/format,jpg/interlace,1/resize,w_100" }
            self.cell?.imageView.userImageView.kf.setImage(
                with: profileImageURL,
                placeholder: UIImage.defaultProfileImage,
                options: [.cacheOriginalImage, .waitForCache, .retryStrategy(retry)]
            )
        }
    }
    
    func cancel() {
        delegate.didCancelRequestLoadImage()
        releaseCellForReuse()
    }
}

private extension DonationGlobalRankCellController {
    func releaseCellForReuse() {
        cell = nil
    }
}
