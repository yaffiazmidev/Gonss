import UIKit
import KipasKipasDonateStuff
import KipasKipasShared

final class DonationItemDetailImageCellController: NSObject {
    
    private let viewModel: DonationItemDetailImage
    private let imageAdapter: LoadImagePresentationAdapter
    
    private var cell: DonationItemDetailImageCell?
    
    private var image: UIImage? {
        didSet {
            cell?.imageView.setImageAnimated(
                image,
                defaultImage: .boxThumbnailBig
            )
        }
    }
    
    init(
        viewModel: DonationItemDetailImage,
        imageAdapter: LoadImagePresentationAdapter
    ) {
        self.viewModel = viewModel
        self.imageAdapter = imageAdapter
        
        super.init()
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
    
    private func cancelRequest() {
        imageAdapter.didCancelImageRequest()
    }
    
    private func requestImage() {
        guard image == nil else { return }
        
        Task {
            guard let url = viewModel.imageURL.asURL() else { return }
            try await imageAdapter.didRequestImage(url: url)
        }
    }
    
    deinit {
        cancelRequest()
    }
}

extension DonationItemDetailImageCellController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cell = collectionView.dequeueReusableCell(at: indexPath)
        cell?.onReuse = { [weak self] in
            self?.releaseCellForReuse()
        }
        cell?.setAnimatedSkeletonView(false)
        return cell!
    }
}

extension DonationItemDetailImageCellController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.cell = cell as? DonationItemDetailImageCell
        self.cell?.imageView.image = image
        requestImage()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        cell?.setZoomOffset(offset: scrollView.contentOffset)
    }
}

extension DonationItemDetailImageCellController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        requestImage()
    }
}

extension DonationItemDetailImageCellController: ResourceView, ResourceLoadingView, ResourceErrorView {
    func display(view image: [String: UIImage]) {
        self.image = image[viewModel.imageURL]
    }
    
    func display(loading viewModel: ResourceLoadingViewModel) {
        if viewModel.isLoading && image == nil {
            cell?.imageView.isShimmering = true
        } else {
            cell?.imageView.isShimmering = false
        }
    }
    
    func display(error errorViewModel: ResourceErrorViewModel) {
        self.image = .boxThumbnailBig
    }
}
