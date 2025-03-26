import KipasKipasShared
import KipasKipasLuckyDraw

public typealias GiftBoxDetailLoader = AnyResourceLoader<Int, GiftBoxData>

struct GiftBoxDetailPresentationAdapter<View: ResourceView> where View.ResourceViewModel == GiftBoxViewModel {
    
    typealias Adapter = LoadResourcePresentationAdapter<GiftBoxDetailLoader, View>
    typealias Presenter = LoadResourcePresenter<GiftBoxData, View>
    
    static func create(
        with view: View,
        loader: GiftBoxDetailLoader
    ) -> Adapter {
        let adapter = Adapter(loader: loader)
        adapter.presenter = Presenter(
            view: view,
            transformer: { GiftBoxMapper.map($0.data) }
        )
        return adapter
    }
}
