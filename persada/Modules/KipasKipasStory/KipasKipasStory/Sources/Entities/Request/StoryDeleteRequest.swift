import Foundation

public struct StoryDeleteRequest {
    public let id: String
    public let feedId: String
    
    public init(id: String, feedId: String) {
        self.id = id
        self.feedId = feedId
    }
}
