import UIKit
import KipasKipasShared
import KipasKipasResetPassword

public typealias ResetPasswordLoginLoader = AnyResourceLoader<ResetPasswordLoginParam, ResetPasswordLoginResponse>

enum ResetPasswordLoginPresentationAdapter<View: ResourceView> where View.ResourceViewModel == ResetPasswordLoginResponse {
    
    typealias PresentationAdapter = LoadResourcePresentationAdapter<ResetPasswordLoginLoader, View>
    typealias Presenter = LoadResourcePresenter<ResetPasswordLoginResponse, View>
    
    static func create(
        publisher: @escaping ResetPasswordLoginLoader.LoadPublisher,
        view: View,
        loadingView: ResourceLoadingView,
        errorView: ResourceErrorView
    ) -> PresentationAdapter {
        let loader = ResetPasswordLoginLoader(publisher: publisher)
        let presentationAdapter = PresentationAdapter(loader: loader)
        let presenter = Presenter(
            view: view,
            loadingView: loadingView,
            errorView: errorView,
            transformer: { $0 }
        )
        presentationAdapter.presenter = presenter
        return presentationAdapter
    }
}
