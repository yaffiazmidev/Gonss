import Foundation

public struct GiftBoxWinner: Codable {
    public let id: Int
    public let name: String?
    public let username: String?
    public let photo: String?
    
    public init(
        id: Int,
        name: String,
        username: String,
        photo: String
    ) {
        self.id = id
        self.name = name
        self.username = username
        self.photo = photo
    }
}
