import UIKit
import KipasKipasResetPassword
import KipasKipasShared

public struct ResetPasswordParameter {
    public let type: ResetPasswordType
    public let countdown: TimeInterval
}

public enum ResetPasswordPhoneUIComposer {
    
    public struct Callback {
        let onSuccessRequestOTP: Closure<ResetPasswordParameter>
        
        public init(onSuccessRequestOTP: @escaping Closure<ResetPasswordParameter>) {
            self.onSuccessRequestOTP = onSuccessRequestOTP
        }
    }
    
    public static func composeWith(
        loader: @escaping ResetPasswordOTPRequestLoader.LoadPublisher,
        callbacks: Callback
    ) -> UIViewController {
        
        let viewController = ResetPasswordPhoneViewController()
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
