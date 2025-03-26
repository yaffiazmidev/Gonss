import Foundation

public struct StoryAccountViewModel: Equatable {
    public let id: String
    public let username: String
    public let name: String
    public let photo: String
    public let isVerified: Bool
    
    public init(
        id: String,
        username: String,
        name: String,
        photo: String,
        isVerified: Bool
    ) {
        self.id = id
        self.username = username
        self.name = name
        self.photo = photo
        self.isVerified = isVerified
    }
}

public extension StoryAccountViewModel {
    var photoURL: URL? {
        return URL(string: photo)
    }
}
