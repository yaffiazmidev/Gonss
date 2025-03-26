import UIKit
import KipasKipasResetPassword
import KipasKipasShared

public enum ResetPasswordEmailUIComposer {
    
    public struct Callback {
        let onSuccessRequestOTP: Closure<ResetPasswordParameter>
        
        public init(
            onSuccessRequestOTP: @escaping Closure<ResetPasswordParameter>
        ) {
            self.onSuccessRequestOTP = onSuccessRequestOTP
        }
    }

    public static func composeWith(
        loader: @escaping ResetPasswordOTPRequestLoader.LoadPublisher,
        callbacks: Callback
    ) -> UIViewController {
        
        let viewController = ResetPasswordEmailViewController()
        let requestOTPAdapter = ResetPasswordRequestOTPPresentationAdapter.create(
            publisher: loader,
            view: viewController,
            loadingView: viewController,
            errorView: viewController
        )

        viewController.requestOTP = requestOTPAdapter.loadResource
        viewController.onSuccessRequestOTP = callbacks.onSuccessRequestOTP
        
        return viewController
    }
}
