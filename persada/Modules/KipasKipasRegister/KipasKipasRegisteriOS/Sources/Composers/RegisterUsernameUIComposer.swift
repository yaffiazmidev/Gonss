import UIKit
import KipasKipasShared
import KipasKipasRegister

public enum RegisterUsernameUIComposer {
    
    public static func composeWith(
        loader: @escaping RegisterAccountAvailabilityLoader.LoadPublisher
    ) -> StepsController {
        let viewController = RegisterUsernameViewController()
     
        let viewAdapter = RegisterAccountAvailabilityViewAdapter(
            publisher: loader,
            loadingView: viewController,
            errorView: viewController
        )
        
        viewAdapter.didCheckAvailability = viewController.display
        viewController.checkAvailability = viewAdapter.checkAvailability
        
        return viewController
    }
}
