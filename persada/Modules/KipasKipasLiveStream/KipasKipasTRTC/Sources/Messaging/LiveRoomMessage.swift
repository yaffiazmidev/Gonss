import Foundation

public struct LiveRoomMessage<T: Codable>: Codable {
    public let businessID: String
    public let version: String
    public let platform: String
    public let data: MessageData<T>
}

public struct MessageData<T: Codable>: Codable {
    public let message: String
    public let extInfo: Ext<T>
}

public struct Ext<T: Codable>: Codable {
    public let value: T
    public let msgType: MessageType
    
    public enum MessageType: String, Codable {
        case WELCOME
        case JOIN
        case CHAT
        case LIKE
    }
}

public struct Sender: Codable {
    public let userId: String
    public let userName: String
    public let avatarUrl: String
    
    public init(userId: String, userName: String, avatarUrl: String) {
        self.userId = userId
        self.userName = userName
        self.avatarUrl = avatarUrl
    }
}

func createCustomChatMessage<T: Codable>(
    value: T,
    message: String,
    messageType: Ext<T>.MessageType
) -> Data? {
    let message = LiveRoomMessage<T>.init(
        businessID: "TUIBarrageCustom",
        version: "1.0",
        platform: "iOS",
        data: .init(
            message: message,
            extInfo: .init(
                value: value,
                msgType: messageType
            )
        )
    )
    
    return try? JSONEncoder().encode(message)
}

// MARK: Gift
public struct LiveRoomGift<T: Codable>: Codable {
    public let businessID: String
    public let version: String
    public let platform: String
    public let source: String
    public let status: String
    public let hostId: String
    public var comboGift: Int = 1
    public var totalComboGift: Int = 1
    public var data: T
    
    
    public var isGiftFromAdministrator: Bool {
        businessID == "TUIGift" && source == "administrator"
    }
    
    public var isStatusSuccess: Bool {
        status == "1000"
    }
    
    public var isStatusError: Bool {
        status == "5000"
    }
    
    public var isInsufficientBalance: Bool {
        status == "9003"
    }
}

public struct LiveRoomLike<T: Codable>: Codable {
    public let businessID: String
    public let version: String
    public let platform: String
    public let data: T
}

public struct GiftMetadata: Codable {
    public let giftId: String
    public let lottieUrl: String?
    public let imageUrl: String?
    public let message: String
    
    public init(
        giftId: String,
        lottieUrl: String?,
        imageUrl: String?,
        message: String
    ) {
        self.giftId = giftId
        self.lottieUrl = lottieUrl
        self.imageUrl = imageUrl
        self.message = message
    }
}

public struct GiftData: Codable {
    public let giftId: String
    public let lottieUrl: String?
    public let imageUrl: String?
    public let message: String
    public let extInfo: GiftExt
    public var comboGift: Int = 1
    public var totalComboGift: Int = 1
    
//     No need for the parsing of the comboGift data
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.giftId = try container.decode(String.self, forKey: .giftId)
        self.lottieUrl = try container.decodeIfPresent(String.self, forKey: .lottieUrl)
        self.imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        self.message = try container.decode(String.self, forKey: .message)
        self.extInfo = try container.decode(GiftExt.self, forKey: .extInfo)
//        self.comboGift = try container.decode(Int.self, forKey: .comboGift)
    }
    
    public init(
        giftId: String,
        lottieUrl: String?,
        imageUrl: String?,
        message: String,
        extInfo: GiftExt
    ) {
        self.giftId = giftId
        self.lottieUrl = lottieUrl
        self.imageUrl = imageUrl
        self.message = message
        self.extInfo = extInfo
    }
    
    public var userId: String {
        extInfo.userId
    }
}

public struct LikeData: Codable {
    public let extInfo: GiftExt
}

public struct GiftExt: Codable {
    public let userId: String
    public let userName: String
    public let avatarUrl: String
    
    public init(userId: String, userName: String, avatarUrl: String) {
        self.userId = userId
        self.userName = userName
        self.avatarUrl = avatarUrl
    }
}

func createLikeMessage(sender: Sender) -> Data? {
    let message = LiveRoomLike<LikeData>.init(
        businessID: "TUIGift_like",
        version: "1.0",
        platform: "iOS", 
        data: .init(
            extInfo: .init(
                userId: sender.userId,
                userName: sender.userName,
                avatarUrl: sender.avatarUrl
            )
        )
    )
    
    return try? JSONEncoder().encode(message)
}

public func createGiftMessage(_ data: GiftData, hostId: String) -> Data? {
    
    let message = LiveRoomGift<GiftData>.init(
        businessID: "TUIGift",
        version: "1.0",
        platform: "iOS",
        source: "", 
        status: "",
        hostId: hostId,
        data: data
    )
    
    return try? JSONEncoder().encode(message)
}
