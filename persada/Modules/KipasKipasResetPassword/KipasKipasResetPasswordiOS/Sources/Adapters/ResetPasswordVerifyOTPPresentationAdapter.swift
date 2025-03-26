import UIKit
import KipasKipasShared
import KipasKipasResetPassword

public typealias ResetPasswordVerifyOTPLoader = AnyResourceLoader<ResetPasswordVerifyOTPParam, ResetPasswordVerifyOTPData>

enum ResetPasswordVerifyOTPPresentationAdapter<View: ResourceView> where View.ResourceViewModel == ResetPasswordVerifyOTPResponse {
    
    typealias PresentationAdapter = LoadResourcePresentationAdapter<ResetPasswordVerifyOTPLoader, View>
    typealias Presenter = LoadResourcePresenter<ResetPasswordVerifyOTPData, View>
        
    static func create(
        publisher: @escaping ResetPasswordVerifyOTPLoader.LoadPublisher,
        view: View,
        loadingView: ResourceLoadingView,
        errorView: ResourceErrorView
    ) -> PresentationAdapter {
        let loader = ResetPasswordVerifyOTPLoader(publisher: publisher)
        let presentationAdapter = PresentationAdapter(loader: loader)
        let presenter = Presenter(
            view: view,
            loadingView: loadingView,
            errorView: errorView,
            transformer: { $0.data }
        )
        presentationAdapter.presenter = presenter
        return presentationAdapter
    }
}
