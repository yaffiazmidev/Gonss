import Foundation

public struct LoginResponse: Codable {
    public var accessToken, loginResponseRefreshToken: String?
    public var token, refreshToken: String?
    public var userEmail, userMobile: String?
    public let tokenType: String?
    public let expiresIn: Int?
    public let scope: String?
    public let userNo: Int?
    public let userName, accountID: String?
    public let authorities: [String]?
    public let appSource, code: String?
    public let timelapse: Int?
    public let role, jti: String?

    public init(accessToken: String?, tokenType: String?, loginResponseRefreshToken: String?, expiresIn: Int?, scope: String?, userNo: Int?, userName: String?, userEmail: String?, userMobile: String?, accountID: String?, authorities: [String]?, appSource: String?, code: String?, timelapse: Int?, role: String?, jti: String?, token: String?, refreshToken: String?) {
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.loginResponseRefreshToken = loginResponseRefreshToken
        self.expiresIn = expiresIn
        self.scope = scope
        self.userNo = userNo
        self.userName = userName
        self.userEmail = userEmail
        self.userMobile = userMobile
        self.accountID = accountID
        self.authorities = authorities
        self.appSource = appSource
        self.code = code
        self.timelapse = timelapse
        self.role = role
        self.jti = jti
        self.token = token
        self.refreshToken = refreshToken
    }
    
    public enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case loginResponseRefreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case scope, userNo, userName, userEmail, userMobile
        case accountID = "accountId"
        case authorities, appSource, code, timelapse, role, jti, token, refreshToken
    }
}
