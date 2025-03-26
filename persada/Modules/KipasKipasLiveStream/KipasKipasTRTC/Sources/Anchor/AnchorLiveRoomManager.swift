import UIKit
import TUICore
import TXLiteAVSDK_Professional

public final class AnchorLiveRoomManager: NSObject {
        
    private lazy var imManager: V2TIMManager = {
        return V2TIMManager.sharedInstance()
    }()
    
    public lazy var cloud: TRTCCloud = {
        let cloud = TRTCCloud.sharedInstance()
        cloud.delegate = self
        return cloud
    }()
    
    private lazy var params: TRTCParams = {
        let params = TRTCParams()
        params.sdkAppId = UInt32(TUILogin.getSdkAppID())
        params.userId = TUILogin.getUserID() ?? ""
        params.userSig = TUILogin.getUserSig() ?? ""
        params.role = .anchor
        return params
    }()
    
    private var isFrontCamera: Bool = true
    private var likesCount: Int = 0
    
    private var joinedAudiencesUserId = Set<String>()
    private var realtimeAudiencesUserId = Set<String>()
    
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
    
    private let chatService: LiveRoomMessageService
    private let giftService: LiveRoomGiftService
    
    public init(
        chatService: LiveRoomMessageService = .init(),
        giftService: LiveRoomGiftService = .init()
    ) {
        self.chatService = chatService
        self.giftService = giftService
    }

    public func createRoom(parameter: LiveRoomParameter, completion: @escaping (Error?) -> Void) {
        let roomId = parameter.roomId
        let roomName = String(parameter.roomName.utf8Prefix(30))
      
        imManager.add(self)
        imManager.addSimpleMsgListener(listener: self)
        imManager.addGroupListener(listener: self)
        
        imManager.createGroup(
            "AVChatRoom",
            groupID: roomId,
            groupName: roomName
        ) { [weak self] _ in
            
            let info = V2TIMGroupInfo()
            info.groupID = roomId
            info.groupName = roomName
            
            self?.imManager.setGroupInfo(info, succ: nil, fail: nil)
            
            completion(nil)
        } fail: { [weak self] code, message in
            completion(LiveRoomError.createRoomError)
        }
    }
    
    public func startCameraPreview(in view: UIView) { 
        cloud.setVideoEncoderMirror(true)
        cloud.startLocalPreview(true, view: view) 
    }
    
    public func stopCamera() {
        cloud.stopLocalPreview()
    }
     
    public func startLiveStreaming(parameter: LiveRoomParameter, view: UIView) {
        params.streamId = parameter.ownerId
        params.roomId = UInt32(parameter.roomId) ?? 0
        
        cloud.enterRoom(params, appScene: .LIVE)
        cloud.setAudioRoute(.modeSoundCard)
        cloud.setSystemVolumeType(.media)
        cloud.startLocalAudio(.music)
        
        let videoEncoder = TRTCVideoEncParam()
        videoEncoder.videoResolution = ._1920_1080
        videoEncoder.videoBitrate = 3000
        videoEncoder.videoFps = 24
        
        cloud.setVideoEncoderParam(videoEncoder)
        cloud.startPublishing(parameter.ownerId, type: .big)
        cloud.startRemoteView(parameter.ownerId, streamType: .big, view: view)
 
        cloud.setGravitySensorAdaptiveMode(.disable)
        
        showWelcomeMessage()
    }
    
    public func toggleCamera() {
        isFrontCamera.toggle()
        cloud.setVideoEncoderMirror(isFrontCamera)
        cloud.getDeviceManager().switchCamera(isFrontCamera)
    }
     
    
    public func getLiveRoomSummary() -> LiveRoomSummary {
        return (viewerCount: joinedAudiencesUserId.count, likeCount: likesCount)
    }
    
    public func destroyLiveStreaming(roomId: String, userId: String) {
        cloud.stopLocalAudio()
        cloud.stopLocalPreview()
        cloud.stopRemoteView(userId, streamType: .big)
        cloud.stopPublishing()
        cloud.exitRoom()
        print("主播====exitRoom====")
        imManager.dismissGroup(roomId, succ: nil, fail: nil)
      
        imManager.remove(self)
        imManager.removeGroupListener(listener: self)
        imManager.removeSimpleMsgListener(listener: self)
        
        TRTCCloud.destroySharedIntance()
    }
    
    public func sendMessage(_ message: String, to groupId: String) {
        chatService.sendMessage(
            to: groupId,
            message: message,
            type: .CHAT
        )
    }
    
    private func showWelcomeMessage() {
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
     
}

extension AnchorLiveRoomManager: TRTCCloudDelegate {
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

extension AnchorLiveRoomManager: V2TIMSDKListener {
    public func onKickedOffline() {
        delegate?.onLiveStreamingKickedByDoubleLogin()
    }
}

extension AnchorLiveRoomManager: V2TIMSimpleMsgListener {
    public func onRecvGroupCustomMessage(_ msgID: String!, groupID: String!, sender info: V2TIMGroupMemberInfo!, customData data: Data!) {
        handleLikesReaction(groupId: groupID, from: data)
        handleAudienceCount(from: data)
        handleLikesCount(from: data)
    }
    
    public func onRecvC2CCustomMessage(_ msgID: String!, sender info: V2TIMUserInfo!, customData data: Data!) {
        
        guard let message = AnchorLiveRoomManager.decode(LiveRoomMessage<Sender>.self, from: data) else { return }
        
        let sender = message.data.extInfo.value
        let messageType = message.data.extInfo.msgType
        
        switch messageType {
        case .LIKE:
            let sender = Sender(
                userId: info.userID ?? "",
                userName: info.nickName ?? "",
                avatarUrl: info.faceURL ?? ""
            )
            
            let messageData = createCustomChatMessage(
                value: sender,
                message: sender.userName + " menyukai LIVE",
                messageType: .LIKE
            )
            
            if let message = imManager.createCustomMessage(messageData) {
                imManager.send(message, receiver: nil, groupID: String(params.roomId), priority: .PRIORITY_HIGH, onlineUserOnly: false, offlinePushInfo: nil, progress: nil, succ: nil, fail: nil)
            }
        case .JOIN:
            realtimeAudiencesUserId.insert(sender.userId)
            joinedAudiencesUserId.insert(sender.userId)
           
            broadcastJoinedUserMessage(
                groupId: String(params.roomId),
                value: sender
            )
            
            broadcastRealtimeAudienceCounter(
                groupId: String(params.roomId)
            )
            
            broadcastRealtimeLikesCounter(
                groupId: String(params.roomId),
                isJoined: true
            )
        default: break
        }
    }
    
    private static func decode<T: Decodable>(_ response: T.Type, from data: Data) -> T? {
        return try? JSONDecoder().decode(response, from: data)
    }
}

extension AnchorLiveRoomManager: V2TIMGroupListener {
    public func onMemberLeave(_ groupID: String!, member: V2TIMGroupMemberInfo!) {
        realtimeAudiencesUserId.remove(member.userID)
        broadcastRealtimeAudienceCounter(groupId: groupID)
    }
    
    public func onGroupDismissed(_ groupID: String!, opUser: V2TIMGroupMemberInfo!) {
        delegate?.onLiveStreamingEnded()
    }
}

private extension AnchorLiveRoomManager {
    func handleLikesReaction(groupId: String, from data: Data) {
        if let dict = TUITool.jsonData2Dictionary(data) as? NSDictionary,
           let like = dict.value(forKeyPath: "businessID") as? String,
           like == TUIIdentifier.likeReaction
        {
            likesCount += 1
            delegate?.onLiveStreamingRealtimeLikesCount(String(likesCount))
            broadcastRealtimeLikesCounter(groupId: groupId, isJoined: false)
        }
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
    
    func broadcastRealtimeAudienceCounter(groupId: String) {
        let currentAudienceCount = realtimeAudiencesUserId.count
        
        let dict: [AnyHashable: Any] = ["audienceCounting": String(currentAudienceCount)]
        
        let data = TUITool.dictionary2JsonData(dict)
        if let message = imManager.createCustomMessage(data) {
            imManager.send(message, receiver: nil, groupID: groupId, priority: .PRIORITY_HIGH, onlineUserOnly: false, offlinePushInfo: nil, progress: nil, succ: nil, fail: nil)
        }
        
        delegate?.onLiveStreamingRealtimeAudiencesCount(String(currentAudienceCount))
    }
    
    func broadcastRealtimeLikesCounter(groupId: String, isJoined: Bool) {
        var dict: [AnyHashable: Any] = [
            "totalLikes": String(likesCount)
        ]
        
        if !isJoined {
            dict["businessID"] = TUIIdentifier.likeReaction
        }
        
        let data = TUITool.dictionary2JsonData(dict)
        if let message = imManager.createCustomMessage(data) {
            imManager.send(message, receiver: nil, groupID: groupId, priority: .PRIORITY_HIGH, onlineUserOnly: false, offlinePushInfo: nil, progress: nil, succ: nil, fail: nil)
        }
    }
    
    func broadcastJoinedUserMessage(
        groupId: String,
        value: Sender
    ) {
        let messageData = createCustomChatMessage(
            value: value,
            message: value.userName + " joined",
            messageType: .JOIN
        )
        
        if let message = imManager.createCustomMessage(messageData) {
            imManager.send(message, receiver: nil, groupID: groupId, priority: .PRIORITY_HIGH, onlineUserOnly: false, offlinePushInfo: nil, progress: nil, succ: nil, fail: nil)
        }
    }
}

private extension String {
    func utf8Prefix(_ maxLength: Int) -> Substring {
        if self.utf8.count <= maxLength {
            return Substring(self)
        }

        let index = self.utf8.index(self.startIndex, offsetBy: maxLength)
        return self.prefix(upTo: index)
    }
}
