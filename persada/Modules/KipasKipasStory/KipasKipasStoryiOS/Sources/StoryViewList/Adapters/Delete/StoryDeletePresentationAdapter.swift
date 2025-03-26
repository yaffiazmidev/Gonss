import KipasKipasShared
import KipasKipasStory

public typealias StoryDeleteLoader = AnyResourceLoader<StoryDeleteRequest, StoryEmptyData>

struct StoryDeletePresentationAdapter<View: ResourceView> where View.ResourceViewModel == StoryEmptyData {
    
    typealias Adapter = LoadResourcePresentationAdapter<StoryDeleteLoader, View>
    typealias Presenter = LoadResourcePresenter<StoryEmptyData, View>
    
    private let view: View
    
    init(view: View) {
        self.view = view
    }
    
    func create(with loader: StoryDeleteLoader) -> Adapter {
        let adapter = Adapter(loader: loader)
        adapter.presenter = Presenter(
            view: view,
            transformer: { $0 }
        )
        return adapter
    }
}
