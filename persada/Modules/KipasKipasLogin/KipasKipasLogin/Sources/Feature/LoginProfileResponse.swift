import Foundation

public typealias LoginProfileData = RootData<LoginProfileResponse>

public struct LoginProfileResponse: Codable {
    public let id, username, name: String?
    public let photo: String?
    public let birthDate, gender: String?
    public let isSeleb: Bool?
    public let mobile, email, accountType: String?
    public let isVerified: Bool?
    public let totalFollowing: Int?

    public init(
        id: String?,
        username: String?,
        name: String?,
        photo: String?,
        birthDate: String?,
        gender: String?,
        isSeleb: Bool?,
        mobile: String?,
        email: String?,
        accountType: String?,
        isVerified: Bool?,
        totalFollowing: Int?
    ) {
        self.id = id
        self.username = username
        self.name = name
        self.photo = photo
        self.birthDate = birthDate
        self.gender = gender
        self.isSeleb = isSeleb
        self.mobile = mobile
        self.email = email
        self.accountType = accountType
        self.isVerified = isVerified
        self.totalFollowing = totalFollowing
    }
}
