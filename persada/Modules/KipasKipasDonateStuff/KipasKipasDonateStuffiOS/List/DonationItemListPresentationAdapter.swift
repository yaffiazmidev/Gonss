import UIKit
import KipasKipasDonateStuff
import KipasKipasShared

public typealias DonationItemListLoader = AnyResourceLoader<String, DonationItemData>

enum DonationItemListPresentationAdapter<View: ResourceView> where View.ResourceViewModel == DonationItemListViewModel {
    
    typealias PresentationAdapter = LoadResourcePresentationAdapter<DonationItemListLoader, View>
    typealias Presenter = LoadResourcePresenter<DonationItemData, View>

    static func create(
        publisher: @escaping DonationItemListLoader.LoadPublisher,
        view: View,
        loadingView: ResourceLoadingView,
        errorView: ResourceErrorView
    ) -> PresentationAdapter {
        let loader = DonationItemListLoader(publisher: publisher)
        let presentationAdapter = PresentationAdapter(loader: loader)
        let presenter = Presenter(
            view: view,
            loadingView: loadingView,
            errorView: errorView,
            transformer: { response in
                let viewModels: [DonationItemViewModel] = map(response.data)
                return DonationItemListViewModel(items: viewModels)
            }
        )
        presentationAdapter.presenter = presenter
        return presentationAdapter
    }
    
    private static func map(_ items: [DonationItem]) -> [DonationItemViewModel] {
        let viewModels: [DonationItemViewModel] = items.map { response in
            return DonationItemViewModel(
                detailId: response.id ?? "", 
                donationId: response.postDonationId ?? "",
                itemId: response.productId ?? "",
                itemName: response.productName ?? "",
                itemImage: response.productImage ?? "",
                itemPrice: response.itemPrice ?? 0,
                itemTargetAmount: response.targetQty ?? 0,
                itemCollectedAmount: response.totalItemCollected ?? 0
            )
        }
        return viewModels
    }
}
