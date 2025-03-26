import Foundation

public struct DonationGlobalRankItem: Hashable {
    
    public enum StatusRank: String {
        case UP
        case DOWN
        case STAY
    }
    
    public let id: String
    public let rank: Int
    public let name: String
    public let username: String
    public let statusRank: StatusRank
    public let profileImageURL: String
    public let badgeURL: String
    public let isShowBadge: Bool
    public let donatedDescription: String
    
    public init(
        id: String,
        rank: Int,
        name: String,
        username: String,
        statusRank: StatusRank,
        profileImageURL: String,
        badgeURL: String,
        isShowBadge: Bool,
        donatedDescription: String
    ) {
        self.id = id
        self.rank = rank
        self.name = name
        self.username = username
        self.statusRank = statusRank
        self.profileImageURL = profileImageURL
        self.badgeURL = badgeURL
        self.isShowBadge = isShowBadge
        self.donatedDescription = donatedDescription
    }
    
    public static func ==(lhs: DonationGlobalRankItem, rhs: DonationGlobalRankItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

