import Foundation

public struct LiveUserProfile: Codable {
    public let id, username, name, bio: String?
    public let photo: String?
    public let birthDate, gender: String?
    public let isFollow, isSeleb: Bool?
    public let mobile, email, accountType: String?
    public let isVerified: Bool?
    public let note: String?
    public let isDisabled, isSeller: Bool?
    public let socialMedias: [SocialMedia]?
    public let totalFollowers, totalFollowing, totalPost: Int?
    public let urlBadge: String?
    public let donationBadge: DonationBadge?
    public let isShowBadge: Bool?
    public let referralCode: String?

    public init(id: String?, username: String?, name: String?, bio: String?, photo: String?, birthDate: String?, gender: String?, isFollow: Bool?, isSeleb: Bool?, mobile: String?, email: String?, accountType: String?, isVerified: Bool?, note: String?, isDisabled: Bool?, isSeller: Bool?, socialMedias: [SocialMedia]?, totalFollowers: Int?, totalFollowing: Int?, totalPost: Int?, urlBadge: String?, donationBadge: DonationBadge?, isShowBadge: Bool?, referralCode: String?) {
        self.id = id
        self.username = username
        self.name = name
        self.bio = bio
        self.photo = photo
        self.birthDate = birthDate
        self.gender = gender
        self.isFollow = isFollow
        self.isSeleb = isSeleb
        self.mobile = mobile
        self.email = email
        self.accountType = accountType
        self.isVerified = isVerified
        self.note = note
        self.isDisabled = isDisabled
        self.isSeller = isSeller
        self.socialMedias = socialMedias
        self.totalFollowers = totalFollowers
        self.totalFollowing = totalFollowing
        self.totalPost = totalPost
        self.urlBadge = urlBadge
        self.donationBadge = donationBadge
        self.isShowBadge = isShowBadge
        self.referralCode = referralCode
    }
}

// MARK: - DonationBadge
public struct DonationBadge: Codable {
    public let id, name: String?
    public let url: String?
    public let min, max, level: Int?
    public let isFlagUpdate: Bool?
    public let globalRank: Int?
    public let isShowBadge: Bool?

    public init(id: String?, name: String?, url: String?, min: Int?, max: Int?, level: Int?, isFlagUpdate: Bool?, globalRank: Int?, isShowBadge: Bool?) {
        self.id = id
        self.name = name
        self.url = url
        self.min = min
        self.max = max
        self.level = level
        self.isFlagUpdate = isFlagUpdate
        self.globalRank = globalRank
        self.isShowBadge = isShowBadge
    }
}

public struct SocialMedia: Codable {
    public let urlSocialMedia: String?
    public let socialMediaType: String?

    public init(urlSocialMedia: String?, socialMediaType: String?) {
        self.urlSocialMedia = urlSocialMedia
        self.socialMediaType = socialMediaType
    }
}
