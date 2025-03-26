import TUICore

public protocol LiveRoomGiftServiceDelegate: AnyObject {
    func onReceiveMessage(_ data: Data?, selfId: String)
}

public final class LiveRoomGiftService: NSObject {
    
    private lazy var imManager: V2TIMManager = {
        return V2TIMManager.sharedInstance()
    }()
    
    private lazy var sender = {
        return Sender(
            userId: TUILogin.getUserID() ?? "" ,
            userName: TUILogin.getNickName() ?? "",
            avatarUrl: TUILogin.getFaceUrl() ?? ""
        )
    }()
    
    public weak var delegate: LiveRoomGiftServiceDelegate?
    
    public override init() {
        super.init()
        initListeners()
    }
    
    // MARK: Listneners
    private func initListeners() {
        imManager.addSimpleMsgListener(listener: self)
    }
    
    public func sendLikeMessage(to groupId: String) {
        let messageData = createLikeMessage(sender: sender)
        
        delegate?.onReceiveMessage(messageData, selfId: sender.userId)
        
        if let message = imManager.createCustomMessage(messageData) {
            imManager.send(message, receiver: nil, groupID: groupId, priority: .PRIORITY_NORMAL, onlineUserOnly: false, offlinePushInfo: nil, progress: nil, succ: nil, fail: nil)
        }
    }
    
    public func sendGiftMessage(
        _ metadata: GiftMetadata,
        to groupId: String,
        hostId: String
    ) {
        let gift = GiftData(
            giftId: metadata.giftId, 
            lottieUrl: metadata.lottieUrl,
            imageUrl: metadata.imageUrl,
            message: metadata.message,
            extInfo: .init(
                userId: sender.userId,
                userName: sender.userName,
                avatarUrl: sender.avatarUrl
            )
        )
        
        let messageData = createGiftMessage(gift, hostId: hostId)
        
        if let message = imManager.createCustomMessage(messageData) {
            imManager.send(message, receiver: nil, groupID: groupId, priority: .PRIORITY_HIGH, onlineUserOnly: false, offlinePushInfo: nil, progress: nil, succ: nil, fail: nil)
        }
    }
}

extension LiveRoomGiftService: V2TIMSimpleMsgListener {
    public func onRecvGroupCustomMessage(_ msgID: String!, groupID: String!, sender info: V2TIMGroupMemberInfo!, customData data: Data!) {
        delegate?.onReceiveMessage(data, selfId: sender.userId)
    }
}
