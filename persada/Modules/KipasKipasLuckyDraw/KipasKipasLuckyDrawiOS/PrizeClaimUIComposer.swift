import UIKit
import KipasKipasShared
import KipasKipasLuckyDraw

public enum PrizeClaimUIComposer {
    
    public struct Parameter {
        let selfAccountId: String
        let viewModel: GiftBoxViewModel
        
        public init(
            selfAccountId: String,
            viewModel: GiftBoxViewModel
        ) {
            self.selfAccountId = selfAccountId
            self.viewModel = viewModel
        }
    }
    
    public static func composeWith(
        parameter: Parameter
    ) -> UIViewController {
        let controller = PrizeClaimViewController(
            selfAccountId: parameter.selfAccountId,
            viewModel: parameter.viewModel
        )
        return controller
    }
}
