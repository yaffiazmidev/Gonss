import Foundation

public typealias GiftBoxData = RootData<GiftBox>
public typealias GiftBoxContentData = RootData<GiftBoxContent>
public typealias GiftBoxEmptyData = EmptyData

public struct EmptyData: Codable {
    public let code: String
    public let message: String
    
    public init(code: String, message: String) {
        self.code = code
        self.message = message
    }
}

public struct RootData<T: Codable>: Codable {
    public let code: String
    public let message: String
    public let data: T
    
    public init(
        code: String,
        message: String,
        data: T
    ) {
        self.code = code
        self.message = message
        self.data = data
    }
}
