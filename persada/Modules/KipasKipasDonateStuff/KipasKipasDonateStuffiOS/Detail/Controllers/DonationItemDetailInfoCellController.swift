import UIKit
import KipasKipasDonateStuff
import KipasKipasShared

final class DonationItemDetailInfoCellController: NSObject {
    
    private let viewModel: DonationItemDetailInfo
    private let role: DonationItemRole
    
    private var cell: DonationItemDetailInfoCell?
  
    init(
        viewModel: DonationItemDetailInfo,
        role: DonationItemRole
    ) {
        self.viewModel = viewModel
        self.role = role
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}

extension DonationItemDetailInfoCellController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cell = collectionView.dequeueReusableCell(at: indexPath)
        cell?.configure(with: viewModel, role: role)
        cell?.onReuse = { [weak self] in
            self?.releaseCellForReuse()
        }
        cell?.setAnimatedSkeletonView(false)
        return cell!
    }
}
