import UIKit
import KipasKipasRegister
import KipasKipasShared

public enum RegisterPhotoUIComposer {
    
    public struct Parameter {
        fileprivate let referralCode: String
        
        public init(referralCode: String) {
            self.referralCode = referralCode
        }
    }
    
    public struct Callback {
        fileprivate let onRegistrationSuccess: (RegisterResponse) -> Void
        
        public init(onRegistrationSuccess: @escaping (RegisterResponse) -> Void) {
            self.onRegistrationSuccess = onRegistrationSuccess
        }
    }
    
    private static var viewAdapter = RegisterViewAdapter()
    
    public static func composeWith(
        parameter: Parameter,
        callback: Callback,
        uploadPublisher: @escaping RegisterPhotoUploader.LoadPublisher,
        registerLoadPublisher: @escaping RegisterLoader.LoadPublisher
    ) -> StepsController {
        
        let viewController = RegisterPhotoViewController(referralCode: parameter.referralCode)
       
        let photoPresentationAdapter = RegisterPhotoPresentationAdapter.create(
            publisher: uploadPublisher,
            view: viewController
        )
        
        viewAdapter.delegate = viewController
        
        let registerPresentationAdapter = RegisterPresentationAdapter.create(
            publisher: registerLoadPublisher,
            view: viewAdapter,
            loadingView: viewController,
            errorView: viewAdapter
        )
        
        viewController.uploadPhoto = photoPresentationAdapter.loadResource
        
        viewController.submitRegistration = registerPresentationAdapter.loadResource
        viewController.onRegistrationSuccess = callback.onRegistrationSuccess
        
        return viewController
    }
}
