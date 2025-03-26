import UIKit
import KipasKipasShared
import KipasKipasLogin

public typealias LoginLoader = AnyResourceLoader<LoginRequestParam, LoginResponse>

enum LoginPresentationAdapter<View: ResourceView> where View.ResourceViewModel == LoginViewModel {
    
    typealias PresentationAdapter = LoadResourcePresentationAdapter<LoginLoader, View>
    typealias Presenter = LoadResourcePresenter<LoginResponse, View>

    static func create(
        publisher: @escaping LoginLoader.LoadPublisher,
        view: View,
        loadingView: ResourceLoadingView,
        errorView: ResourceErrorView
    ) -> PresentationAdapter {
        let loader = LoginLoader(publisher: publisher)
        let presentationAdapter = PresentationAdapter(loader: loader)
        let presenter = Presenter(
            view: view,
            loadingView: loadingView,
            errorView: errorView,
            transformer: { LoginViewModel(response: $0) }
        )
        presentationAdapter.presenter = presenter
        return presentationAdapter
    }
}
