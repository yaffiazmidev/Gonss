import Foundation

public struct NotificationFollowersContent {
    public let id: String
    public let name: String
    public let username: String
    public let photo: String
    public var isFollow: Bool
    public var isFollowed: Bool
    public let followedAt: Int
    public let isVerified: Bool
}

public struct NotificationFollowersItem {
    public let content: [NotificationFollowersContent]
    public var totalPages: Int?
}
