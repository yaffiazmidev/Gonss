import Foundation

public struct LocalTokenItem: Codable, Hashable {
    public let accessToken: String
    public let refreshToken: String
    public let expiresIn: Date
    
    public init(accessToken: String, refreshToken: String, expiresIn: Date) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
    }
}
