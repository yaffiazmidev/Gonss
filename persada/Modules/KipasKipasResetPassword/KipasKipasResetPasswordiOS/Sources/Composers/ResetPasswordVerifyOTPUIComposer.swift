import UIKit
import KipasKipasResetPassword
import KipasKipasShared

public enum ResetPasswordVerifyOTPUIComposer {
    
    public struct Loader {
        let verifyOTPLoader: ResetPasswordVerifyOTPLoader.LoadPublisher
        let requestOTPLoader: ResetPasswordOTPRequestLoader.LoadPublisher
        
        public init(
            verifyOTPLoader: @escaping ResetPasswordVerifyOTPLoader.LoadPublisher,
            requestOTPLoader: @escaping ResetPasswordOTPRequestLoader.LoadPublisher
        ) {
            self.verifyOTPLoader = verifyOTPLoader
            self.requestOTPLoader = requestOTPLoader
        }
    }
    
    public struct Callback {
        let onSuccessVerifyOTP: Closure<(ResetPasswordVerifyOTPResponse, ResetPasswordParameter)>
        
        public init(onSuccessVerifyOTP: @escaping Closure<(ResetPasswordVerifyOTPResponse, ResetPasswordParameter)>) {
            self.onSuccessVerifyOTP = onSuccessVerifyOTP
        }
    }
        
    public static func composeWith(
        loaders: Loader,
        parameter: ResetPasswordParameter,
        callback: Callback
    ) -> UIViewController {
        
        let viewController = ResetPasswordVerifyOTPViewController(
            parameter: parameter,
            requestOTPAdapter: .init()
        )
        
        let verifyOTPAdapter = ResetPasswordVerifyOTPPresentationAdapter.create(
            publisher: loaders.verifyOTPLoader,
            view: viewController,
            loadingView: viewController,
            errorView: viewController
        )
        
        let requestOTPAdapter = ResetPasswordRequestOTPPresentationAdapter.create(
            publisher: loaders.requestOTPLoader,
            view: viewController.requestOTPAdapter,
            loadingView: viewController,
            errorView: viewController
        )
       
        viewController.onVerifyOTP = verifyOTPAdapter.loadResource
        viewController.onResendOTP =  requestOTPAdapter.loadResource
        viewController.onSuccessVerifyOTP = callback.onSuccessVerifyOTP
        
        return viewController
    }
}
