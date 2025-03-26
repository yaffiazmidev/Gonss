import Foundation

public struct LiveRoomSummaryViewModel {
    public let duration: TimeInterval
    public let likesCount: Int
    public let viewersCount: Int
    public let streamId: String
    
    public init(duration: TimeInterval, likesCount: Int, viewersCount: Int, streamId: String) {
        self.duration = duration
        self.likesCount = likesCount
        self.viewersCount = viewersCount
        self.streamId = streamId
    }
}
