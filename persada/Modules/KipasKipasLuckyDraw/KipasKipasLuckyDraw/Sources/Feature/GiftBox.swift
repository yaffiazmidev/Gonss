import Foundation

public struct GiftBoxContent: Codable {
    public let content: [GiftBox]
    
    public init(content: [GiftBox]) {
        self.content = content
    }
}

public struct GiftBox: Codable {
    public let id: Int
    public let giftName: String?
    public let giftPrice: Double?
    public let giftNum: Int?
    public let giftURL, lotteryType, createAt, lotteryDate: String?
    public let lotteryCrowdType, feedID: String?
    public let lotteryNum, ownerAccountID: Int?
    public let isJoined, isFans: Bool?
    public let status: String?
    public let wonAccounts: [GiftBoxWinner]?

    public init(
        id: Int,
        giftName: String,
        giftPrice: Double,
        giftNum: Int,
        giftURL: String,
        lotteryType: String,
        createAt: String,
        lotteryDate: String,
        lotteryCrowdType: String,
        feedID: String,
        lotteryNum: Int,
        ownerAccountID: Int,
        isJoined: Bool,
        isFans: Bool,
        status: String,
        wonAccounts: [GiftBoxWinner]
    ) {
        self.id = id
        self.giftName = giftName
        self.giftPrice = giftPrice
        self.giftNum = giftNum
        self.giftURL = giftURL
        self.lotteryType = lotteryType
        self.createAt = createAt
        self.lotteryDate = lotteryDate
        self.lotteryCrowdType = lotteryCrowdType
        self.feedID = feedID
        self.lotteryNum = lotteryNum
        self.ownerAccountID = ownerAccountID
        self.isJoined = isJoined
        self.isFans = isFans
        self.status = status
        self.wonAccounts = wonAccounts
    }
    
    public enum CodingKeys: String, CodingKey {
        case id, giftName, giftPrice, giftNum
        case giftURL = "giftUrl"
        case lotteryType, createAt, lotteryDate, lotteryCrowdType
        case feedID = "feedId"
        case lotteryNum
        case ownerAccountID = "ownerAccountId"
        case isJoined, isFans, status, wonAccounts
    }
}
