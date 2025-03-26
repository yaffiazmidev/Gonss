import KipasKipasShared
import KipasKipasStory

final class StoryDeleteViewAdapter: ResourceView, ResourceErrorView {
    
    var storyDeleted: Closure<Error?>?
    
    func display(view viewModel: StoryEmptyData) {
        if viewModel.code == "1000" {
            storyDeleted?(nil)
        }
    }
    
    func display(error errorViewModel: ResourceErrorViewModel) {
        storyDeleted?(errorViewModel.error)
    }
}
