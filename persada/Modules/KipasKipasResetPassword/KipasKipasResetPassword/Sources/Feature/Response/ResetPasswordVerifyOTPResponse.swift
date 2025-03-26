import Foundation

public typealias ResetPasswordVerifyOTPData = RootData<ResetPasswordVerifyOTPResponse>

public struct ResetPasswordVerifyOTPResponse: Codable {
    public let id: String?
    public let key: String?
    public let otpCode: String?
    public let newPassword: String?
    public let media: String?
    public let token: String?
    public let deviceId: String?
    public let code: String?
    public let email: String?
    
    public init(
        id: String?,
        key: String?,
        otpCode: String?,
        newPassword: String?,
        media: String?,
        token: String?,
        deviceId: String?,
        code: String?,
        email: String?
    ) {
        self.id = id
        self.key = key
        self.otpCode = otpCode
        self.newPassword = newPassword
        self.media = media
        self.token = token
        self.deviceId = deviceId
        self.code = code
        self.email = email
    }
}

extension ResetPasswordVerifyOTPResponse {
    
    public struct Phone {
        public let id: String?
        public let key: String?
        public let otpCode: String?
        public let newPassword: String?
        public let media: String?
     
        public init(
            id: String?,
            key: String?,
            otpCode: String?,
            newPassword: String?,
            media: String?
        ) {
            self.id = id
            self.key = key
            self.otpCode = otpCode
            self.newPassword = newPassword
            self.media = media
        }
    }
    
    public init(phone: Phone) {
        self.init(
            id: phone.id,
            key: phone.key,
            otpCode: phone.otpCode,
            newPassword: phone.newPassword,
            media: phone.media,
            token: nil,
            deviceId: nil,
            code: nil,
            email: nil
        )
    }
    
    public struct Email {
        public let id: String?
        public let newPassword: String?
        public let token: String?
        public let deviceId: String?
        public let code: String?
        public let email: String?
        
        public init(
            id: String?,
            newPassword: String?,
            token: String?,
            deviceId: String?,
            code: String?,
            email: String?
        ) {
            self.id = id
            self.newPassword = newPassword
            self.token = token
            self.deviceId = deviceId
            self.code = code
            self.email = email
        }
    }
    
    public init(email: Email) {
        self.init(
            id: email.id,
            key: nil,
            otpCode: nil,
            newPassword: email.newPassword,
            media: nil,
            token: email.token,
            deviceId: email.deviceId,
            code: email.code,
            email: email.email
        )
    }
}
