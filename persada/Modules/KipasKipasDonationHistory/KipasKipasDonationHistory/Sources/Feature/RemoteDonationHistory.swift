import Foundation

public struct RemoteDonationHistory: Codable {
    public let id: String?
    public let activityType: String?
    public let historyType, accountName: String?
    public let nominal: Double?
    public let bankFee: Double?
    public let createAt: Int?
}
