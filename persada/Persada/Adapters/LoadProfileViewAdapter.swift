import KipasKipasShared
import KipasKipasLogin

typealias LoginProfileLoader = AnyResourceLoader<String, LoginProfileData>

final class LoadProfileViewAdapter: ResourceView, ResourceErrorView, ResourceLoadingView {
    
    typealias PresentationAdapter = LoadResourcePresentationAdapter<LoginProfileLoader, LoadProfileViewAdapter>
    typealias Presenter = LoadResourcePresenter<LoginProfileData, LoadProfileViewAdapter>
    
    private let publisher: LoginProfileLoader.LoadPublisher
    
    private var onSuccessLoadProfile: Closure<LoginProfileResponse>?
    private var onFailedLoadProfile: Closure<ResourceErrorViewModel>?
    
    init(publisher: @escaping LoginProfileLoader.LoadPublisher) {
        self.publisher = publisher
    }
    
    private lazy var adapter: PresentationAdapter = {
        let loader = LoginProfileLoader(publisher: publisher)
        let presentationAdapter = PresentationAdapter(loader: loader)
        let presenter = Presenter(
            view: self,
            loadingView: self,
            errorView: self,
            transformer: { $0 }
        )
        
        presentationAdapter.presenter = presenter
        
        return presentationAdapter
    }()
    
    func display(view viewModel: LoginProfileData) {
        onSuccessLoadProfile?(viewModel.data)
    }
    
    func loadProfile(
        _ userId: String,
        onSuccessLoadProfile: @escaping Closure<LoginProfileResponse>,
        onFailedLoadProfile: @escaping Closure<ResourceErrorViewModel>
    ) {
        self.onSuccessLoadProfile = onSuccessLoadProfile
        self.onFailedLoadProfile = onFailedLoadProfile
        self.adapter.loadResource(with: userId)
    }
    
    func display(error errorViewModel: ResourceErrorViewModel) {
        self.onFailedLoadProfile?(errorViewModel)
    }
    
    func display(loading loadingViewModel: ResourceLoadingViewModel) {}
}
