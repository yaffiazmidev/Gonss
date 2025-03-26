import Foundation

public struct DonationHistoryViewModel {
    
    public enum HistoryType: String {
        case debit = "DEBIT"
        case credit = "CREDIT"
    }
    
    public let id: String
    public let accountName: String
    public let nominal: String
    public let bankFee: String
    public let createdAt: String
    public let type: HistoryType
}
