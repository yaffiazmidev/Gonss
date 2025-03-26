import Foundation

public struct RegisterRequestOTPParam: Encodable {
    public let phoneNumber: String
    public let platform: RegisterOTPPlatform
    public let type: String
    
    public init(
        phoneNumber: String,
        platform: RegisterOTPPlatform,
        type: String = "REGISTER"
    ) {
        self.phoneNumber = phoneNumber
        self.platform = platform
        self.type = type
    }
}
