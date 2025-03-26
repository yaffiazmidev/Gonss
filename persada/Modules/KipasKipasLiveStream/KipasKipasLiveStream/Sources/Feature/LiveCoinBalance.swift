import Foundation

public struct LiveCoinBalance: Codable {
    public let coin, diamond, deposit: Int?
    public let payerID, recipientID: String?
    public let sessionCreateAt: Int?

    enum CodingKeys: String, CodingKey {
        case coin, diamond, deposit
        case payerID = "payerId"
        case recipientID = "recipientId"
        case sessionCreateAt
    }
}
