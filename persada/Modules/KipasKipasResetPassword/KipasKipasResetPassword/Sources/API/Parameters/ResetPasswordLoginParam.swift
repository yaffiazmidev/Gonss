import Foundation

public struct ResetPasswordLoginParam: Encodable {
    public let username: String?
    public let deviceId: String
    public let password: String?
    public let otpCode: String?
    public let platform: String?
    
    public init(
        username: String?,
        deviceId: String,
        password: String? = nil,
        otpCode: String? = nil,
        platform: String? = nil
    ) {
        self.username = username
        self.deviceId = deviceId
        self.password = password
        self.otpCode = otpCode
        self.platform = platform
    }
}
