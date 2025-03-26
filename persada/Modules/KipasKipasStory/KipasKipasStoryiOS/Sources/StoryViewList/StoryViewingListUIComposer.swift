import UIKit
import KipasKipasStory
import KipasKipasShared

public enum StoryViewingListUIComposer {
    
    public struct Parameter {
        let selectedId: String
        let viewModels: [StorySectionViewModel]
        
        public init(
            selectedId: String,
            viewModels: [StorySectionViewModel]
        ) {
            self.selectedId = selectedId
            self.viewModels = viewModels
        }
    }
    
    public struct Callback {
        let showListViewers: Closure<(StoryItemViewModel, EmptyClosure)>
        let showShareSheet: Closure<(StoryItemViewModel, EmptyClosure)>
        let showCameraGallery: EmptyClosure
        let showProfile: Closure<String>
        
        public init(
            showListViewers: @escaping Closure<(StoryItemViewModel, EmptyClosure)>,
            showShareSheet: @escaping Closure<(StoryItemViewModel, EmptyClosure)>,
            showCameraGallery: @escaping EmptyClosure,
            showProfile: @escaping Closure<String>
        ) {
            self.showListViewers = showListViewers
            self.showShareSheet = showShareSheet
            self.showCameraGallery = showCameraGallery
            self.showProfile = showProfile
        }
    }
    
    public struct Loader {
        let storySeenLoader: StorySeenLoader
        let storyLikeLoader: StoryLikeLoader
        let storyDeleteLoader: StoryDeleteLoader
        
        public init(
            storySeenLoader: StorySeenLoader,
            storyLikeLoader: StoryLikeLoader,
            storyDeleteLoader: StoryDeleteLoader
        ) {
            self.storySeenLoader = storySeenLoader
            self.storyLikeLoader = storyLikeLoader
            self.storyDeleteLoader = storyDeleteLoader
        }
    }
    
    public static func composeWith(
        parameter: Parameter,
        callback: Callback,
        loader: Loader
    ) -> UIViewController {
        let controller = StoryViewingListController(
            selectedId: parameter.selectedId,
            viewModels: parameter.viewModels
        )
        
        let seenAdapter = StorySeenPresentationAdapter(
            view: controller.seenAdapter
        ).create(with: loader.storySeenLoader)
        
        let likeAdapter = StoryLikePresentationAdapter(
            view: controller.likeAdapter
        ).create(with: loader.storyLikeLoader)
        
        let deleteAdapter = StoryDeletePresentationAdapter(
            view: controller.deleteAdapter
        ).create(with: loader.storyDeleteLoader)
        
        controller.showListViewers = callback.showListViewers
        controller.showShareSheet = callback.showShareSheet
        controller.showCamera = callback.showCameraGallery
        controller.showProfile = callback.showProfile
        
        controller.seenStory = seenAdapter.loadResource
        controller.likeStory = likeAdapter.loadResource
        controller.deleteStory = deleteAdapter.loadResource
        
        return controller
    }
}
