import KipasKipasShared
import KipasKipasStory

final class StoryFollowViewAdapter: ResourceView, ResourceErrorView {
    
    private let manager = StoryViewersManager.shared
    
    func display(view viewModel: StoryEmptyData) {
        if viewModel.code == "1000" {
            manager.finalizeFollow(true)
        }
    }
    
    func display(error errorViewModel: ResourceErrorViewModel) {
        manager.finalizeFollow(false)
    }
}
