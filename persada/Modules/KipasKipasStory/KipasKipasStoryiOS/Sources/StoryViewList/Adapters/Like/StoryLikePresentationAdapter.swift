import KipasKipasShared
import KipasKipasStory

public typealias StoryLikeLoader = AnyResourceLoader<StoryLikeRequest, StoryEmptyData>

struct StoryLikePresentationAdapter<View: ResourceView> where View.ResourceViewModel == StoryEmptyData {
    
    typealias  Adapter = LoadResourcePresentationAdapter<StoryLikeLoader, View>
    typealias Presenter = LoadResourcePresenter<StoryEmptyData, View>
    
    private let view: View
    
    init(view: View) {
        self.view = view
    }
    
    func create(with loader: StoryLikeLoader) -> Adapter {
        let adapter = Adapter(loader: loader)
        adapter.presenter = Presenter(
            view: view,
            transformer: { $0 }
        )
        return adapter
    }
}
