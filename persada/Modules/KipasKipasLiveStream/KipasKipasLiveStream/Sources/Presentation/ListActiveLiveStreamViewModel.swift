import Foundation

public struct ListActiveLiveStreamContentViewModel {
    public let id: String
    public let roomId: String
    public let roomDescription: String
    public let anchorName: String
    public let anchorUserId: String
    public let anchorPhoto: String
    public let isFollowingAnchor: Bool
    public let isVerified: Bool
}

public struct ListActiveLiveStreamViewModel {
    public let page: Int
    public let totalPages: Int
    public let contents: [ListActiveLiveStreamContentViewModel]
}
