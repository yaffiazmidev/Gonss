import Foundation

struct RemoteDonationGlobalRank: Codable {
    let id: String?
    let globalRank: Int?
    let name, statusRank: String?
    let url: String?
    let account: RemoteAccount?
}

struct RemoteAccount: Codable {
    let id, username, name, bio: String?
    let photo: String?
    let birthDate, gender: String?
    let isFollow, isSeleb: Bool?
    let mobile, email, accountType: String?
    let isVerified: Bool?
    let note: String?
    let isDisabled, isSeller: Bool?
    let totalDonation: Double?
    let donationBadgeID: String?
    let levelBadge: Int?
    let urlBadge: String?
    let isShowBadge: Bool?

    enum CodingKeys: String, CodingKey {
        case id, username, name, bio, photo, birthDate, gender, isFollow, isSeleb, mobile, email, accountType, isVerified, note, isDisabled, isSeller, totalDonation, levelBadge, isShowBadge
        case donationBadgeID = "donationBadgeId"
        case urlBadge
    }
}
