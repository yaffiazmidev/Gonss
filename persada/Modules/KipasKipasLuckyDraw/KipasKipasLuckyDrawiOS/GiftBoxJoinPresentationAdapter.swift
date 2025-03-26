import KipasKipasShared
import KipasKipasLuckyDraw

public typealias GiftBoxJoinLoader = AnyResourceLoader<Int, GiftBoxData>

struct GiftBoxJoinPresentationAdapter<View: ResourceView> where View.ResourceViewModel == GiftBoxViewModel {
    
    typealias Adapter = LoadResourcePresentationAdapter<GiftBoxJoinLoader, View>
    typealias Presenter = LoadResourcePresenter<GiftBoxData, View>
    
    static func create(
        with view: View,
        loader: GiftBoxJoinLoader
    ) -> Adapter {
        let adapter = Adapter(loader: loader)
        adapter.presenter = Presenter(
            view: view,
            transformer: { GiftBoxMapper.map($0.data) }
        )
        return adapter
    }
}
