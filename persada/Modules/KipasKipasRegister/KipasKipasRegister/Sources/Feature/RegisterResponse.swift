import Foundation

public struct RegisterResponse: Codable {
    public let accessToken, tokenType, loginRefreshToken: String?
    public let expiresIn: Int?
    public let scope: String?
    public let userNo: Int?
    public let userName, userEmail, userMobile, accountId: String?
    public let authorities: [String]?
    public let appSource, code: String?
    public let timelapse: Int?
    public let role, jti, token, refreshToken: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case loginRefreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case scope, userNo, userName, userEmail, userMobile, accountId, authorities, appSource, code, timelapse, role, jti, token, refreshToken
    }
}
