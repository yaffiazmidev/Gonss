import Foundation

public struct StorySeenRequest: Encodable {
    public let storyId: String
    
    public init(storyId: String) {
        self.storyId = storyId
    }
}
