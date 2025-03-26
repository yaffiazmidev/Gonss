import Foundation

public struct ChatSession: Codable {
    public let coin, deposit, diamond: Int?
    public let chatPrice: Int?
    public let sendBirdChatID, message, mobileMessageID: String?
    public let isSuccessRetry, isAutoDeposit: Bool?
    
    enum CodingKeys: String, CodingKey {
        case coin, deposit, diamond
        case chatPrice
        case sendBirdChatID = "sendBirdChatId"
        case message
        case mobileMessageID = "mobileMessageId"
        case isSuccessRetry, isAutoDeposit
    }
}
