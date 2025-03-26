import UIKit
import KipasKipasDonateStuff
import KipasKipasShared

public enum DonationItemRole {
    case donor
    case initiator
}

final class DonationItemCellController: NSObject {
    
    private let viewModel: DonationItemViewModel
    private let imageAdapter: LoadImagePresentationAdapter
    private let role: DonationItemRole
    private let selection: Closure<(String, DonationItemRole)>
    
    private var cell: DonationItemListCell?
    
    private var image: UIImage? {
        didSet {
            cell?.itemImageView.setImageAnimated(image, defaultImage: .boxThumbnailSmall)
            
            if image != nil {
                cancelRequest()
            }
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
        viewModel: DonationItemViewModel,
        imageAdapter: LoadImagePresentationAdapter,
        role: DonationItemRole,
        selection: @escaping Closure<(String, DonationItemRole)>
    ) {
        self.viewModel = viewModel
        self.imageAdapter = imageAdapter
        self.role = role
        self.selection = selection
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
    
    private func cancelRequest() {
        delayedImageRequest = nil
        imageAdapter.didCancelImageRequest()
    }
    
    private func requestImage() {
        guard image == nil else { return }
        
        Task {
            guard let url = viewModel.itemImage.asURL() else { return }
            try await imageAdapter.didRequestImage(url: url)
            delayedImageRequest?.append(requestImage)
        }
    }
    
    deinit {
        cancelRequest()
    }
}

extension DonationItemCellController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.configure(with: viewModel, role: role)
        cell?.onReuse = { [weak self] in
            self?.releaseCellForReuse()
        }
        cell?.setAnimatedSkeletonView(false)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.cell = cell as? DonationItemListCell
        self.cell?.itemImageView.image = image
        requestImage()
    }
}

extension DonationItemCellController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        requestImage()
    }
}

extension DonationItemCellController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selection((viewModel.detailId, role))
    }
}

extension DonationItemCellController: ResourceView, ResourceLoadingView, ResourceErrorView {
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
        self.image = .boxThumbnailSmall
    }
}
