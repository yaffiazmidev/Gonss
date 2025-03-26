import Foundation

public struct LiveRoomChatViewModel {
    
    public enum ChatType: String {
        case WELCOME
        case JOIN
        case CHAT
        case LIKE
    }
    
    public let senderUserId: String?
    public let senderUsername: String?
    public let senderAvatarURL: String?
    public let message: String
    public let messageType: ChatType
    
    public init(
        senderUserId: String? = nil,
        senderUsername: String? = nil,
        senderAvatarURL: String? = nil,
        message: String,
        messageType: ChatType
    ) {
        self.senderUserId = senderUserId
        self.senderUsername = senderUsername
        self.senderAvatarURL = senderAvatarURL
        self.message = message
        self.messageType = messageType
    }
}

public extension [LiveRoomChatViewModel] {
    
    func lastIndexOf(type: LiveRoomChatViewModel.ChatType) -> Int? {
        return lastIndex(where: \.messageType == type)
    }
    
    func ofType(_ type: LiveRoomChatViewModel.ChatType) -> Self {
        return filter(\.messageType == type)
    }
}

public extension Array {
    mutating func safeRemove(at index: Index) {
        guard !isEmpty else { return }
        remove(at: index)
    }
    
    mutating func safeRemoveAll() {
        guard !isEmpty else { return }
        removeLast()
    }
    
    mutating func safeRemoveLast() {
        guard !isEmpty else { return }
        removeLast()
    }
}

private func ==<T, V: Equatable>(lhs: KeyPath<T, V>, rhs: V) -> (T) -> Bool {
    return { $0[keyPath: lhs] == rhs }
}

