import UIKit
import KipasKipasDonateStuff
import KipasKipasShared

final class DonationItemDetailStakeholderCellController: NSObject {
    
    private let viewModel: DonationItemDetailStakeholder
    private let imageAdapter: LoadImagePresentationAdapter
    
    private var cell: DonationItemDetailStakeholderCell?
    
    private var images: [String: UIImage] = [:] {
        didSet {
            let placeholder = UIImage.defaultProfileImageSmallCircle
            cell?.setSupplierImage(images[viewModel.supplierImage] ?? placeholder)
            cell?.setInitiatorImage(images[viewModel.initiatorImage] ?? placeholder)
        }
    }
    
    /// When the image is not prefetched,
    /// we need to re-request the image some time later
    private var delayedImageRequest: TimedSequence<(() -> Void)?>? = {
        return TimedSequence(interval: 2) { completion in
            completion?()
        }
    }()
    
    init(
        viewModel: DonationItemDetailStakeholder,
        imageAdapter: LoadImagePresentationAdapter
    ) {
        self.viewModel = viewModel
        self.imageAdapter = imageAdapter
        super.init()
    }
    
    private func cancelRequest() {
        delayedImageRequest = nil
        imageAdapter.didCancelImageRequest()
    }
    
    private func requestImage() {
        Task {
            let urls = [viewModel.supplierImage, viewModel.initiatorImage].compactMap(URL.init)
            try await imageAdapter.didRequestImages(
                urls: urls,
                delay: 0.5
            ) { [weak self] url in
                self?.images[url.absoluteString] == nil
            }
        }
    }
    
    deinit {
        cancelRequest()
    }
}

extension DonationItemDetailStakeholderCellController: UICollectionViewDataSource {
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

extension DonationItemDetailStakeholderCellController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.cell = cell as? DonationItemDetailStakeholderCell
        requestImage()
    }
}

extension DonationItemDetailStakeholderCellController: ResourceView, ResourceLoadingView, ResourceErrorView {
    func display(view image: [String: UIImage]) {
        images += image
    }
    
    func display(error errorViewModel: ResourceErrorViewModel) {
        cell?.setSupplierImage(.defaultProfileImageSmallCircle)
        cell?.setInitiatorImage(.defaultProfileImageSmallCircle)
    }
}

extension Dictionary {
    static func += (left: inout Dictionary, right: Dictionary) {
        left.merge(right) { (current, _) in current }
    }
}
