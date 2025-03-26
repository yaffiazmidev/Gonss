import Foundation

public struct ResetPasswordVerifyOTPParam: Encodable {
    
    public struct Email: Encodable {
        public let code: String
        public let email: String
        public let platform: String
        
        public init(
            code: String,
            email: String,
            platform: String = "EMAIL"
        ) {
            self.code = code
            self.email = email
            self.platform = platform
        }
    }
    
    /*
     Verify by clicking the verification link sent to email
     */
    public struct EmailLink: Encodable {
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
    
    public struct Phone: Encodable {
        public let code: String
        public let phoneNumber: String
        public let platform: String
        public let type: String
        
        public init(
            code: String,
            phoneNumber: String,
            platform: String = "WHATSAPP",
            type: String = "FORGOT_PASSWORD"
        ) {
            self.code = code
            self.phoneNumber = phoneNumber
            self.platform = platform
            self.type = type
        }
    }
  
    public let phone: Phone?
    public let email: Email?
    public let emailLink: EmailLink?
    
    /// The client needs to decide which verification type to be used
    public init(
        phone: Phone? = nil,
        email: Email? = nil,
        emailLink: EmailLink? = nil
    ) {
        self.phone = phone
        self.email = email
        self.emailLink = emailLink
    }
}
