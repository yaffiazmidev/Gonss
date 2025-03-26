import UIKit
import KipasKipasRegister
import KipasKipasShared

public typealias RegisterAccountAvailabilityLoader = AnyResourceLoader<RegisterAccountAvailabilityParam, RegisterAccountAvailabilityResponse>

final class RegisterAccountAvailabilityViewAdapter: ResourceView {
    
    typealias PresentationAdapter = LoadResourcePresentationAdapter<RegisterAccountAvailabilityLoader, RegisterAccountAvailabilityViewAdapter>
    typealias Presenter = LoadResourcePresenter<RegisterAccountAvailabilityResponse, RegisterAccountAvailabilityViewAdapter>
    
    private lazy var adapter: PresentationAdapter = {
        let loader = RegisterAccountAvailabilityLoader(publisher: publisher)
        let presentationAdapter = PresentationAdapter(loader: loader)
        let presenter = Presenter(
            view: self,
            loadingView: loadingView,
            errorView: errorView,
            transformer: { .init(isExists: $0.data) }
        )
        presentationAdapter.presenter = presenter
        return presentationAdapter
    }()
    
    private let publisher: RegisterAccountAvailabilityLoader.LoadPublisher
    private let loadingView: ResourceLoadingView
    private let errorView: ResourceErrorView
    
    var didCheckAvailability: Closure<RegisterAccountAvailabilityViewModel>?
    
    init(
        publisher: @escaping RegisterAccountAvailabilityLoader.LoadPublisher,
        loadingView: ResourceLoadingView,
        errorView: ResourceErrorView
    ) {
        self.publisher = publisher
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    
    func display(view viewModel: RegisterAccountAvailabilityViewModel) {
        didCheckAvailability?(viewModel)
    }

    func checkAvailability(with param: RegisterAccountAvailabilityParam) {
        adapter.loadResource(with: param)
    }
}
