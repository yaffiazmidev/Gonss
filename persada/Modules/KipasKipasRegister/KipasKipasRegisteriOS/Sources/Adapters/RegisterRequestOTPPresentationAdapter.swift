import Combine
import KipasKipasRegister
import KipasKipasShared

public typealias RegisterRequestOTPLoader = AnyResourceLoader<RegisterRequestOTPParam, RegisterRequestOTPData>

struct RegisterRequestOTPPresentationAdapter<View: ResourceView> where View.ResourceViewModel == RegisterRequestOTPViewModel {
    
    typealias PresentationAdapter = LoadResourcePresentationAdapter<RegisterRequestOTPLoader, View>
    typealias Presenter = LoadResourcePresenter<RegisterRequestOTPData, View>
    
    static func create(
        publisher: @escaping RegisterRequestOTPLoader.LoadPublisher,
        view: View,
        loadingView: ResourceLoadingView,
        errorView: ResourceErrorView
    ) -> PresentationAdapter {
        let loader = RegisterRequestOTPLoader(publisher: publisher)
        let presentationAdapter = PresentationAdapter(loader: loader)
        let presenter = Presenter(
            view: view,
            loadingView: loadingView,
            errorView: errorView,
            transformer: { .init(
                countdownInterval: $0.data.expireInSecond ?? $0.data.tryInSecond ?? 0
            )}
        )
        presentationAdapter.presenter = presenter
        return presentationAdapter
    }
}
