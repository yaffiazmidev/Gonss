import UIKit
import KipasKipasDonateStuff
import KipasKipasShared

public enum DonationItemListUIComposer {
    
    public struct Parameter {
        let postDonationId: String
        
        public init(postDonationId: String) {
            self.postDonationId = postDonationId
        }
    }
    
    public struct Action {
        let selection: Closure<(String, DonationItemRole)>
        
        public init(selection: @escaping Closure<(String, DonationItemRole)>) {
            self.selection = selection
        }
    }
    
    public static func composeWith(
        role: DonationItemRole,
        loader: @escaping DonationItemListLoader.LoadPublisher,
        imageLoader: ImageResourceLoader,
        parameter: Parameter,
        actions: Action
    ) -> UIViewController {
        
        let viewController = DonationItemListViewController(
            viewAdapter: .init(
                imageLoader: imageLoader,
                role: role,
                selection: actions.selection
            )
        )
        
        let adapter = DonationItemListPresentationAdapter.create(
            publisher: loader,
            view: viewController.listAdapter,
            loadingView: viewController.listAdapter,
            errorView: viewController
        )

        viewController.onRefresh = { [adapter, parameter] in
            adapter.loadResource(with: parameter.postDonationId)
        }
        
        return viewController
    }
}
