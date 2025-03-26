import Foundation

public struct LiveRoomActive: Codable {
    public let content: [Content]?
    public let pageable: Pageable?
    public let totalElements, totalPages: Int?
    public let last: Bool?
    public let sort: Sort?
    public let first: Bool?
    public let numberOfElements, size, number: Int?
    public let empty: Bool?
}

public struct Content: Codable {
    public let id, roomID, description: String?
    public let account: Account?

    enum CodingKeys: String, CodingKey {
        case id
        case roomID = "roomId"
        case description, account
    }
}

public struct Account: Codable {
    public let id, username, name, bio: String?
    public let photo, birthDate, gender: String?
    public let isFollow, isSeleb: Bool?
    public let mobile, email, accountType: String?
    public let isVerified: Bool?
    public let note: String?
    public let isDisabled, isSeller: Bool?
    public let totalDonation, levelBadge: Int?
    public let donationBadgeID, urlBadge, donationBadge: String?
    public let isShowBadge: Bool?
    public let referralCode: String?
    public let chatPrice: Double?

    enum CodingKeys: String, CodingKey {
        case id, username, name, bio, photo, birthDate, gender, isFollow, isSeleb, mobile, email, accountType, isVerified, note, isDisabled, isSeller, totalDonation, levelBadge
        case donationBadgeID = "donationBadgeId"
        case urlBadge, donationBadge, isShowBadge, referralCode, chatPrice
    }
}

public struct Pageable: Codable {
    public let sort: Sort?
    public let pageNumber, pageSize, offset: Int?
    public let paged, unpaged: Bool?
}

public struct Sort: Codable {
    public let sorted, unsorted, empty: Bool?
}
