
import Foundation

public struct RemoteDonationTransactionGroupRoot: Codable, Equatable {
    public var code, message: String?
    public var data: RemoteDonationTransactionGroupData?

}

public struct RemoteDonationTransactionGroupData: Codable, Equatable {
    public var donations: [RemoteDonationTransactionGroup]?
    public var totalAmount: Int?
}

public struct RemoteDonationTransactionGroup: Codable, Equatable {
    public var postDonationId, title: String?
    public var urlPhoto: String?
    public var amount: Int?
}
