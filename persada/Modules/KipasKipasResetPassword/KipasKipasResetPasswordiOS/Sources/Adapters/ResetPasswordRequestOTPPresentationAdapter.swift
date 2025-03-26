import UIKit
import KipasKipasShared
import KipasKipasResetPassword

public typealias ResetPasswordOTPRequestLoader = AnyResourceLoader<ResetPasswordRequestOTPParam, ResetPasswordOTPData>

enum ResetPasswordRequestOTPPresentationAdapter<View: ResourceView> where View.ResourceViewModel == ResetPasswordOTPRequestViewModel {
    
    typealias PresentationAdapter = LoadResourcePresentationAdapter<ResetPasswordOTPRequestLoader, View>
    typealias Presenter = LoadResourcePresenter<ResetPasswordOTPData, View>
    
    static func create(
        publisher: @escaping ResetPasswordOTPRequestLoader.LoadPublisher,
        view: View,
        loadingView: ResourceLoadingView,
        errorView: ResourceErrorView
    ) -> PresentationAdapter {
        let loader = ResetPasswordOTPRequestLoader(publisher: publisher)
        let presentationAdapter = PresentationAdapter(loader: loader)
        let presenter = Presenter(
            view: view,
            loadingView: loadingView,
            errorView: errorView,
            transformer: { ResetPasswordOTPRequestViewModel(
                countdownInterval: TimeInterval($0.data.expireInSecond ?? $0.data.tryInSecond ?? 0)
            )}
        )
        presentationAdapter.presenter = presenter
        return presentationAdapter
    }
}
