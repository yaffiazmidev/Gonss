import UIKit
import KipasKipasShared
import KipasKipasLuckyDraw

final class GiftBoxDetailViewAdapter: ResourceView, ResourceLoadingView {
    
    private weak var controller: GiftBoxDetailViewController?
    
    var showPrizeClaimStatus: Closure<GiftBoxViewModel>?
    
    init(controller: GiftBoxDetailViewController) {
        self.controller = controller
    }
    
    func display(view viewModel: GiftBoxViewModel) {
        controller?.setButtonState(viewModel.isJoined ? .joined : .join)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.controller?.forceDismiss { [weak self] in
                self?.showPrizeClaimStatus?(viewModel)
            }
        }
    }
    
    func display(loading loadingViewModel: ResourceLoadingViewModel) {
        controller?.setButtonState(.join, isLoading: loadingViewModel.isLoading)
    }
}
