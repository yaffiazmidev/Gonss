import KipasKipasDonateStuff
import KipasKipasShared

public typealias DonationItemDetailLoader = AnyResourceLoader<String, DonationItemDetailData>

enum DonationItemDetailPresentationAdapter<View: ResourceView> where View.ResourceViewModel == DonationItemDetailViewModel {
    
    typealias PresentationAdapter = LoadResourcePresentationAdapter<DonationItemDetailLoader, View>
    typealias Presenter = LoadResourcePresenter<DonationItemDetailData, View>
    
    static func create(
        publisher: @escaping DonationItemDetailLoader.LoadPublisher,
        view: View,
        loadingView: ResourceLoadingView,
        errorView: ResourceErrorView
    ) -> PresentationAdapter {
        let loader = DonationItemDetailLoader(publisher: publisher)
        let presentationAdapter = PresentationAdapter(loader: loader)
        let presenter = Presenter(
            view: view,
            loadingView: loadingView,
            errorView: errorView,
            transformer: { response in
                let viewModel: DonationItemDetailViewModel = map(response.data)
                return viewModel
            }
        )
        presentationAdapter.presenter = presenter
        return presentationAdapter
    }
    
    private static func map(_ detail: DonationItemDetail) -> DonationItemDetailViewModel {
        #warning("[BEKA] move this somewhere else")
        let resizeParameter = "?x-oss-process=image/format,jpg/interlace,1/resize,w_100"
        let resizeProductImage =  "?x-oss-process=image/format,jpg/interlace,1/resize,w_350"
        
        let images = detail.media?
            .filter { $0.type == "image" }
            .compactMap { ($0.url ?? "") + resizeProductImage }
        
        return DonationItemDetailViewModel(
            id: detail.id ?? "",
            productImages: images?.compactMap(DonationItemDetailImage.init) ?? [],
            info: .init(
                detailId: detail.id ?? "",
                donationId: detail.donationItemId ?? "",
                itemId: detail.productId ?? "",
                itemName: detail.productName ?? "-",
                itemImage: images?.first ?? "",
                itemPrice: detail.itemPrice ?? 0,
                itemTargetAmount: detail.targetQty ?? 0,
                itemCollectedAmount: detail.totalItemCollected ?? 0
            ),
            stakeholder: .init(
                supplierName: detail.sellerName ?? "",
                supplierImage: detail.sellerImage ?? "" + resizeParameter,
                initiatorName: detail.initiatorName ?? "",
                initiatorImage: detail.initiatorImage ?? "" + resizeParameter,
                shippingAddress: detail.shippingAddress ?? ""
            ),
            desc: .init(
                description: detail.description ?? "Tidak ada deskripsi produk"
            )
        )
    }
}
