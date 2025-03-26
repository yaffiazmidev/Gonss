import UIKit
import KipasKipasRegister
import KipasKipasShared

public enum RegisterPhoneUIComposer {
    
    public struct Callback {
        let onSuccessRequestOTP: Closure<(String, Int)>
        let redirectToLoginWithOTP: Closure<String>
        
        public init(
            onSuccessRequestOTP: @escaping Closure<(String, Int)>,
            redirectToLoginWithOTP: @escaping Closure<String>
        ) {
            self.onSuccessRequestOTP = onSuccessRequestOTP
            self.redirectToLoginWithOTP = redirectToLoginWithOTP
        }
    }
    
    public static func composeWith(
        loader: @escaping RegisterRequestOTPLoader.LoadPublisher,
        callbacks: Callback
    ) -> UIViewController {
        
        let viewController = RegisterPhoneViewController()
        let requestOTPAdapter = RegisterRequestOTPPresentationAdapter.create(
            publisher: loader,
            view: viewController,
            loadingView: viewController,
            errorView: viewController
        )
        
        viewController.requestOTP = requestOTPAdapter.loadResource
        viewController.onSuccessRequestOTP = callbacks.onSuccessRequestOTP
        viewController.redirectToLoginWithOTP = callbacks.redirectToLoginWithOTP
        
        return viewController
    }
}
