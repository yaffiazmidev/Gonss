import Foundation

public struct PaidSessionBalance: Codable {
    public let coin: Int?
    public let diamond: Int?
    public let deposit: Int?
    public let payerId: String?
    public let recipientId: String?
    public let sessionCreateAt: Double?
    public let isAutoDeposit: Bool?
}
