import KipasKipasShared
import KipasKipasStory

public typealias StorySeenLoader = AnyResourceLoader<StorySeenRequest, StoryEmptyData>

struct StorySeenPresentationAdapter<View: ResourceView> where View.ResourceViewModel == StoryEmptyData {
    
    typealias  Adapter = LoadResourcePresentationAdapter<StorySeenLoader, View>
    typealias Presenter = LoadResourcePresenter<StoryEmptyData, View>
    
    private let view: View
    
    init(view: View) {
        self.view = view
    }
    
    func create(with loader: StorySeenLoader) -> Adapter {
        let adapter = Adapter(loader: loader)
        adapter.presenter = Presenter(
            view: view,
            transformer: { $0 }
        )
        return adapter
    }
}
