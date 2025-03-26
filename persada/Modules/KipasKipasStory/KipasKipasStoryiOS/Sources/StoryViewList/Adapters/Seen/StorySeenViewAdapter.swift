import KipasKipasShared
import KipasKipasStory

final class StorySeenViewAdapter: ResourceView, ResourceErrorView {
    
    var storySeen: Closure<Error?>?
    
    func display(view viewModel: StoryEmptyData) {
        if viewModel.code == "1002" {
            storySeen?(nil)
        }
    }
    
    func display(error errorViewModel: ResourceErrorViewModel) {
        storySeen?(errorViewModel.error)
    }
}
