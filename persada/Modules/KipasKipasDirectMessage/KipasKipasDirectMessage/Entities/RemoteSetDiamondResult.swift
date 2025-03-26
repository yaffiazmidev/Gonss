import Foundation

public struct RemoteSetDiamondData: Codable {
    public let coin, deposit, diamond: Int?
    public let chatPrice: Int?
    public let mobileMessageid, externalChatid: String?

    enum CodingKeys: String, CodingKey {
        case coin, deposit, diamond, chatPrice
        case mobileMessageid
        case externalChatid
    }
}
