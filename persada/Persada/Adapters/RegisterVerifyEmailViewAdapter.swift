import KipasKipasRegister
import KipasKipasShared
import KipasKipasNetworking

typealias RegisterVerifyEmailLoader = AnyResourceLoader<RegisterVerifyEmailParam, EmptyData>

final class RegisterVerifyEmailViewAdapter: ResourceView, ResourceErrorView, ResourceLoadingView {
    
    typealias PresentationAdapter = LoadResourcePresentationAdapter<RegisterVerifyEmailLoader, RegisterVerifyEmailViewAdapter>
    typealias Presenter = LoadResourcePresenter<EmptyData, RegisterVerifyEmailViewAdapter>
    
    private lazy var adapter: PresentationAdapter = {
        let loader = RegisterVerifyEmailLoader(publisher: publisher)
        let presentationAdapter = PresentationAdapter(loader: loader)
        let presenter = Presenter(
            view: self,
            transformer: { $0 }
        )
        presentationAdapter.presenter = presenter
        return presentationAdapter
    }()
    
    private var onSuccessVerifyEmail: Closure<Bool>?
    private var onFailedVerifyEmail: Closure<ResourceErrorViewModel>?
    
    private let publisher: RegisterVerifyEmailLoader.LoadPublisher
        
    init(publisher: @escaping RegisterVerifyEmailLoader.LoadPublisher) {
        self.publisher = publisher
    }
    
    func display(view viewModel: EmptyData) {
        onSuccessVerifyEmail?(viewModel.code == "1000")
    }
    
    func display(error errorViewModel: ResourceErrorViewModel) {
        onFailedVerifyEmail?(errorViewModel)
    }
    
    func display(loading loadingViewModel: ResourceLoadingViewModel) {}
    
    func verifyEmail(
        with param: RegisterVerifyEmailParam,
        onSuccessVerifyEmail: @escaping Closure<Bool>,
        onFailedVerifyEmail: @escaping Closure<ResourceErrorViewModel>
    ) {
        self.onSuccessVerifyEmail = onSuccessVerifyEmail
        self.onFailedVerifyEmail = onFailedVerifyEmail
        
        adapter.loadResource(with: param)
    }
}
