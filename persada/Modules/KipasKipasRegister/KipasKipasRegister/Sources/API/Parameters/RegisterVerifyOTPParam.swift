import Foundation

public struct RegisterVerifyOTPParam: Encodable {
    public let code: String
    public let phoneNumber: String
    public let type: String
    public let platform: RegisterOTPPlatform
    
    public init(
        code: String,
        phoneNumber: String,
        type: String = "REGISTER",
        platform: RegisterOTPPlatform
    ) {
        self.code = code
        self.phoneNumber = phoneNumber
        self.type = type
        self.platform = platform
    }
}
