import Foundation
public struct NotificationSuggestionAccountContent {
    public let content: [NotificationSuggestionAccountItem]
    public var totalPages: Int?
}

public struct NotificationSuggestionAccountItem {
    public let id: String
    public let username: String
    public let name: String
    public let photo: String
    public var isFollow: Bool
    public var isFollowed: Bool
    public let isVerified: Bool
    public var suggestId, suggestType: String
    public var firstId, firstName: String
    public var firstPhoto: String
    public var secondId, secondName, secondPhoto: String
    public var othersLike, followedAt: Int
}
