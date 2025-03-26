import Foundation

public struct StoryItemViewModel: Equatable {
    public let id: String
    public let feedId: String
    public let repostId: String?
    public let repostOwnerUsername: String?
    public let firstViewerAccountId: String?
    public let firstViewerPhoto: String?
    public let secondViewerAccountId: String?
    public let secondViewerPhoto: String?
    public let totalView: Int
    public let type: StoryItemType
    public let media: StoryItemMediaViewModel
    public let createAt: Int
    public var isViewed: Bool
    public var isLiked: Bool
    public let perspective: StoryPerspective
    public let account: StoryAccountViewModel
    
    public init(
        id: String,
        feedId: String,
        repostId: String?,
        repostOwnerUsername: String?,
        firstViewerAccountId: String?,
        firstViewerPhoto: String?,
        secondViewerAccountId: String?,
        secondViewerPhoto: String?,
        totalView: Int,
        type: StoryItemType,
        media: StoryItemMediaViewModel,
        createAt: Int,
        isViewed: Bool,
        isLiked: Bool,
        perspective: StoryPerspective,
        account: StoryAccountViewModel
    ) {
        self.id = id
        self.feedId = feedId
        self.repostId = repostId
        self.repostOwnerUsername = repostOwnerUsername
        self.firstViewerAccountId = firstViewerAccountId
        self.firstViewerPhoto = firstViewerPhoto
        self.secondViewerAccountId = secondViewerAccountId
        self.secondViewerPhoto = secondViewerPhoto
        self.totalView = totalView
        self.type = type
        self.media = media
        self.createAt = createAt
        self.isViewed = isViewed
        self.isLiked = isLiked
        self.perspective = perspective
        self.account = account
    }
    
    public static func ==(lhs: StoryItemViewModel, rhs: StoryItemViewModel) -> Bool {
        return lhs.id == rhs.id
    }
}

public extension StoryItemViewModel {
    var createAtDesc: String {
        let secondsInDay: Double = 86400
        let secondsInHour: Double = 3600
        let secondsInMinute: Double = 60
        
        let currentDate = Date()
        let epochDate = Date(timeIntervalSince1970: TimeInterval(createAt) / 1000.0)
        let interval = currentDate.timeIntervalSince(epochDate)
        
        let days = Int(interval / secondsInDay)
        let hours = Int((interval.truncatingRemainder(dividingBy: secondsInDay)) / secondsInHour)
        let minutes = Int((interval.truncatingRemainder(dividingBy: secondsInHour)) / secondsInMinute)
        let seconds = Int(interval.truncatingRemainder(dividingBy: secondsInMinute))
        
        if days > 0 {
            return "\(days) hari"
        } else if hours > 0 {
            return "\(hours) jam"
        } else if minutes > 0 {
            return "\(minutes) menit"
        } else {
            return "\(seconds) detik"
        }
    }
    
    var firstViewerPhotoURL: URL? {
        guard let photo = firstViewerPhoto else { return nil }
        return URL(string: photo)
    }
    
    var secondViewerPhotoURL: URL? {
        guard let photo = secondViewerPhoto else { return nil }
        return URL(string: photo)
    }
    
    var repostUsername: String {
        return "@" + (repostOwnerUsername ?? "user")
    }
}
