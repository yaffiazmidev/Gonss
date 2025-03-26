import UIKit
import KipasKipasShared
import KipasKipasDonateStuff

final class DonationItemPaymentProductCellController: NSObject {
    
    private let viewModel: DonationItemPaymentProductViewModel
    private let imageAdapter: LoadImagePresentationAdapter
    
    private var cell: DonationItemPaymentProductCell?
    
    private var image: UIImage? {
        didSet {
            cell?.itemImageView.setImageAnimated(image ?? .boxThumbnailSmall)
        }
    }
    
    init(
        viewModel: DonationItemPaymentProductViewModel,
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
            guard let url = viewModel.productPhoto.asURL() else { return }
            try await imageAdapter.didRequestImage(url: url)
        }
    }
}

extension DonationItemPaymentProductCellController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cell = collectionView.dequeueReusableCell(at: indexPath)
        cell?.configure(with: viewModel)
        cell?.setAnimatedSkeletonView(false)
        return cell!
    }
}

extension DonationItemPaymentProductCellController: ResourceView, ResourceLoadingView, ResourceErrorView {
    func display(view image: [String: UIImage]) {
        self.image = image[viewModel.productPhoto]
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

public final class CollectionHeaderFooterCellController: NSObject, UICollectionViewDataSource {
    
    private let text: String
    private let height: CGFloat
    
    private var cell: CollectionHeaderFooterCell?
    
    public init(
        text: String = "",
        height: CGFloat = 30
    ) {
        self.text = text
        self.height = height
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cell = collectionView.dequeueReusableCell(at: indexPath)
        cell?.headerLabel.anchors.height.equal(height)
        cell?.headerLabel.text = text
        return cell!
    }
}

