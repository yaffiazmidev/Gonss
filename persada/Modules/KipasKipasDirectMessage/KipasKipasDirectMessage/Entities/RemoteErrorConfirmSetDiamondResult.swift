import Foundation

public struct RemoteErrorConfirmSetDiamondResult: Codable, Equatable {
    public var code, message: String?
    public var data: RemoteErrorConfirmSetDiamondData?
}

public struct RemoteErrorConfirmSetDiamondData: Codable, Equatable {
    public var createBy, createAt, modifyBy, modifyAt: String?
    public var isDeleted: Bool?
    public var externalChannelid, channelName: String?
    public var coinDeposit: Int?
    public var accountids: [String]?
    public var isPaidActive: Bool?
    public var currentPrice, updatedPrice, ttl: Int?

    enum CodingKeys: String, CodingKey {
        case createBy, createAt, modifyBy, modifyAt, isDeleted
        case externalChannelid = "externalChannelId"
        case channelName, coinDeposit
        case accountids = "accountIds"
        case isPaidActive, currentPrice, updatedPrice, ttl
    }
}
