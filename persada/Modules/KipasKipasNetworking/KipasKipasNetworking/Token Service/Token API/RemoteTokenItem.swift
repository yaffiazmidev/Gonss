import Foundation

struct RemoteTokenItem: Codable {
    let accessToken, loginResponseRefreshToken: String?
    let token, refreshToken: String?
    let userEmail, userMobile: String?
    let tokenType: String?
    let expiresIn: Int?
    let scope: String?
    let userNo: Int?
    let userName, accountID: String?
    let authorities: [String]?
    let appSource, code: String?
    let timelapse: Int?
    let role, jti: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case loginResponseRefreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case scope, userNo, userName, userEmail, userMobile
        case accountID = "accountId"
        case authorities, appSource, code, timelapse, role, jti, token, refreshToken
    }
}

