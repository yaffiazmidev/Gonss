import UIKit
import KipasKipasLogin
import KipasKipasShared

public enum LoginWithOTPUIComposer {
    
    public struct Loader {
        let loginLoader: LoginLoader.LoadPublisher
        let otpRequestLoader: LoginOTPRequestLoader.LoadPublisher
        
        public init(
            loginLoader: @escaping LoginLoader.LoadPublisher,
            otpRequestLoader: @escaping LoginOTPRequestLoader.LoadPublisher
        ) {
            self.loginLoader = loginLoader
            self.otpRequestLoader = otpRequestLoader
        }
    }
    
    public struct Event {
        let onTapRegister: Closure<(Phone, String)>
        let didTapLoginWithPassword: Closure<Phone>
        
        public init(
            onTapRegister: @escaping Closure<(Phone, String)>,
            didTapLoginWithPassword: @escaping Closure<Phone>
        ) {
            self.onTapRegister = onTapRegister
            self.didTapLoginWithPassword = didTapLoginWithPassword
        }
    }
    
    public struct Callback {
        let onSuccessLogin: Closure<LoginResponse>
        
        public init(
            onSuccessLogin: @escaping Closure<LoginResponse>
        ) {
            self.onSuccessLogin = onSuccessLogin
        }
    }
    
    public struct Parameter {
        let phoneNumber: Phone
        let interval: TimeInterval
        
        public init(
            phoneNumber: Phone,
            interval: TimeInterval
        ) {
            self.phoneNumber = phoneNumber
            self.interval = interval
        }
    }
    
    public static func composeWith(
        loaders: Loader,
        parameter: Parameter,
        event: Event,
        callback: Callback
    ) -> UIViewController {
        
        let viewController = LoginWithOTPViewController(
            phoneNumber: parameter.phoneNumber,
            interval: parameter.interval, 
            requestOTPAdapter: .init()
        )
        
        let loginAdapter = LoginPresentationAdapter.create(
            publisher: loaders.loginLoader,
            view: viewController,
            loadingView: viewController,
            errorView: viewController
        )
                
        let requestOTPAdapter = LoginRequestOTPPresentationAdapter.create(
            publisher: loaders.otpRequestLoader,
            view: viewController.requestOTPAdapter,
            loadingView: viewController,
            errorView: viewController
        )
     
        viewController.onLoginWithOTP = loginAdapter.loadResource
        viewController.onResendOTP = requestOTPAdapter.loadResource
        
        viewController.onTapRegister = event.onTapRegister
        viewController.onSuccessLogin = callback.onSuccessLogin
        viewController.didTapLoginWithPassword = event.didTapLoginWithPassword
        
        return viewController
    }
}
