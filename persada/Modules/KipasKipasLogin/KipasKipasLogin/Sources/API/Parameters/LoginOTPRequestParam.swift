import Foundation

public struct LoginOTPRequestParam: Encodable {
    public let phoneNumber: String
    public let platform: String
    public let type: String
    
    public init(
        phoneNumber: String,
        platform: String,
        type: String = "LOGIN"
    ) {
        self.phoneNumber = phoneNumber
        self.platform = platform
        self.type = type
    }
}
