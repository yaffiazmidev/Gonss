import Foundation

public struct LiveRoomInfoViewModel {
    public let roomId: String
    public let roomName: String
    public let ownerName: String
    public let ownerId: String
    public let ownerPhoto: String
    public let isFollowingOwner: Bool
    public let isVerified: Bool
    
    public init(
        roomId: String,
        roomName: String,
        ownerName: String,
        ownerId: String,
        ownerPhoto: String,
        isFollowingOwner: Bool,
        isVerified:Bool
    ) {
        self.roomId = roomId
        self.roomName = roomName
        self.ownerName = ownerName
        self.ownerId = ownerId
        self.ownerPhoto = ownerPhoto
        self.isFollowingOwner = isFollowingOwner
        self.isVerified = isVerified
    }
}

