import TUICore

public protocol LiveRoomMessageServiceDelegate: AnyObject {
    func onReceiveMessage(_ data: Data?)
}

public final class LiveRoomMessageService: NSObject {
    
    private lazy var imManager: V2TIMManager = {
        return V2TIMManager.sharedInstance()
    }()
    
    public weak var delegate: LiveRoomMessageServiceDelegate?
        
    public override init() {
        super.init()
        
        initListeners()
    }

    // MARK: Listneners
    private func initListeners() {
        imManager.addSimpleMsgListener(listener: self)
    }

    public func sendMessageToLocal(_ data: Data?) {
        delegate?.onReceiveMessage(data)
    }
    
    public func sendMessage(
        to groupId: String,
        message: String,
        type: Ext<Sender>.MessageType
    ) {
        let sender = Sender(
            userId: TUILogin.getUserID() ?? "",
            userName: TUILogin.getNickName() ?? "",
            avatarUrl: TUILogin.getFaceUrl() ?? ""
        )
        onReceiveMessage(
            from: sender,
            message: message,
            type: type
        )
        
        if let message = imManager.createTextMessage(message) {
            imManager.send(message, receiver: nil, groupID: groupId, priority: .PRIORITY_DEFAULT, onlineUserOnly: false, offlinePushInfo: nil, progress: nil, succ: nil, fail: nil)
        }
    }
    
    private func onReceiveMessage(
        from sender: Sender,
        message: String,
        type: Ext<Sender>.MessageType
    ) {
        let messageData = createCustomChatMessage(
            value: sender,
            message: message,
            messageType: type
        )
        delegate?.onReceiveMessage(messageData)
    }
}

extension LiveRoomMessageService: V2TIMSimpleMsgListener {
    public func onRecvGroupTextMessage(_ msgID: String!, groupID: String!, sender info: V2TIMGroupMemberInfo!, text: String!) {
        let sender = Sender(
            userId: info.userID ?? "",
            userName: info.nickName ?? "",
            avatarUrl: info.faceURL ?? ""
        )
        onReceiveMessage(
            from: sender,
            message: text,
            type: .CHAT
        )
    }
    
    public func onRecvC2CCustomMessage(_ msgID: String!, sender info: V2TIMUserInfo!, customData data: Data!) {
        delegate?.onReceiveMessage(data)
    }
    
    public func onRecvGroupCustomMessage(_ msgID: String!, groupID: String!, sender info: V2TIMGroupMemberInfo!, customData data: Data!) {
        delegate?.onReceiveMessage(data)
    }
}
