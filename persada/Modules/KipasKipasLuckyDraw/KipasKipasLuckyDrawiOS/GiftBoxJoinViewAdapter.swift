import UIKit
import KipasKipasShared
import KipasKipasLuckyDraw

final class GiftBoxJoinViewAdapter: ResourceView, ResourceLoadingView, ResourceErrorView {
    
    private weak var controller: GiftBoxDetailViewController?
    
    var onJoined: Closure<Int>?
    
    init(controller: GiftBoxDetailViewController) {
        self.controller = controller
    }
    
    func display(view viewModel: GiftBoxViewModel) {
        handleJoinGiftBox(viewModel)
    }
    
    func display(loading loadingViewModel: ResourceLoadingViewModel) {
        controller?.setButtonState(.join, isLoading: loadingViewModel.isLoading)
    }
    
    func display(error errorViewModel: ResourceErrorViewModel) {
        controller?.showToast("Terjadi kesalahan")
    }
    
    private func handleJoinGiftBox(_ viewModel: GiftBoxViewModel) {
        if viewModel.lotteryType == .drawWinner {
            onJoined?(viewModel.id)
        } else {
            controller?.setButtonState(viewModel.isJoined ? .joined : .join)
            /// Add a slight delay to see the button state change.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showToastAndDismiss("Berhasil berpartisipasi, menunggu hadiah")
            }
        }
    }
    
    private func showToastAndDismiss(_ message: String) {
        controller?.showToast(message)
        controller?.forceDismiss()
    }
}
