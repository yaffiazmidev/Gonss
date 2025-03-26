import KipasKipasShared
import KipasKipasStory

public typealias StoryFollowLoader = AnyResourceLoader<String, StoryEmptyData>

struct StoryFollowPresentationAdapter<View: ResourceView> where View.ResourceViewModel == StoryEmptyData {
    
    typealias Adapter = LoadResourcePresentationAdapter<StoryFollowLoader, View>
    typealias Presenter = LoadResourcePresenter<StoryEmptyData, View>
    
    private let view: View

    init(view: View) {
        self.view = view
    }
    
    func create(with loader: StoryFollowLoader) -> Adapter {
        let adapter = Adapter(loader: loader)
        adapter.presenter = Presenter(
            view: view,
            transformer: { $0 }
        )
        return adapter
    }
}
