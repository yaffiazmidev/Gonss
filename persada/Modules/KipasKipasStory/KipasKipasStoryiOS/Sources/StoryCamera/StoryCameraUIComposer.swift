import UIKit
import KipasKipasShared

public enum StoryCameraUIComposer {
    
    public struct Callback {
        let didPostStory: Closure<KKMediaItem>
        
        public init(didPostStory: @escaping Closure<KKMediaItem>) {
            self.didPostStory = didPostStory
        }
    }
    
    public static func compose(
        profilePhoto: String,
        callback: Callback
    ) -> UIViewController {
        let controller = StoryCameraViewController(profilePhoto: profilePhoto)
        controller.didPostStory = callback.didPostStory
        return controller
    }
}
