import UIKit
import KipasKipasShared
import KipasKipasDonateStuff

public enum DonationItemCheckoutUIComposer {
    
    public struct Parameter {
        let viewModel: DonationItemDetailViewModel
        let quantity: Int
        
        public init(
            viewModel: DonationItemDetailViewModel,
            quantity: Int
        ) {
            self.viewModel = viewModel
            self.quantity = quantity
        }
    }
    
    public struct Callback {
        let showTransactionList: EmptyClosure
        
        public init(showTransactionList: @escaping EmptyClosure) {
            self.showTransactionList = showTransactionList
        }
    }
    
    public static func composeWith(
        loader: DonationItemCheckoutLoader,
        imageLoader: ImageResourceLoader,
        parameter: Parameter,
        callback: Callback
    ) -> UIViewController {
        let viewController = DonationItemCheckoutViewController()
        viewController.title = "Checkout"
        
        let view = DonationItemCheckoutViewAdapter(
            imageLoader: imageLoader, 
            viewController: viewController,
            viewModel: parameter.viewModel,
            quantity: parameter.quantity
        )
        
        let adapter = DonationItemCheckoutPresentationAdapter(
            view: viewController,
            loadingView: viewController,
            errorView: viewController
        ).create(with: loader)
        
        
        viewController.onRefresh = view.display
        viewController.onTapCheckoutButton = { [adapter, parameter] in
            adapter.loadResource(
                with: .init(
                    donationItemId: parameter.viewModel.id,
                    qty: parameter.quantity
                )
            )
        }
        viewController.onSuccessCheckout = callback.showTransactionList
        
        return viewController
    }
}
