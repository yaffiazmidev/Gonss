import Foundation

public struct RegisterVerifyEmailParam: Encodable {
    public let code: String
    public let token: String
    public let deviceId: String
    
    public init(
        code: String,
        token: String,
        deviceId: String
    ) {
        self.code = code
        self.token = token
        self.deviceId = deviceId
    }
}
