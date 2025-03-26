import Foundation

public struct StoryLikeRequest {
    
    public enum LikeStatus: String {
        case like
        case unlike
    }
    
    public let storyId: String
    public let likeStatus: LikeStatus
    
    public init(
        storyId: String,
        likeStatus: LikeStatus
    ) {
        self.storyId = storyId
        self.likeStatus = likeStatus
    }
}
