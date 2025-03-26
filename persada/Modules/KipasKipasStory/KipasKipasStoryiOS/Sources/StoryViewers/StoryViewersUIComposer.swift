import UIKit
import KipasKipasStory
import KipasKipasShared

public enum StoryViewersUIComposer {
    
    public struct Parameter {
        let storyId: String
        
        public init(storyId: String) {
            self.storyId = storyId
        }
    }
    
    public struct Loader {
        let viewersLoader: StoryViewersLoader
        let followLoader: StoryFollowLoader
        
        public init(
            viewersLoader: StoryViewersLoader,
            followLoader: StoryFollowLoader
        ) {
            self.viewersLoader = viewersLoader
            self.followLoader = followLoader
        }
    }
    
    public struct Callback {
        let didDeleteStory: EmptyClosure
        let showProfile: Closure<String>
        let sendMessage: Closure<String>
        
        public init(
            didDeleteStory: @escaping EmptyClosure,
            showProfile: @escaping Closure<String>,
            sendMessage: @escaping Closure<String>
        ) {
            self.didDeleteStory = didDeleteStory
            self.showProfile = showProfile
            self.sendMessage = sendMessage
        }
    }
    
    public static func composeWith(
        parameter: Parameter,
        loader: Loader,
        callback: Callback
    ) -> UIViewController {
        let controller = StoryViewersViewController()
        
        let viewersAdapter = StoryViewersPresentationAdapter(
            view: controller.viewAdapter
        ).create(with: loader.viewersLoader)
        
        let followAdapter = StoryFollowPresentationAdapter(
            view: controller.followAdapter
        ).create(with: loader.followLoader)
        
        controller.onViewWillAppear = { [viewersAdapter] in
            viewersAdapter.loadResource(with: .init(
                storyId: parameter.storyId,
                page: 0
            ))
        }
        
        controller.deleteStory = callback.didDeleteStory
    
        controller.viewAdapter.follow = followAdapter.loadResource
        controller.viewAdapter.showProfile = callback.showProfile
        controller.viewAdapter.sendMessage = callback.sendMessage
        
        return controller
    }
}
