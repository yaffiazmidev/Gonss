import Foundation

public struct LiveDailyRankViewModel {
    public let userId: String
    public let imageURL: String?
    public let name: String
    public let isVerified: Bool
    public let totalLikes: String
    
    public init(
        userId: String,
        imageURL: String?,
        name: String,
        isVerified: Bool,
        totalLikes: String
    ) {
        self.userId = userId
        self.imageURL = imageURL
        self.name = name
        self.isVerified = isVerified
        self.totalLikes = totalLikes
    }
}
