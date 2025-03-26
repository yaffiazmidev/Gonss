import KipasKipasRegister
import KipasKipasShared

typealias RegisterLoader = AnyResourceLoader<RegisterUserParam, RegisterResponse>

final class RegisterViewAdapter: ResourceView, ResourceErrorView, ResourceLoadingView {
    
    typealias PresentationAdapter = LoadResourcePresentationAdapter<RegisterLoader, RegisterViewAdapter>
    typealias Presenter = LoadResourcePresenter<RegisterResponse, RegisterViewAdapter>
    
    private lazy var adapter: PresentationAdapter = {
        let loader = RegisterLoader(publisher: publisher)
        let presentationAdapter = PresentationAdapter(loader: loader)
        let presenter = Presenter(
            view: self,
            transformer: { $0 }
        )
        presentationAdapter.presenter = presenter
        return presentationAdapter
    }()
    
    private var onSuccessRegister: Closure<RegisterResponse>?
    private var onFailedRegister: Closure<ResourceErrorViewModel>?
    
    private let publisher: RegisterLoader.LoadPublisher
        
    init(publisher: @escaping RegisterLoader.LoadPublisher) {
        self.publisher = publisher
    }
    
    func display(view viewModel: RegisterResponse) {
        onSuccessRegister?(viewModel)
    }
    
    func display(error errorViewModel: ResourceErrorViewModel) {
        onFailedRegister?(errorViewModel)
    }
    
    func display(loading loadingViewModel: ResourceLoadingViewModel) {}
    
    func register(
        with param: RegisterUserParam,
        onSuccessRegister: @escaping Closure<RegisterResponse>,
        onFailedRegister: @escaping Closure<ResourceErrorViewModel>
    ) {
        self.onSuccessRegister = onSuccessRegister
        self.onFailedRegister = onFailedRegister
        
        adapter.loadResource(with: param)
    }
}
