import UIKit
import KipasKipasShared
import KipasKipasResetPassword

public typealias ResetPasswordLoader = AnyResourceLoader<ResetPasswordVerifyOTPResponse, ResetPasswordResponse>

enum ResetPasswordPresentationAdapter {
    
    typealias Controller = ResetPasswordViewController
    typealias PresentationAdapter = LoadResourcePresentationAdapter<ResetPasswordLoader, Controller>
    typealias Presenter = LoadResourcePresenter<ResetPasswordResponse, Controller>
    
    static func create(
        publisher: @escaping ResetPasswordLoader.LoadPublisher,
        controller: Controller
    ) -> PresentationAdapter {
        
        let loader = ResetPasswordLoader(publisher: publisher)
        let presentationAdapter = PresentationAdapter(loader: loader)
        let presenter = Presenter(
            view: controller,
            transformer: { ResetPasswordViewModel(code: $0.code) }
        )
        presentationAdapter.presenter = presenter
        return presentationAdapter
    }
}
