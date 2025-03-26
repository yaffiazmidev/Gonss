import UIKit
import KipasKipasResetPassword
import KipasKipasShared

public enum ResetPasswordUIComposer {
    
    public struct Loader {
        let resetPasswordLoader: ResetPasswordLoader.LoadPublisher
        let loginLoader: ResetPasswordLoginLoader.LoadPublisher
        
        public init(
            resetPasswordLoader: @escaping ResetPasswordLoader.LoadPublisher,
            loginLoader: @escaping ResetPasswordLoginLoader.LoadPublisher
        ) {
            self.resetPasswordLoader = resetPasswordLoader
            self.loginLoader = loginLoader
        }
    }
    
    public struct Callback {
        let onSuccessLogin: Closure<ResetPasswordLoginResponse>
        let onFailedLogin: () -> Void
        
        public init(
            onSuccessLogin: @escaping Closure<ResetPasswordLoginResponse>,
            onFailedLogin: @escaping () -> Void
        ) {
            self.onSuccessLogin = onSuccessLogin
            self.onFailedLogin = onFailedLogin
        }
    }
    
    public struct Parameter {
        let response: ResetPasswordVerifyOTPResponse
        let param: ResetPasswordParameter
        
        public init(
            response: ResetPasswordVerifyOTPResponse,
            param: ResetPasswordParameter
        ) {
            self.response = response
            self.param = param
        }
    }

    public static func composeWith(
        loaders: Loader,
        parameter: Parameter,
        callback: Callback
    ) -> UIViewController {
        
        let viewController = ResetPasswordViewController(
            parameter: parameter.param, 
            response: parameter.response
        )
        
        let resetpasswordAdapter = ResetPasswordPresentationAdapter.create(
            publisher: loaders.resetPasswordLoader,
            controller: viewController
        )
    
        let loginAdapter = ResetPasswordLoginPresentationAdapter.create(
            publisher: loaders.loginLoader,
            view: viewController.loginViewAdapter,
            loadingView: viewController,
            errorView: viewController.loginViewAdapter
        )
        
        viewController.onResetPassword = resetpasswordAdapter.loadResource
        viewController.onSuccessResetPassword = loginAdapter.loadResource
        viewController.onSuccessLogin = callback.onSuccessLogin
        viewController.onFailedLogin = callback.onFailedLogin
        
        return viewController
    }
}
