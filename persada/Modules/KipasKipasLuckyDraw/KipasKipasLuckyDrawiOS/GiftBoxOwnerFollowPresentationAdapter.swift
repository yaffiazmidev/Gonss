import KipasKipasShared
import KipasKipasLuckyDraw

public typealias GiftBoxOwnerFollowLoader = AnyResourceLoader<Int, GiftBoxEmptyData>

struct GiftBoxOwnerFollowPresentationAdapter<View: ResourceView> where View.ResourceViewModel == GiftBoxEmptyData {
    
    typealias Adapter = LoadResourcePresentationAdapter<GiftBoxOwnerFollowLoader, View>
    typealias Presenter = LoadResourcePresenter<GiftBoxEmptyData, View>
    
    static func create(
        with view: View,
        loader: GiftBoxOwnerFollowLoader
    ) -> Adapter {
        let adapter = Adapter(loader: loader)
        adapter.presenter = Presenter(view: view)
        
        return adapter
    }
}
