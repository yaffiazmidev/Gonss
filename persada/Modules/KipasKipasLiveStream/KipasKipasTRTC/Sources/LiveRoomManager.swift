import Foundation

public protocol LiveRoomDelegate: AnyObject {
    func onLiveStreamingEnded()
    func onLiveStreamingRealtimeAudiencesCount(_ count: String)
    func onLiveStreamingRealtimeLikesCount(_ count: String)
    func onLiveStreamingKickedByDoubleLogin()
    func onLiveStreamingCheckNetwork(buffer isBuffering: Bool)
    func onLiveStreamingPaused(paused isPaused: Bool)
}

public typealias LiveRoomSummary = (viewerCount: Int, likeCount: Int)
