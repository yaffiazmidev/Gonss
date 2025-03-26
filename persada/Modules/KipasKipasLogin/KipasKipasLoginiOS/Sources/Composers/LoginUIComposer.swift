import UIKit
import Combine
import KipasKipasLogin
import KipasKipasShared

public enum LoginUIComposer {
    
    public struct Loader {
        let loginLoader: LoginLoader.LoadPublisher
        
        public init(
            loginLoader: @escaping LoginLoader.LoadPublisher
        ) {
            self.loginLoader = loginLoader
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
        account: String?,
        loaders: Loader,
        callbacks: Callback,
        delegate: LoginViewControllerDelegate
    ) -> UIViewController {
        
        let viewController = LoginViewController(account: account, delegate: delegate)
        let loginAdapter = LoginPresentationAdapter.create(
            publisher: loaders.loginLoader,
            view: viewController,
            loadingView: viewController,
            errorView: viewController
        )
       
        viewController.loginCallback = loginAdapter.loadResource
        viewController.onSuccessLogin = callbacks.onSuccessLogin
        viewController.onFailedLogin = callbacks.onFailedLogin
        
        return viewController
    }
}
