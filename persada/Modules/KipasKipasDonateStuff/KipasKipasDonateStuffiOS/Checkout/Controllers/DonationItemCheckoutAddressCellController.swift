import UIKit
import KipasKipasDonateStuff
import KipasKipasShared

final class DonationItemCheckoutAddressCellController: NSObject {
    
    private let viewModel: DonationItemDetailStakeholder
    
    private var cell: DonationItemCheckoutAddressCell?
  
    init(viewModel: DonationItemDetailStakeholder) {
        self.viewModel = viewModel
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}

extension DonationItemCheckoutAddressCellController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cell = collectionView.dequeueReusableCell(at: indexPath)
        cell?.setAddress(viewModel.shippingAddress)
        cell?.onReuse = { [weak self] in
            self?.releaseCellForReuse()
        }
        return cell!
    }
}

