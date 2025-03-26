import UIKit
import KipasKipasShared
import KipasKipasRegister

public enum RegisterEmailUIComposer {
    
    public struct Callback {
        let onAccountAvailable: Closure<String>
        let onAccountNotAvailable: Closure<String>
        
        public init(
            onAccountAvailable: @escaping Closure<String>,
            onAccountNotAvailable: @escaping Closure<String>
        ) {
            self.onAccountAvailable = onAccountAvailable
            self.onAccountNotAvailable = onAccountNotAvailable
        }
    }
    
    public static func composeWith(
        loader: @escaping RegisterAccountAvailabilityLoader.LoadPublisher,
        callbacks: Callback
    ) -> UIViewController {
        let viewController = RegisterEmailViewController()
     
        let viewAdapter = RegisterAccountAvailabilityViewAdapter(
            publisher: loader,
            loadingView: viewController,
            errorView: viewController
        )
        viewAdapter.didCheckAvailability = viewController.display
        
        viewController.checkAvailability = viewAdapter.checkAvailability
        viewController.onAccountAvailable = callbacks.onAccountAvailable
        viewController.onAccountNotAvailable = callbacks.onAccountNotAvailable
        
        return viewController
    }
}
