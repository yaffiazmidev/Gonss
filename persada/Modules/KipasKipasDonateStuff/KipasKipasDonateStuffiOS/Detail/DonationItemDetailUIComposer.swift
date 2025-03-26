import UIKit
import KipasKipasDonateStuff
import KipasKipasShared

public enum DonationItemDetailUIComposer {
    
    public struct Parameter {
        let id: String
        let role: DonationItemRole
        
        public init(
            id: String,
            role: DonationItemRole
        ) {
            self.id = id
            self.role = role
        }
    }
    
    public struct Actions {
        let didTapDonateButton: Closure<(DonationItemDetailViewModel, Int)>
        
        public init(didTapDonateButton: @escaping Closure<(DonationItemDetailViewModel, Int)>) {
            self.didTapDonateButton = didTapDonateButton
        }
    }
    
    public static func composeWith(
        loader: @escaping DonationItemDetailLoader.LoadPublisher,
        imageLoader: ImageResourceLoader,
        parameter: Parameter,
        actions: Actions
    ) -> UIViewController {
        
        let viewController = DonationItemDetailViewController(
            role: parameter.role, 
            detailAdapter: .init(
                imageLoader: imageLoader,
                didDonate: actions.didTapDonateButton,
                role: parameter.role
            )
        )
        
        let adapter = DonationItemDetailPresentationAdapter.create(
            publisher: loader,
            view: viewController.detailAdapter,
            loadingView: viewController.detailAdapter,
            errorView: viewController
        )

        viewController.onRefresh = { [adapter, parameter] in
            adapter.loadResource(with: parameter.id)
        }
        
        return viewController
    }
}
