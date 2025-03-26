import UIKit
import KipasKipasShared
import KipasKipasDonateStuff

final class DonationItemCheckoutProductCellController: NSObject {
    
    private let viewModel: DonationItemViewModel
    private let imageAdapter: LoadImagePresentationAdapter
    
    private var cell: DonationItemCheckoutProductCell?
    
    private var image: UIImage? {
        didSet {
            cell?.itemImageView.setImageAnimated(image ?? .boxThumbnailSmall)
        }
    }
    
    init(
        viewModel: DonationItemViewModel,
        imageAdapter: LoadImagePresentationAdapter
    ) {
        self.viewModel = viewModel
        self.imageAdapter = imageAdapter
        super.init()
        
        requestImage()
    }
    
    private func requestImage() {
        guard image == nil else { return }
        
        Task {
            guard let url = viewModel.itemImage.asURL() else { return }
            try await imageAdapter.didRequestImage(url: url)
        }
    }
}

extension DonationItemCheckoutProductCellController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cell = collectionView.dequeueReusableCell(at: indexPath)
        cell?.configure(with: viewModel)
        return cell!
    }
}

extension DonationItemCheckoutProductCellController: ResourceView, ResourceLoadingView, ResourceErrorView {
    func display(view image: [String: UIImage]) {
        self.image = image[viewModel.itemImage]
    }
    
    func display(loading viewModel: ResourceLoadingViewModel) {
        if viewModel.isLoading && image == nil {
            cell?.itemImageView.isShimmering = true
        } else {
            cell?.itemImageView.isShimmering = false
        }
    }
    
    func display(error errorViewModel: ResourceErrorViewModel) {
        cell?.itemImageView.image = .boxThumbnailSmall
    }
}
