import UIKit
import KipasKipasLogin
import KipasKipasShared

public enum LoginOTPRequestUIComposer {
    
    public struct Callback {
        let onSuccessRequestOTP: Closure<(Phone, TimeInterval)>
        
        public init(
            onSuccessRequestOTP: @escaping Closure<(Phone, TimeInterval)>
        ) {
            self.onSuccessRequestOTP = onSuccessRequestOTP
        }
    }
    
    public static func composeWith(
        publisher: @escaping LoginOTPRequestLoader.LoadPublisher,
        callbacks: Callback
    ) -> UIViewController {
        
        let viewController = LoginOTPRequestViewController()
        let viewAdapter = LoginRequestOTPPresentationAdapter.create(
            publisher: publisher,
            view: viewController,
            loadingView: viewController,
            errorView: viewController
        )
        
        viewController.requestOTP = viewAdapter.loadResource
        viewController.onSuccessRequestOTP = callbacks.onSuccessRequestOTP
        
        return viewController
    }
}
