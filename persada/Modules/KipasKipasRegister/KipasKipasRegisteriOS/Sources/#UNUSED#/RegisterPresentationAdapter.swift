import UIKit
import KipasKipasRegister
import KipasKipasShared

public typealias RegisterLoader = AnyResourceLoader<RegisterUserParam, RegisterResponse>

enum RegisterPresentationAdapter {
    
    typealias View = RegisterViewAdapter
    typealias PresentationAdapter = LoadResourcePresentationAdapter<RegisterLoader, View>
    typealias Presenter = LoadResourcePresenter<RegisterResponse, View>
    
    static func create(
        publisher: @escaping RegisterLoader.LoadPublisher,
        view: View,
        loadingView: ResourceLoadingView,
        errorView: ResourceErrorView
    ) -> PresentationAdapter {
        let loader = RegisterLoader(publisher: publisher)
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
