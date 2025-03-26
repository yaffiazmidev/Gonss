import Foundation

public struct StoryViewerRequest {
    public let storyId: String
    public let page: Int
    public let size: Int
    
    public init(
        storyId: String,
        page: Int,
        size: Int = 100
    ) {
        self.storyId = storyId
        self.page = page
        self.size = size
    }
}
