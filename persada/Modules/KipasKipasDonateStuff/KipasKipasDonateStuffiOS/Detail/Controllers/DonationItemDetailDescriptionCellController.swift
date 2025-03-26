import UIKit
import KipasKipasDonateStuff
import KipasKipasShared

final class DonationItemDetailDescriptionCellController: NSObject {
    
    private let viewModel: DonationItemDetailDescription
    
    private var cell: DonationItemDetailDescriptionCell?
  
    init(viewModel: DonationItemDetailDescription) {
        self.viewModel = viewModel
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}

extension DonationItemDetailDescriptionCellController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cell = collectionView.dequeueReusableCell(at: indexPath)
        cell?.setDescription(viewModel.description)
        cell?.onReuse = { [weak self] in
            self?.releaseCellForReuse()
        }
        cell?.setAnimatedSkeletonView(false)
        return cell!
    }
}

