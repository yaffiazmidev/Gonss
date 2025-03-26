import UIKit
import TUICore
import TXLiteAVSDK_Professional
import KipasKipasShared

public final class AudienceLiveRoomManager: NSObject {
    
    private lazy var imManager: V2TIMManager = {
        return V2TIMManager.sharedInstance()
    }()
    
    private lazy var subcloud: TRTCCloud = {
        let cloud = TRTCCloud.sharedInstance()
        let sub = cloud.createSub()
        sub.delegate = self
        return sub
    }()
    
    #warning("[BEKA] move this code to somewhere else, should not import KipasKipasShared")
    private lazy var likedMessages = DelayedTunnel<Void>(interval: 7) { [weak self] _ in
        self?.broadcastLikeNotification()
    }
    
    private let parameter: LiveRoomParameter
    private let chatService: LiveRoomMessageService
    private let giftService: LiveRoomGiftService
    
    public weak var delegate: LiveRoomDelegate?
    
    public weak var chatDelegate: LiveRoomMessageServiceDelegate? {
        didSet {
            chatService.delegate = chatDelegate
        }
    }
    
    public weak var giftDelegate: LiveRoomGiftServiceDelegate? {
        didSet {
            giftService.delegate = giftDelegate
        }
    }
    
    private struct TUIIdentifier {
        static let giftService = TUICore_TUIGiftService
        static let sendLikeMethod = TUICore_TUIGiftService_SendLikeMethod
        static let likeReaction = "TUIGift_like"
    }
    
    private lazy var params: TRTCParams = {
        let params = TRTCParams()
        params.sdkAppId = UInt32(TUILogin.getSdkAppID())
        params.userId = TUILogin.getUserID() ?? ""
        params.userSig = TUILogin.getUserSig() ?? ""
        params.role = .audience
        return params
    }()
    
    public init(
        parameter: LiveRoomParameter,
        chatService: LiveRoomMessageService = .init(),
        giftService: LiveRoomGiftService = .init()
    ) {
        self.parameter = parameter
        self.chatService = chatService
        self.giftService = giftService
    }
    
    public func exitRoom() {
        print("观众====exitRoom====")
        subcloud.exitRoom()
    }
    
    public func didClickLikeReaction() {
        giftService.sendLikeMessage(to: parameter.roomId)
        likedMessages.append(())
    }
    
    public func startPlay(on view: UIView) {
        subcloud.startRemoteView(parameter.ownerId, streamType: .big, view: view)
    }
    
    public func sendGift(_ metadata: GiftMetadata) {
        giftService.sendGiftMessage(
            metadata,
            to: parameter.roomId,
            hostId: parameter.ownerId
        )
    }
    
    public func stopPlay() {
        subcloud.stopRemoteView(parameter.ownerId, streamType: .big)
    }
    
    public func freezePlay(_ mute:Bool) {
        subcloud.muteRemoteVideoStream(parameter.ownerId, streamType: .big, mute: mute)
        subcloud.muteRemoteAudio(parameter.ownerId, mute: mute)
    }
    
    public func enterRoom() {
        guard parameter.roomId.count <= 9 else { return }
        
        #warning("[BEKA] Need to handle this")
        params.roomId = UInt32(parameter.roomId) ?? 0
        params.streamId = parameter.ownerId
        subcloud.enterRoom(params, appScene: .LIVE)
        
        imManager.add(self)
        imManager.addSimpleMsgListener(listener: self)
        imManager.addGroupListener(listener: self)
    }
    
    public func enterChatRoom() {
        let groupId = parameter.roomId
        let ownerId = parameter.ownerId
      
        imManager.joinGroup(groupId, msg: "") { [weak self] in
            self?.showWelcomeMessage()
            self?.onAudienceJoinedNotifyOwner(
                groupID: groupId,
                ownerId: ownerId
            )
            
        } fail: { [weak self] code, _ in
            /// Live-streaming ended & groupId not exists
            if code == 10010 || code == 10015 {
                self?.delegate?.onLiveStreamingEnded()
            }
        }
    }
    
    public func leaveChatRoom() {
        imManager.quitGroup(parameter.roomId, succ: nil, fail: nil)
        imManager.remove(self)
        imManager.removeSimpleMsgListener(listener: self)
        imManager.removeGroupListener(listener: self)
    }
    
    public func pause() {
        subcloud.pauseScreenCapture()
    }
    
    public func resume() {
        subcloud.resumeScreenCapture()
    }
    
    private func broadcastLikeNotification() {
        let sender = Sender(
            userId: TUILogin.getUserID() ?? "",
            userName: TUILogin.getNickName() ?? "",
            avatarUrl: TUILogin.getFaceUrl() ?? ""
        )
        
        let messageData = createCustomChatMessage(
            value: sender,
            message: sender.userName + " menyukai LIVE",
            messageType: .LIKE
        )
        
        if let message = imManager.createCustomMessage(messageData) {
            message.isExcludedFromLastMessage = true
            message.isExcludedFromUnreadCount = true
            imManager.send(message, receiver: parameter.ownerId, groupID: nil, priority: .PRIORITY_NORMAL, onlineUserOnly: false, offlinePushInfo: nil, progress: nil, succ: nil, fail: nil)
        }
    }
    
    public func sendMessage(_ message: String) {
        chatService.sendMessage(
            to: parameter.roomId,
            message: message,
            type: .CHAT
        )
    }
}

extension AudienceLiveRoomManager: TRTCCloudDelegate {
    public func onNetworkQuality(_ localQuality: TRTCQualityInfo, remoteQuality: [TRTCQualityInfo]) {
        let isBuffer = localQuality.quality != .excellent && localQuality.quality != .good &&
        localQuality.quality != .poor
        delegate?.onLiveStreamingCheckNetwork(buffer: isBuffer)
    }
    
    public func onRemoteVideoStatusUpdated(_ userId: String, streamType: TRTCVideoStreamType, streamStatus status: TRTCAVStatusType, reason: TRTCAVStatusChangeReason, extrainfo: [AnyHashable : Any]?) {
        let isPaused = status == .stopped && (reason == .localStopped || reason == .remoteStopped)
        delegate?.onLiveStreamingPaused(paused: isPaused)
    }
}

extension AudienceLiveRoomManager: V2TIMSDKListener {
    public func onKickedOffline() {
        delegate?.onLiveStreamingKickedByDoubleLogin()
    }
}

extension AudienceLiveRoomManager: V2TIMSimpleMsgListener {
    public func onRecvGroupCustomMessage(_ msgID: String!, groupID: String!, sender info: V2TIMGroupMemberInfo!, customData data: Data!) {
        handleAudienceCount(from: data)
        handleLikesCount(from: data)
    }
}

extension AudienceLiveRoomManager: V2TIMGroupListener {
    public func onGroupDismissed(_ groupID: String!, opUser: V2TIMGroupMemberInfo!) {
        delegate?.onLiveStreamingEnded()
    }
}

private extension AudienceLiveRoomManager {
    func onAudienceJoinedNotifyOwner(
        groupID: String,
        ownerId: String
    ) {
        
        let joinedAudience = Sender(
            userId: TUILogin.getUserID() ?? "",
            userName: TUILogin.getNickName() ?? "",
            avatarUrl: TUILogin.getFaceUrl() ?? ""
        )
        
        let messageData = createCustomChatMessage(
            value: joinedAudience,
            message: joinedAudience.userName + " joined",
            messageType: .JOIN
        )
        
        if let message = imManager.createCustomMessage(messageData) {
            message.isExcludedFromLastMessage = true
            message.isExcludedFromUnreadCount = true
            imManager.send(message, receiver: ownerId, groupID: nil, priority: .PRIORITY_NORMAL, onlineUserOnly: false, offlinePushInfo: nil, progress: nil, succ: nil, fail: nil)
        }
    }
    
    func showWelcomeMessage() {
        let sender = Sender(
            userId: TUILogin.getUserID() ?? "",
            userName: TUILogin.getNickName() ?? "",
            avatarUrl: TUILogin.getFaceUrl() ?? ""
        )
        
        let messageData = createCustomChatMessage(
            value: sender,
            message: "Rasakan keseruan bersama di Live Kipaskipas. Interaksi live jadi lebih asik! Tetap ikuti Syarat & Ketentuan, ya!",
            messageType: .WELCOME
        )
        chatService.sendMessageToLocal(messageData)
    }
    
    func handleAudienceCount(from data: Data) {
        if let dict = TUITool.jsonData2Dictionary(data) as? NSDictionary,
           let audienceCount = dict.value(forKeyPath: "audienceCounting") as? String {
            delegate?.onLiveStreamingRealtimeAudiencesCount(audienceCount)
        }
    }
    
    func handleLikesCount(from data: Data) {
        if let dict = TUITool.jsonData2Dictionary(data) as? NSDictionary,
           let totalLikesCount = dict.value(forKeyPath: "totalLikes") as? String {
            delegate?.onLiveStreamingRealtimeLikesCount(totalLikesCount)
        }
    }
}
