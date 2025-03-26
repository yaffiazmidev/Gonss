import UIKit
import KipasKipasShared
import KipasKipasRegister

public enum RegisterVerifyOTPUIComposer {
    
    public static func composeWith(
        requestOTPLoader: @escaping RegisterRequestOTPLoader.LoadPublisher,
        verifyOTPLoader: @escaping RegisterVerifyOTPLoader.LoadPublisher
    ) -> StepsController {
        
        let requestOTPController = RequestOTPViewAdapter()
        let viewController = RegisterVerifyOTPViewController(
            requestOTPController: requestOTPController
        )
        let verifyOTPAdapter = RegisterVerifyOTPPresentationAdapter.create(
            publisher: verifyOTPLoader,
            controller: viewController
        )
        
        let requestOTPAdapter = RegisterRequestOTPPresentationAdapter.create(
            publisher: requestOTPLoader,
            view: requestOTPController,
            loadingView: viewController,
            errorView: viewController
        )
        
        viewController.resendOTP = requestOTPAdapter.loadResource
        viewController.verifyOTP = verifyOTPAdapter.loadResource
        
        return viewController
    }
}
