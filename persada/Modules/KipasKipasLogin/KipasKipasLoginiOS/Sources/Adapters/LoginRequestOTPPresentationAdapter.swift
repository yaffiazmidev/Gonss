import UIKit
import KipasKipasShared
import KipasKipasLogin

public typealias LoginOTPRequestLoader = AnyResourceLoader<LoginOTPRequestParam, LoginOTPRequestData>

enum LoginRequestOTPPresentationAdapter<View: ResourceView> where View.ResourceViewModel == LoginOTPRequestViewModel {
    
    typealias PresentationAdapter = LoadResourcePresentationAdapter<LoginOTPRequestLoader, View>
    typealias Presenter = LoadResourcePresenter<LoginOTPRequestData, View>

    static func create(
        publisher: @escaping LoginOTPRequestLoader.LoadPublisher,
        view: View,
        loadingView: ResourceLoadingView,
        errorView: ResourceErrorView
    ) -> PresentationAdapter {
        let loader = LoginOTPRequestLoader(publisher: publisher)
        let presentationAdapter = PresentationAdapter(loader: loader)
        let presenter = Presenter(
            view: view,
            loadingView: loadingView,
            errorView: errorView,
            transformer: { LoginOTPRequestViewModel(
                countdownInterval: TimeInterval($0.data.expireInSecond ?? $0.data.tryInSecond ?? 0)
            )}
        )
        presentationAdapter.presenter = presenter
        return presentationAdapter
    }
}
