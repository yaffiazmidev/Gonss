import KipasKipasShared
import KipasKipasStory

final class StoryLikeViewAdapter: ResourceView, ResourceErrorView {
    
    var storyLiked: Closure<Error?>?
    
    func display(view viewModel: StoryEmptyData) {
        if viewModel.code == "1000" {
            storyLiked?(nil)
        }
    }
    
    func display(error errorViewModel: ResourceErrorViewModel) {
        storyLiked?(errorViewModel.error)
    }
}
