import Foundation

public struct RemoteUserProfile: Codable {
    public var code: String?
    public var data: RemoteUserProfileData?
    public var message: String?
    
}

// MARK: - DataClass
public struct RemoteUserProfileData: Codable {
    public let id, username, name, bio: String?
    public let photo: String?
    public let birthDate, gender: String?
    public var isFollow: Bool?
    public let isSeleb: Bool?
    public let mobile, email, accountType: String?
    public let isVerified: Bool?
    public let note: String?
    public let isDisabled, isSeller: Bool?
    public let socialMedias: [RemoteUserProfileSocialMedia]?
    public var totalFollowers, totalFollowing, totalPost: Int?
    public let urlBadge: String?
    public let donationBadge: RemoteUserProfileDonationBadge?
    public let isShowBadge: Bool?
    public let referralCode: String?
    public let chatPrice: Int?
    public let totalFeedLikes: Int?
}

//    MARK: -
public struct RemoteAcountMutualData: Codable {
    public let isMutual: Bool
}

// MARK: - DonationBadge
public struct RemoteUserProfileDonationBadge: Codable {
    public let id, name: String?
    public let url: String?
    public let min, max, level: Int?
    public let isFlagUpdate: Bool?
    public let globalRank: Int?
    public let isShowBadge: Bool?
}

// MARK: - SocialMedia
public struct RemoteUserProfileSocialMedia: Codable {
    public let urlSocialMedia, socialMediaType: String?
}
