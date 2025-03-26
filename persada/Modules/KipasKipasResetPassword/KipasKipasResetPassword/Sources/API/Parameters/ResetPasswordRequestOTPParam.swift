import Foundation

public struct ResetPasswordRequestOTPParam: Encodable {
    
    public struct Email: Encodable {
        public let email: String
        public let deviceId: String
        
        public init(
            email: String,
            deviceId: String
        ) {
            self.email = email
            self.deviceId = deviceId
        }
    }
    
    public struct Phone: Encodable {
        public let key: String
        public let platform: String
        
        public init(
            key: String,
            platform: String = "WHATSAPP"
        ) {
            self.key = key
            self.platform = platform
        }
    }
    
    public let phone: Phone?
    public let email: Email?
    
    /// Client needs to decide the value
    public init(
        phone: Phone? = nil,
        email: Email? = nil
    ) {
        self.phone = phone
        self.email = email
    }
}
