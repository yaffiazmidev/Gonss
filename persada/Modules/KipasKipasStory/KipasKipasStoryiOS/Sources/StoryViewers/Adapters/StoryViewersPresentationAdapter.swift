import KipasKipasShared
import KipasKipasStory

public typealias StoryViewersLoader = AnyResourceLoader<StoryViewerRequest, StoryViewersResponse>

struct StoryViewersPresentationAdapter<View: ResourceView> where View.ResourceViewModel == StoryViewerPagingViewModel {
    
    typealias Adapter = LoadResourcePresentationAdapter<StoryViewersLoader, View>
    typealias Presenter = LoadResourcePresenter<StoryViewersResponse, View>
    
    private let view: View
    
    init(view: View) {
        self.view = view
    }
    
    func create(with loader: StoryViewersLoader) -> Adapter {
        let adapter = Adapter(loader: loader)
        adapter.presenter = Presenter(
            view: view,
            transformer: map
        )
        return adapter
    }
    
    private func map(_ response: StoryViewersResponse) -> StoryViewerPagingViewModel {
        
        let data = response.data
        let viewers: [StoryViewerViewModel] = data.content.compactMap {
            return StoryViewerViewModel(
                accountId: $0.id,
                name: $0.name ?? "-",
                photoURL: URL(string: $0.photo ?? ""),
                isLiked: $0.isLike == true,
                isVerified: $0.isVerified == true,
                isFollow: $0.isFollow == true,
                isFollowed: $0.isFollowed == true
            )
        }
        
        return StoryViewerPagingViewModel(
            viewers: viewers,
            page: data.pageable.pageNumber,
            totalPages: data.totalPages,
            isFirstPage: data.first,
            isLastPage: data.last
        )
    }
}
