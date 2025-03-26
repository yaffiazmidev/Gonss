import Foundation

public struct StoryViewer: Codable {
    public let id: String
    public let username: String?
    public let name: String?
    public let photo: String?
    public let isLike: Bool?
    public let isVerified: Bool?
    public let isFollow: Bool?
    public let isFollowed: Bool?
    
    public init(
        id: String,
        username: String,
        name: String,
        photo: String,
        isLike: Bool,
        isVerified: Bool,
        isFollow: Bool,
        isFollowed: Bool
    ) {
        self.id = id
        self.username = username
        self.name = name
        self.photo = photo
        self.isLike = isLike
        self.isVerified = isVerified
        self.isFollow = isFollow
        self.isFollowed = isFollowed
    }
}
