import Foundation

public struct LiveStreamAudienceListRequest {
    public let roomId: String
    public let ownerId: String
    public let page: Int
    
    public init(roomId: String, ownerId: String, page: Int) {
        self.roomId = roomId
        self.ownerId = ownerId
        self.page = page
    }
}
