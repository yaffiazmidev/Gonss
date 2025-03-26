import Foundation

public struct BadgeViewModel {
    public let id: String
    public let badgeName: String
    public let badgeURL: URL?
    public let isShowBadge: Bool
    public let isMyBadge: Bool
    public let badgeAmountRangeDescription: String
    public let isBadgeUnlocked: Bool
    public let badgeMessage: String
    public let highlightedBadgeMessageText: String
}
