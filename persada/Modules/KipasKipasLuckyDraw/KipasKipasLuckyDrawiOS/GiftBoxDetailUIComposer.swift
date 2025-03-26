import UIKit
import KipasKipasShared
import KipasKipasLuckyDraw

public enum GiftBoxDetailUIComposer {

    public struct Parameter {
        let viewModel: GiftBoxViewModel
        
        public init(viewModel: GiftBoxViewModel) {
            self.viewModel = viewModel
        }
    }
    
    public struct Loader {
        let followLoader: GiftBoxOwnerFollowLoader
        let joinLoader: GiftBoxJoinLoader
        let detailLoader: GiftBoxDetailLoader
        
        public init(
            followLoader: GiftBoxOwnerFollowLoader,
            joinLoader: GiftBoxJoinLoader,
            detailLoader: GiftBoxDetailLoader
        ) {
            self.followLoader = followLoader
            self.joinLoader = joinLoader
            self.detailLoader = detailLoader
        }
    }
    
    public struct Callback {
        let showPrizeClaimStatus: Closure<GiftBoxViewModel>
        
        public init(showPrizeClaimStatus: @escaping Closure<GiftBoxViewModel>) {
            self.showPrizeClaimStatus = showPrizeClaimStatus
        }
    }
    
    // MARK: Composer
    public static func composeWith(
        parameter: Parameter,
        loader: Loader,
        callback: Callback
    ) -> UIViewController {
        
        let controller = GiftBoxDetailViewController(viewModel: parameter.viewModel)
        let viewAdapter = controller.viewAdapter
        
        let followAdapter = GiftBoxOwnerFollowPresentationAdapter.create(
            with: viewAdapter.ownerFollow,
            loader: loader.followLoader
        )
        let joinAdapter = GiftBoxJoinPresentationAdapter.create(
            with: viewAdapter.join,
            loader: loader.joinLoader
        )
        let detailAdapter = GiftBoxDetailPresentationAdapter.create(
            with: viewAdapter.detail,
            loader: loader.detailLoader
        )

        controller.onFollow = followAdapter.loadResource
        controller.onJoin = joinAdapter.loadResource
        
        viewAdapter.join.onJoined = detailAdapter.loadResource
        viewAdapter.detail.showPrizeClaimStatus = callback.showPrizeClaimStatus
        
        return controller
    }
}
