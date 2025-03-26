import Foundation
import KipasKipasLogin

struct RemoteUpdateUsername: Codable {
    let code, message: String?
    let data: LoginResponse?
}

struct RemoteUpdateUsernameData: Codable {
    let username: String
    
    enum CodingKeys: String, CodingKey {
        case username = "userName"
    }
}
