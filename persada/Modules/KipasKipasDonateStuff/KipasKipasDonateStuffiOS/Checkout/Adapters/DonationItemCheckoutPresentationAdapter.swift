import KipasKipasDonateStuff
import KipasKipasShared

public typealias DonationItemCheckoutLoader = AnyResourceLoader<DonationItemCheckoutRequest, DonationItemCheckoutData>

struct DonationItemCheckoutPresentationAdapter<View: ResourceView> where View.ResourceViewModel == DonationItemCheckout {
    
    typealias PresentationAdapter = LoadResourcePresentationAdapter<DonationItemCheckoutLoader, View>
    typealias Presenter = LoadResourcePresenter<DonationItemCheckoutLoader.Resource, View>
    
    private let view: View
    private let loadingView: ResourceLoadingView
    private let errorView: ResourceErrorView
    
    init(
        view: View,
        loadingView: ResourceLoadingView,
        errorView: ResourceErrorView
    ) {
        self.view = view
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    func create(with loader: DonationItemCheckoutLoader) -> PresentationAdapter {
        let adapter = PresentationAdapter(loader: loader)
        adapter.presenter = Presenter(
            view: view,
            loadingView: loadingView,
            errorView: errorView,
            transformer: { $0.data }
        )
        return adapter
    }
}
