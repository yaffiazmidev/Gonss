import Foundation

public struct RegisterUserParam: Encodable {
    public let name: String?
    public let mobile: String?
    public let password: String?
    public let photo: String?
    public let username: String?
    public let otpCode: String?
    public let birthDate: String?
    public let gender: String?
    public let deviceId: String?
    public let referralCode: String?
    public let email: String?
    
    public init(
        name: String?,
        mobile: String?,
        password: String?,
        photo: String?,
        username: String?,
        otpCode: String?,
        birthDate: String?,
        gender: String?,
        deviceId: String?,
        referralCode: String?,
        email: String?
    ) {
        self.name = name
        self.mobile = mobile
        self.password = password
        self.photo = photo
        self.username = username
        self.otpCode = otpCode
        self.birthDate = birthDate
        self.gender = gender
        self.deviceId = deviceId
        self.referralCode = referralCode
        self.email = email
    }
}
