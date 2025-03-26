import UIKit
import KipasKipasDirectMessage
import KipasKipasCall
import KipasKipasNetworking

class ConversationInteractor: NSObject {
    weak var delegate: IConversationViewController?
    
    public let userID: String
    public let channelURL: String
    public var network: DataTransferService!
    private let currentUserId = TXIMUserManger.shared.currentUserId
    private let serviceManager: DirectMessageCallServiceManager
    private(set) var messages: [TXIMMessage] = []
    private(set) var forwardMessages: [TXIMMessage] = []
    private(set) var name: String
    private(set) var avatar: String
    private(set) var isVerified: Bool
    private(set) var isSeleb: Bool = false
    private var isBlockUser: Bool = false {
        didSet {
            if isBlockUser != oldValue {
                self.delegate?.displayYouBlockUser(isBlock: isBlockUser)
            }
        }
    }
    private(set) var isPaid: Bool = false {
        didSet {
            self.delegate?.displayPaidStateUpdate(isPaid: isPaid)
        }
    }
    private(set) var sessionBalanceCurrency: PaidSessionBalance? {
        didSet {
            isSeleb = (sessionBalanceCurrency != nil && currentUserId != nil) && (sessionBalanceCurrency?.recipientId == currentUserId || sessionBalanceCurrency?.payerId != currentUserId)
            if let balance = sessionBalanceCurrency {
                self.delegate?.displayPaidSessionBalance(balance: balance)
                /*
                if let isAutoDeposit = balance.isAutoDeposit {
                    let desc: String = "5 koin ditambahkan ke dalam deposit"
                    self.delegate?.displayError(message: desc)
                }
                 */
            }
        }
    }
    private(set) lazy var msgManager: TXIMMessageManager = {
        let manager = TXIMMessageManager(userId: self.userID)
        manager.isPaidChat = isPaid
        manager.addTXIMListener()
        manager.delegate = self
        return manager
    }()
    
    private let paidChatPriceAdapter: PaidChatPriceInteractorAdapter
    private let paidSessionBalanceAdapter: PaidSessionBalanceInteractorAdapter
    private let chatSessionAdapter: ChatSessionInteractorAdapter
    private let confirmationSetDiamondAdapter: ConfirmationSetDiamondInteractorAdapter
    private let notificationAdapter: OneSignalNotificationInteractorAdapter
    private let chatProfileAdapter: ChatProfileInteractorAdapter
    private let allowCallAdapter: AllowCallInteractorAdapter

    init(
        paidChatPriceAdapter: PaidChatPriceInteractorAdapter,
        paidSessionBalanceAdapter: PaidSessionBalanceInteractorAdapter,
        chatSessionAdapter: ChatSessionInteractorAdapter,
        confirmationSetDiamondAdapter: ConfirmationSetDiamondInteractorAdapter,
        notificationAdapter: OneSignalNotificationInteractorAdapter,
        chatProfileAdapter: ChatProfileInteractorAdapter,
        allowCallAdapter: AllowCallInteractorAdapter,
        serviceManager: DirectMessageCallServiceManager,
        userID: String,
        name: String,
        avatar: String,
        isVerified: Bool = false,
        forwardMessages: [TXIMMessage] = []
    ) {
        self.paidChatPriceAdapter = paidChatPriceAdapter
        self.paidSessionBalanceAdapter = paidSessionBalanceAdapter
        self.chatSessionAdapter = chatSessionAdapter
        self.confirmationSetDiamondAdapter = confirmationSetDiamondAdapter
        self.notificationAdapter = notificationAdapter
        self.chatProfileAdapter = chatProfileAdapter
        self.allowCallAdapter = allowCallAdapter
        self.serviceManager = serviceManager
        self.userID = userID
        self.name = name.isEmpty ? userID : name
        self.avatar = avatar
        self.isVerified = isVerified
        
        var userIdList = [userID, TXIMUserManger.shared.currentUserId ?? ""]
        userIdList.sort( by: { UInt64($0) ?? 0 < UInt64($1) ?? 0 } )
        self.channelURL = userIdList.joined(separator: "_")
        self.forwardMessages = forwardMessages
        
        super.init()
    }
    
    func getUserInfo() {
        print("【DM】start get userInfo of \(userID)")
        TXIMUserManger.shared.getUsersInfo([userID]) { [weak self] userList in
            if let self {
                if let user = userList.first {
                    self.name = user.nickName.isEmpty ? userID : user.nickName
                    self.avatar = user.faceURL
                    self.isVerified = user.isVerified
                    self.delegate?.displayUserInfoUpdate()
                }
            }
        } failure: { _ in }
    }

    func loadInitialMessages() {
        msgManager.loadInitMessages()
    }
    
    func loadPreviousMessages() {
        msgManager.loadPreviousMessages()
    }
    
    func deleteMessages(_ messages: [TXIMMessage], completion: @escaping (Bool, NSError?) -> Void) {
        msgManager.deleteMessages(messages, completion: completion)
    }
    
    func revokeMessage(_ message: TXIMMessage, completion: @escaping (Bool, NSError?) -> Void) {
        msgManager.revokeMessage(message, completion: completion)
    }
    
    func clearUnreadCount(before cleanTimestamp: UInt64) {
        msgManager.clearUnreadCount(before: cleanTimestamp)
    }
    
    func clearAllUnreadCount() {
        msgManager.clearAllUnreadCount()
    }
    
    @discardableResult func sendMessage(with value: String, quote quoteMsg: TXIMMessage? = nil) -> TXIMMessage? {
        let message = msgManager.sendTextMessage(with: value, quote: quoteMsg)
        return message
    }
    
    @discardableResult func sendMediaMessage(media: ImagePickerMediaFile, quote quoteMsg: TXIMMessage? = nil) -> TXIMMessage? {
        let size: CGSize = CGSize(width: (media.thumbnail?.size.width ?? 0), height: (media.thumbnail?.size.height ?? 0))
        if media.isVideo == true {
            let message = msgManager.sendVideoMessage(with: media.data, size: size, quote: quoteMsg) { progress in
                print("【DM】send image message progress \(progress)")
            }
            return message
        } else {
            let message = msgManager.sendImageMessage(with: media.data, size: size, quote: quoteMsg) { progress in
                print("【DM】send image message progress \(progress)")
            }
            return message
        }
    }
    
    func sendPushNotifMessage(message: TXIMMessage) {
        var text: String = ""
        if message.type == .text {
            text = message.text ?? ""
        } else if message.type == .image {
            text = "image"
        } else if message.type == .video {
            text = "video"
        }
        let userId = UserManager.shared.accountId ?? ""
        let nickName = UserManager.shared.username ?? ""
        let profileURL = UserManager.shared.userAvatarUrl ?? ""
        let isVerify = UserManager.shared.userVerify ?? false
        let isVerifiedStr = isVerify ? "true" : "false"
        notificationAdapter.send(
            param: .init(
                includeExternalUserIds: [userID],
                data: .init(
                    from: "chat",
                    channelURL: channelURL,
                    senderAccountId: userId,
                    senderName: nickName,
                    senderIsVerified: isVerifiedStr,
                    senderImageURL: profileURL
                ),
                contents: .init(en: text),
                smallIcon: "ic_stat_onesignal_default",
                headings: .init(en: "\(nickName)"),
                contentAvailable: true
            )) { _ in }
    }
    
    func updatePaidMessage(isPaid: Bool) {
        delegate?.displayLoading(isLoading: true)
        
        chatSessionAdapter.load(
            channelParam: .init(
                channelURL: channelURL,
                isPaid: isPaid
            ),
            chatParam: .init(
                externalChannelId: channelURL,
                payerId: TXIMUserManger.shared.currentUserId ?? "",
                recipientId: userID
            )
        ) { [weak self] result in
            guard let self = self else { return }
            
            delegate?.displayLoading(isLoading: false)
            
            var success: Bool = false
            
            switch result {
            case .success:
                success = true
                
            case let .failure(error):
                if case let .general(reason) = error {
                    if reason.errorCode == "9003" {
                        self.delegate?.displayInsufficientBalance()
                    } else if reason.errorCode == "4200" {
                        success = true
                    }
                }
            }
            
            if success {
                msgManager.isPaidChat = isPaid
                msgManager.sendCustomMessage(startPaidChat: isPaid)
                self.isPaid = isPaid
            }
        }
    }
    
    func requestSessionBalanceCurrency() {
        paidSessionBalanceAdapter.load(channelURL) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(balance):
                msgManager.isPaidChat = true
                self.isPaid = true
                
                sessionBalanceCurrency = balance
                msgManager.balance = balance
            case .failure:
                msgManager.isPaidChat = false
                self.isPaid = false
            }
        }
    }
    
    func getDiamondPrice() {
        paidChatPriceAdapter.load(by: userID) { [weak self] result in
            switch result {
            case .success(let price):
                self?.delegate?.displayChatPrice(price: price)
            case .failure(_):
                self?.delegate?.displayChatPrice(price: nil)
            }
        }
    }
    
    func confirmationNewPrice() {
        confirmationSetDiamondAdapter.confirm(
            chatParam: .init(
                externalChannelId: channelURL,
                payerId: sessionBalanceCurrency?.payerId ?? "",
                recipientId: sessionBalanceCurrency?.recipientId ?? ""
            )
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(data):
                self.delegate?.displayConfirmationNewPriceSuccess(value: data)
            case let .failure(error):
                if case let .general(reason) = error {
                    if reason.errorCode == "9003" {
                        self.delegate?.displayInsufficientBalance()
                    } else {
                        self.delegate?.displayConfirmationNewPriceError()
                    }
                }
            }
        }
    }
    
    func startCall(isAudio: Bool) {
        allowCallAdapter.load(by: userID) { [weak self] result in
            switch result {
            case .success(let success):
                if success.isMutual {
                    if isAudio == true {
                        self?.startVoiceCall()
                    } else {
                        self?.startVideoCall()
                    }
                } else {
                    self?.delegate?.displayError(message: "Tersedia setelah mengikuti satu sama lain")
                }
            case .failure(let failure):
                let desc: String = "Gagal memuat data.\n\(failure.localizedDescription)"
                self?.delegate?.displayError(message: desc)
            }
        }
    }
    
    func requestUserProfile(by username: String) {
        self.delegate?.displayLoading(isLoading: true)
        
        chatProfileAdapter.load(with: username) { [weak self] result in
            guard let self = self else { return }
            
            self.delegate?.displayLoading(isLoading: false)
            switch result {
            case .success(let response):
                self.delegate?.displayUserProfile(data: response)
            case .failure(let error):
                if case .general(_) = error {
                    self.delegate?.displayError(message: "User tidak ditemukan, silahkan coba lagi..")
                }
            }
        }
    }
    
    func clearHistoryMessage() {
        msgManager.clearHistoryMessage()
    }
    
    func updateEmojiReaction(message: TXIMMessage, emoji: String) {
        if let myReaction = message.myReaction {
            msgManager.removeEmoji(message: message, emoji: myReaction) { _ in}
            if myReaction != emoji {
                msgManager.addEmoji(message: message, emoji: emoji) { _ in}
            }
        } else {
            msgManager.addEmoji(message: message, emoji: emoji) { _ in}
        }
    }
    
    func sendMessageReadReceipts(_ messages: [TXIMMessage]) {
        msgManager.sendMessageReadReceipts(messages)
    }
    
    func getBlockRelationship() {
        let endpoint: Endpoint<BlockRelationship?> = Endpoint(
            path: "blockRelationship",
            method: .get,
            queryParameters: ["accountId": userID]
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(_):
                print("【DM】get blockRelationship failure")
            case .success(let response):
                print("【DM】get blockRelationship success")
                let data = response?.data
                let isBlocked: Bool = data?.isBlocked ?? false
                self.isBlockUser = isBlocked
            }
        }
    }
    
    func updateBlockRelationship(isBlock: Bool) {
        struct Root: Codable {
            var code: String?
            var message: String?
        }
        
        let endpoint: Endpoint<Root?> = Endpoint(
            path: "blockRelationship",
            method: .put,
            bodyParamaters: ["accountId": userID, "enabled":false]
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(_):
                print("【DM】removeDefriend failure")
            case .success(_):
                print("【DM】removeDefriend success")
                self.delegate?.displayUnBlockAlert()
                msgManager.sentLockMessage(isLock: false)
                self.isBlockUser = false
            }
        }
    }
}

// MARK: - TXIMMessageManagerDelegate
extension ConversationInteractor: TXIMMessageManagerDelegate {
    func didMessageClear(with messageManager: TXIMMessageManager) {
        self.messages = []
        delegate?.displayMessagesClear()
    }
    
    func messageManager(_ messageManager: TXIMMessageManager, didMessageUpdate messages: [TXIMMessage]) {
        print("【DM】conversation interactor load messages \(messages.count)")
        
        self.messages = messageManager.messageList
        delegate?.displayUpdateMessages(messages: messages)
        
        if forwardMessages.count > 0 {
            msgManager.forwardMessages(forwardMessages)
            forwardMessages.removeAll()
        }
    }
    
    func messageManager(_ messageManager: TXIMMessageManager, didMessageDelete messages: [TXIMMessage]) {
        print("【DM】conversation interactor messages delete")
        
        self.messages = messageManager.messageList
        delegate?.displayDeleteMessages(messages: messages)
    }
    
    func messageManager(_ messageManager: TXIMMessageManager, didMessageReceive message: TXIMMessage) {
        print("【DM】conversation interactor receive message")
        
        self.messages = messageManager.messageList
        delegate?.displayReceiveMessage(message: message)
    }
    
    func messageManager(_ messageManager: TXIMMessageManager, didMessageForward messages: [TXIMMessage]) {
        print("【DM】conversation interactor message forward")
        
        self.messages = messageManager.messageList
        delegate?.displayForwardMessages(messages: messages)
    }
    
    func didMessageRevoke(with messageManager: TXIMMessageManager) {
        
        self.messages = messageManager.messageList
        delegate?.displayRevokeMessage(messages: messages)
    }
    
    func messageManager(_ messageManager: TXIMMessageManager, didLoadMessageError error: Error) {
        print("【DM】conversation interactor receive error \(error.localizedDescription)")
        
        let desc: String = "Gagal memuat data.\n\(error.localizedDescription)"
        delegate?.displayError(message: desc)
    }
    
    func messageManager(_ messageManager: TXIMMessageManager, didMessageSent message: TXIMMessage) {
        print("【DM】conversation interactor sent message")
        
        self.messages = messageManager.messageList
        delegate?.displaySentMessage(message: message)
    }
    
    func messageManager(_ messageManager: TXIMMessageManager, didMessageSentSuccess message: TXIMMessage) {
        print("【DM】didMessageSent success")
        
        self.delegate?.displaySentMessageSuccess(message: message)
    }
    
    func messageManager(_ messageManager: TXIMMessageManager, didMessageSentFailure message: TXIMMessage, error: NSError) {
        print("【DM】didMessageSent error \(error)")
        
        self.delegate?.displaySentMessageFailure(error: error)
        
        guard isSeleb != false else {
            return
        }
        
        if let desc = error.userInfo[NSLocalizedDescriptionKey] as? String,
            desc.isEmpty == false,
            let jsonData = desc.data(using: .utf8),
            let dict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
            let code = dict["code"] as? Int {
            if code == 4300 {
                let result = try? JSONDecoder().decode(RemoteErrorConfirmSetDiamondResult.self, from: jsonData)
                self.delegate?.displayChatPriceChanged(value: result?.data)
            } else if code == 9003 {
                self.delegate?.displayInsufficientBalance()
            }
        }
    }
    
    func messageManager(_ messageManager: TXIMMessageManager, didPaidChatStatusChanged isPaid: Bool) {
        self.isPaid = isPaid
        print("【DM】TXIMMessageManager didPaidChatStatusChanged: \(isPaid)")
    }
    
    func messageManager(_ messageManager: TXIMMessageManager, didReceiveCloudCustomData balance: PaidSessionBalance) {
        sessionBalanceCurrency = balance
        print("【DM】TXIMMessageManager didReceiveCloudCustomData")
    }
}

// MARK: - TUICall Related Private Methods
extension ConversationInteractor {
    private func startVoiceCall() {
        guard let currentUserId = TXIMUserManger.shared.currentUserId else {
            return
        }
        let roomId = userID + "_" + currentUserId
        let request = CallLoaderRequest(roomId: roomId, userId: userID, type: .audio, pushInfo: serviceManager.requestPushInfo?())
        serviceManager.loader.call(with: request, completion: didCall(with:))
    }
    
    private func startVideoCall() {
        guard let currentUserId = TXIMUserManger.shared.currentUserId else {
            return
        }
        let roomId = userID + "_" + currentUserId
        let request = CallLoaderRequest(roomId: roomId, userId: userID, type: .video, pushInfo: serviceManager.requestPushInfo?())
        serviceManager.loader.call(with: request, completion: didCall(with:))
    }
    
    private func didCall(with result: Swift.Result<Void, Error>) {
        switch result {
        case .success(_):
            print("Call Feature: call success")
            break
        case .failure(let failure):
            print("Call Feature: call fail", failure.localizedDescription)
            break
        }
    }
}
