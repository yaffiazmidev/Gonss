import UIKit
import KipasKipasLogin
import KipasKipasShared

public enum LoginPasswordUIComposer {
    
    public struct Event {
        let didTapForgotPassword: () -> Void
        
        public init(didTapForgotPassword: @escaping () -> Void) {
            self.didTapForgotPassword = didTapForgotPassword
        }
    }
    
    public struct Parameter {
        let phoneNumber: Phone
        
        public init(phoneNumber: Phone) {
            self.phoneNumber = phoneNumber
        }
    }
    
    public struct Callback {
        let onSuccessLogin: Closure<LoginResponse>
        let onFailedLogin: Closure<AnyError>
        
        public init(
            onSuccessLogin: @escaping Closure<LoginResponse>,
            onFailedLogin: @escaping Closure<AnyError>
        ) {
            self.onSuccessLogin = onSuccessLogin
            self.onFailedLogin = onFailedLogin
        }
    }
    
    
    public static func composeWith(
        loader: @escaping LoginLoader.LoadPublisher,
        parameter: Parameter,
        events: Event,
        callbacks: Callback
    ) -> UIViewController {
        let viewController = LoginPasswordViewController(phoneNumber: parameter.phoneNumber)
        
        let loginAdapter = LoginPresentationAdapter.create(
            publisher: loader,
            view: viewController,
            loadingView: viewController,
            errorView: viewController
        )
        
        viewController.login = loginAdapter.loadResource
        viewController.forgotPassword = events.didTapForgotPassword
        viewController.onSuccessLogin =  callbacks.onSuccessLogin
        viewController.onFailedLogin = callbacks.onFailedLogin
        
        return viewController
    }
}
