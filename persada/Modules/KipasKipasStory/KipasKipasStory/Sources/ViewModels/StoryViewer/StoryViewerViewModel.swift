import Foundation

public struct StoryViewerViewModel {
    public let accountId: String
    public let name: String
    public let photoURL: URL?
    public let isLiked: Bool
    public let isVerified: Bool
    public var isFollow: Bool
    public let isFollowed: Bool
    
    public init(
        accountId: String,
        name: String,
        photoURL: URL?,
        isLiked: Bool,
        isVerified: Bool,
        isFollow: Bool,
        isFollowed: Bool
    ) {
        self.accountId = accountId
        self.name = name
        self.photoURL = photoURL
        self.isLiked = isLiked
        self.isVerified = isVerified
        self.isFollow = isFollow
        self.isFollowed = isFollowed
    }
}

public extension StoryViewerViewModel {
    enum AccountState {
        case follow
        case message
    }
    
    var accountState: AccountState {
        switch(isFollow, isFollowed) {
        case (false, false): .follow
        case (true, false): .message
        case (false, true): .follow
        case (true, true): .message
        }
    }
}
