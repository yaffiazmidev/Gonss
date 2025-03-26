import Foundation
import KipasKipasLogin

struct RemoteUpdatePassword: Codable {
    let code, message: String
    let data: LoginResponse?
}

struct RemoteUpdatePasswordData: Codable {
    let userMobile: String
}
