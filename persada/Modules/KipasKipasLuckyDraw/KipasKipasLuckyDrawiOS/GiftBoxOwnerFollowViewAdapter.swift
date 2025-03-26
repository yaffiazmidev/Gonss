import UIKit
import KipasKipasShared
import KipasKipasLuckyDraw

final class GiftBoxOwnerFollowViewAdapter: ResourceView, ResourceLoadingView, ResourceErrorView {
    
    private weak var controller: GiftBoxDetailViewController?
    
    init(controller: GiftBoxDetailViewController) {
        self.controller = controller
    }
    
    func display(view viewModel: GiftBoxEmptyData) {
        let isFollowed = viewModel.code == "1000"
        
        if isFollowed {
            controller?.setButtonState(.join)
            controller?.showToast("Jadilah pengikut dan ikuti undian hadiah")
        }
    }
    
    func display(loading loadingViewModel: ResourceLoadingViewModel) {
        controller?.setButtonState(
            .follow,
            isLoading: loadingViewModel.isLoading
        )
    }
    
    func display(error errorViewModel: ResourceErrorViewModel) {
        controller?.setButtonState(.follow)
        controller?.showToast("Terjadi kesalahan")
    }
}
