import UIKit
import KipasKipasShared
import KipasKipasDonateStuff

final class DonationItemPaymentInitiatorCellController: NSObject {
    
    private let viewModel: DonationItemPaymentInitiatorViewModel
    private let imageAdapter: LoadImagePresentationAdapter
    private let showInitiatorProfile: Closure<String>
    
    private var cell: DonationItemPaymentInitiatorCell?
    
    private var images: [String: UIImage] = [:] {
        didSet {
            cell?.donationPhotoImageView.image = images[viewModel.donationPhoto]
            cell?.initiatorImageView.image = images[viewModel.initiatorPhoto]
        }
    }
    
    init(
        viewModel: DonationItemPaymentInitiatorViewModel,
        imageAdapter: LoadImagePresentationAdapter,
        showInitiatorProfile: @escaping Closure<String>
    ) {
        self.viewModel = viewModel
        self.imageAdapter = imageAdapter
        self.showInitiatorProfile = showInitiatorProfile
        super.init()
        
        requestImage()
    }
    
    private func requestImage() {
        Task {
            let urls = [viewModel.donationPhoto, viewModel.initiatorPhoto].compactMap(URL.init)
            try await imageAdapter.didRequestImages(
                urls: urls,
                delay: 0.5,
                conditions: { [weak self] url in
                    self?.images[url.absoluteString] == nil
                }
            )
        }
    }
}

extension DonationItemPaymentInitiatorCellController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cell = collectionView.dequeueReusableCell(at: indexPath)
        cell?.configure(with: viewModel)
        cell?.setAnimatedSkeletonView(false)
        cell?.onTapInitiatorView = { [weak self, viewModel] in
            self?.showInitiatorProfile(viewModel.initiatorId)
        }
        return cell!
    }
}

extension DonationItemPaymentInitiatorCellController: ResourceView, ResourceLoadingView {
    func display(view image: [String: UIImage]) {
        images += image
    }
}
