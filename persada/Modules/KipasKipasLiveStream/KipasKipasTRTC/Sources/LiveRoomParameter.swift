import Foundation

public struct LiveRoomParameter {
    public let roomId: String
    public let ownerId: String
    public let roomName: String
    
    public init(roomId: String, ownerId: String, roomName: String) {
        self.roomId = roomId
        self.ownerId = ownerId
        self.roomName = roomName
    }
}
