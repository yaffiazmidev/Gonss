import UIKit
import KipasKipasDonateStuff
import KipasKipasShared

public enum DonationItemPaymentUIComposer {
    
    public struct Parameter {
        let orderId: String
        
        public init(orderId: String) {
            self.orderId = orderId
        }
    }
    
    public struct Action {
        let showInitiatorProfile: Closure<String>
        
        public init(showInitiatorProfile: @escaping Closure<String>) {
            self.showInitiatorProfile = showInitiatorProfile
        }
    }
    
    public static func composeWith(
        loader: @escaping DonationItemPaymentLoader.LoadPublisher,
        imageLoader: ImageResourceLoader,
        parameter: Parameter,
        action: Action
    ) -> UIViewController {
        
        let viewController = DonationItemPaymentViewController(
            viewAdapter: .init(
                imageLoader: imageLoader,
                showInitiatorProfile: action.showInitiatorProfile
            )
        )
        
        let adapter = DonationItemPaymentPresentationAdapter<DonationItemPaymentViewAdapter>(
            loader: .init(publisher: loader)
        )

        adapter.presenter = LoadResourcePresenter(
            view: viewController.viewAdapter,
            loadingView: viewController.viewAdapter,
            errorView: viewController,
            transformer: DonationItemPaymentMapper.map
        )
        
        viewController.onRefresh = { [adapter, parameter] in
            adapter.loadResource(with: parameter.orderId)
        }
        
        return viewController
    }
}
