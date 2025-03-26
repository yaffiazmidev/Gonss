//
//  ConversationViewController.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 15/07/23.
//

import UIKit
import KipasKipasDirectMessage
import KipasKipasShared

protocol IConversationViewController: AnyObject {
    func displayLoading(isLoading: Bool)
    func displayError(message: String)
    func displayUserProfile(data: ChatProfile)
    func displayUserInfoUpdate()
    
    func displayMessagesClear()
    func displayDeleteMessages(messages: [TXIMMessage])
    func displayUpdateMessages(messages: [TXIMMessage])
    func displayRevokeMessage(messages: [TXIMMessage])
    func displayReceiveMessage(message: TXIMMessage)
    func displaySentMessage(message: TXIMMessage)
    func displaySentMessageSuccess(message: TXIMMessage)
    func displaySentMessageFailure(error: NSError)
    func displayForwardMessages(messages: [TXIMMessage])
    
    func displayPaidSessionBalance(balance: PaidSessionBalance)
    func displayChatPrice(price: Int?)
    func displayPaidStateUpdate(isPaid: Bool)
    
    func displayInsufficientBalance()
    func displayChatPriceChanged(value: RemoteErrorConfirmSetDiamondData?)
    func displayConfirmationNewPriceSuccess(value: RemoteSetDiamondData)
    func displayConfirmationNewPriceError()
    
    func displayYouBlockUser(isBlock: Bool)
    func displayUnBlockAlert()
}

public class ConversationViewController: UIViewController, UIGestureRecognizerDelegate, NavigationAppearance {
    private lazy var mainView: ConversationView = {
        let view = ConversationView().loadViewFromNib() as! ConversationView
        view.delegate = self
        view.isPaid = self.interactor.isPaid
        return view
    }()
    
    public var userID: String {
        get {
            self.interactor.userID
        }
    }
    private var name: String {
        get {
            self.interactor.name
        }
    }
    private var avatar: String {
        get {
            self.interactor.avatar
        }
    }
    private var isVerified: Bool {
        get {
            self.interactor.isVerified
        }
    }
    
    private var messageList: [TXIMMessage] = [] {
        didSet {
            mainView.messageList = messageList
        }
    }
    
    private var isLoading: Bool = false {
        didSet {
            DispatchQueue.main.async { self.isLoading ? KKDefaultLoading.shared.show() : KKDefaultLoading.shared.hide() }
        }
    }
    
    var interactor: ConversationInteractor!
    var router: IConversationRouter!
    private var selecting: Bool = false
    private let handleTapPatnerProfile: ((String?) -> Void)
    private let handleTapHashtag: ((String?) -> Void)
    private let showCameraPhotoVideo: ((@escaping (KKMediaItem) -> Void) -> Void)
    private let handleTapForward: (([TXIMMessage]) -> Void)
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        
        interactor.loadInitialMessages()
        //TODO: close Paid temply
//        interactor.requestSessionBalanceCurrency()
//        interactor.getDiamondPrice()
        interactor.getBlockRelationship()
        
        NotificationCenter.default.addObserver(self, selector: #selector(forwardMessages), name: .init("forwardMessages"), object: nil)
    }
    
    public init(
        handleTapPatnerProfile: @escaping ((String?) -> Void),
        handleTapHashtag: @escaping ((String?) -> Void),
        showCameraPhotoVideo: @escaping ((@escaping (KKMediaItem) -> Void) -> Void),
        handleTapForward: @escaping (([TXIMMessage]) -> Void)
    ) {
        self.handleTapPatnerProfile = handleTapPatnerProfile
        self.handleTapHashtag = handleTapHashtag
        self.showCameraPhotoVideo = showCameraPhotoVideo
        self.handleTapForward = handleTapForward
        super.init(nibName: "ConversationViewController", bundle: SharedBundle.shared.bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        view = mainView
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        mainView.keyboardObserver.add()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        setupNavigationBar(color: .white, tintColor: .black, shadowColor: .softPeach)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        interactor.getUserInfo()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        mainView.allowDismissKeyboard = true
        mainView.isTyping = !self.mainView.isEmptyInputMessageField()
        self.view.endEditing(true)
        mainView.inputMessageTextViewHeightConstraint.constant = 32
        mainView.layoutIfNeeded()
        
        mainView.keyboardObserver.remove()
    }
    
    private func setupNavigationItem() {
        var leftBarButtonItems = mainView.makeLeftBarButtonItems(userName: name, avatar: avatar, isVerify: isVerified)
        if !selecting {
            leftBarButtonItems.insert(makeDefaultNavBarBackButton(), at: 0)
            navigationItem.leftBarButtonItems = leftBarButtonItems
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(customView: mainView.settingButton),
                UIBarButtonItem(customView: mainView.voiceCallButton),
                UIBarButtonItem(customView: mainView.videoCallButton)
            ]
        } else {
            navigationItem.leftBarButtonItems = leftBarButtonItems
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(customView: mainView.cancleSelectButton)
            ]
        }
    }
    
    private func handleSendMessage() {
        let trimMessage = mainView.inputMessageTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        mainView.inputMessageTextView.text = trimMessage
        
        mainView.isTyping = false
        mainView.allowDismissKeyboard = true
        mainView.inputMessageTextViewHeightConstraint.constant = 32
        mainView.layoutIfNeeded()

        guard let message = mainView.inputMessageTextView.text, !message.isEmpty else { return }
        
        mainView.inputMessageTextView.text = ""
        
        interactor.sendMessage(with: message, quote: mainView.replyMsg)
        mainView.messageSent()
    }
    
    private func showCamera() {
        showCameraPhotoVideo({ [weak self] media in
            guard let self = self else { return }
            let extFile = NSString(string: media.path).lastPathComponent
            let ext = NSString(string: media.path).pathExtension
            let messageType = media.type == .photo ? "image" : "video"
            let mimeType = "\(messageType)/\(ext)"
            
            let thumbnail = messageType == "image" ? media.photoThumbnail : media.videoThumbnail
            
            let mediaFile = ImagePickerMediaFile(data: media.data ?? Data(), name: extFile, mimeType: mimeType, isVideo: media.type == .video, thumbnail: thumbnail)
            self.interactor.sendMediaMessage(media: mediaFile, quote: mainView.replyMsg)
            mainView.messageSent()
        })
    }
    
    @objc func forwardMessages(noti: Notification) {
        mainView.cancelMultipleSelection()
    }
}

extension ConversationViewController: ConversationViewDelegate {
    func didTapHashtag(with hashtag: String) {
        handleTapHashtag(hashtag)
    }

    func didTapMention(with username: String) {
        interactor.requestUserProfile(by: username)
    }

    func didTapLink(with url: URL) {
        router.openSafariWithURL(url)
    }

    func didTapPatnerProfile() {
        handleTapPatnerProfile(userID)
    }
    
    func didStopPaidMessage() {
        router.presentPopUpStopPaidMessage(stopPaidMessageHandler: { [weak self] in
            guard let self = self else { return }
            
            self.interactor.updatePaidMessage(isPaid: false)
        })
    }
    
    func didStartPaidMessage() {
        interactor.updatePaidMessage(isPaid: true)
    }
    
    func didTapLearnMorePaidDM() {
        router.presentLearnMorePaidDM()
    }
    
    func didTapSendMessageButton() {
        mainView.allowDismissKeyboard = !mainView.isTyping
        view.endEditing(!mainView.isTyping)
        mainView.isTyping ? handleSendMessage() : showCamera()
    }
    
    func didTapSettingButton() {
        router.presentDeleteAllActionSheet(userName: self.name) {[weak self] in
            guard let self = self else { return }
            self.interactor.clearHistoryMessage()
        }
    }

    func didTapVoiceCallButton() {
        interactor.startCall(isAudio: true)
    }
    
    func didTapVideoCallButton() {
        interactor.startCall(isAudio: false)
    }
    
    func didTapUnblock() {
        router.presentPupUpUnBlockPatner(patnerNickname: name) { [weak self] in
            guard let self = self else { return }
            self.interactor.updateBlockRelationship(isBlock: false)
        }
    }
    
    func didTapMedia(isVideo: Bool, url: URL?) {
        if isVideo == true {
            router.presentVideo(with: url)
        } else {
            router.presentImage(with: url)
        }
    }
    
    func didTapDeleteButton(with messages: [TXIMMessage]) {
        router.presentDeleteActionSheet(messageCount: messages.count) {[weak self] in
            guard let self = self else { return }
            self.isLoading = true
            self.interactor.deleteMessages(messages) { [weak self] success, error in
                guard let self = self else { return }
                self.isLoading = false
                if success {
                    self.mainView.cancelMultipleSelection()
                    self.displayError(message: "\(messages.count) pesan terhapus untuk saya")
                } else {
                    self.presentAlert(title: "Tidak ada koneksi internet, periksa dan coba lagi.", message: "")
                }
            }
        }
    }
    
    func didTapForwardButton(with messages: [TXIMMessage]) {
        if messages.count > 0 {
            handleTapForward(messages)
        }
        print("【DM】\(messages.count) messages were forwarding")
    }
    
    func didTapRevokeMessage(with message: TXIMMessage) {
        router.presentRevokeActionSheet() {[weak self] in
            guard let self = self else { return }
            self.interactor.revokeMessage(message) { [weak self] success, error in
                guard let self = self else { return }
                if success {
                    self.mainView.tableView.reloadData()
                } else {
                    self.presentAlert(title: "Tidak ada koneksi internet, periksa dan coba lagi.", message: "")
                }
            }
        }
    }
    
    func didSelectEmoji(with message: TXIMMessage, emoji: String) {
        interactor.updateEmojiReaction(message: message, emoji:emoji)
    }
    
    func loadPreviousMessages() {
        interactor.loadPreviousMessages()
    }
    
    func tableViewDidScroll() {
        if let index = self.mainView.tableView.indexPathsForVisibleRows?.last {
            if index.row < self.messageList.count {
                let message = self.messageList[index.row]
                interactor.clearUnreadCount(before: UInt64(message.timestamp.timeIntervalSince1970))
            }
        }
    }
    
    func isChatUserVerified() -> Bool {
        return isVerified
    }
    
    func updateNavigationBarForSelection(with select: Bool) {
        selecting = select
        setupNavigationItem()
    }
    
    func didStopScrollForSecond() {
        if let firstIndexPath = self.mainView.tableView.indexPathsForVisibleRows?.first,
           let lastIndexPath = self.mainView.tableView.indexPathsForVisibleRows?.last,
           firstIndexPath.row >= 0, lastIndexPath.row < self.messageList.count {
            let msgs: [TXIMMessage] = Array(self.messageList[firstIndexPath.row...lastIndexPath.row])
            if msgs.count > 0 {
                interactor.sendMessageReadReceipts(msgs)
            }
        }
    }
}

extension ConversationViewController: IConversationViewController {
    func displayLoading(isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    func displayError(message: String) {
        showToast(
            with: message,
            backgroundColor: UIColor.azure,
            isOnTopScreen: true,
            verticalSpace: 80
        )
    }
    
    func displayUserProfile(data: ChatProfile) {
        handleTapPatnerProfile(data.id)
    }
    
    func displayUserInfoUpdate() {
        setupNavigationItem()
    }
    
    func displayMessagesClear() {
        self.messageList = interactor.messages
        mainView.tableView.reloadData()
    }
    
    func displayDeleteMessages(messages: [TXIMMessage]) {
        self.messageList = interactor.messages
        mainView.tableView.reloadData()
    }
    
    func displayUpdateMessages(messages: [TXIMMessage]) {
        let firstPage = self.messageList.isEmpty
        if self.messageList.isEmpty {
            self.messageList = interactor.messages
            mainView.tableView.reloadData()
            mainView.scrollToLastMessage(force: true)
        } else {
            let insertCount = interactor.messages.count - self.messageList.count
            self.messageList = interactor.messages
            self.mainView.scrollToStayWithMessageInsert(count: insertCount)
        }
    }
    
    func displayRevokeMessage(messages: [TXIMMessage]) {
        mainView.tableView.reloadData()
    }
    
    func displayReceiveMessage(message: TXIMMessage) {
        self.messageList = interactor.messages
        mainView.tableView.reloadData()
        mainView.scrollToLastMessage(force: false)
    }
    
    func displaySentMessage(message: TXIMMessage) {
        self.messageList = interactor.messages
        mainView.tableView.reloadData()
        mainView.scrollToLastMessage(force: true)
    }
    
    func displaySentMessageSuccess(message: TXIMMessage) {
        interactor.sendPushNotifMessage(message:message)
    }
    
    func displaySentMessageFailure(error: NSError) {
        
    }
    
    func displayForwardMessages(messages: [TXIMMessage]) {
        self.messageList = interactor.messages
        mainView.tableView.reloadData()
        mainView.scrollToLastMessage(force: true)
        for msg in messages {
            if msg.status == .send_succ {
                interactor.sendPushNotifMessage(message:msg)
            }
        }
    }
    
    func displayPaidSessionBalance(balance: PaidSessionBalance) {
        //TODO: close Paid temply
//        DispatchQueue.main.async {
//            self.mainView.updateHeaderView(diamond: balance.diamond, coin: balance.coin, deposit: balance.deposit, isSeleb: self.interactor.isSeleb)
//        }
    }
    
    func displayChatPrice(price: Int?) {
        //TODO: close Paid temply
//        DispatchQueue.main.async {
//            self.mainView.updateFooterView(price: price)
//        }
    }
    
    func displayPaidStateUpdate(isPaid: Bool) {
        //TODO: close Paid temply
//        guard mainView.isPaid != isPaid else {
//            return
//        }
//        if isPaid == true {
//            interactor.requestSessionBalanceCurrency()
//        } else {
//            interactor.getDiamondPrice()
//        }
//        mainView.isPaid = isPaid
    }
    
    func displayInsufficientBalance() {
        presentKKPopUpView(
            title: "Yah koin yang kamu punya tidak cukup untuk memulai sesi pesan berbayar",
            message: "Beli Koin kipaskipas kamu atau akhiri sesi ini terlebih dahulu.",
            imageName: "imageSad",
            cancelButtonTitle: "Kirim Pesan Biasa",
            actionButtonTitle: "Beli Koin Kipaskipas"
        ) { [weak self] in
            guard let self = self else { return }
            self.router.navigateToPurchaseCoin()
        } onCancelTap: { [weak self] in
            guard let self = self else { return }
            self.interactor.updatePaidMessage(isPaid: false)
        }
    }
    
    func displayChatPriceChanged(value: RemoteErrorConfirmSetDiamondData?) {
        presentKKPopUpViewWithImageAndText(
            title: "Perubahan Harga Pesan Berbayar",
            message: "Pemilik akun telah mengubah tarif pesan berbayar, kamu bisa memilih untuk menghentikan sesi yang sedang berlangsung atau melanjutkan dengan harga pesan berbayar terbaru.",
            isHiddenCloseButton: true,
            cancelButtonTitle: "Akhiri Pesan Berbayar",
            actionButtonTitle: "Lanjutkan Pesan Berbayar",
            imageName: "img_coin_gold",
            secondTitle: "\(value?.updatedPrice ?? 1) Coin / Pesan Dibalas (Terbaru)",
            secondSubtitle: "\(value?.currentPrice ?? 1) Coin / Pesan Dibalas (Sebelumnya)",
            isHidden: false) { [weak self] in
                guard let self = self else { return }
                self.interactor.confirmationNewPrice()
            } onCancelTap: { [weak self] in
                guard let self = self else { return }
                self.interactor.updatePaidMessage(isPaid: false)
                self.interactor.getDiamondPrice()
            }
    }
    
    func displayConfirmationNewPriceSuccess(value: RemoteSetDiamondData) {
        DispatchQueue.main.async {
            self.mainView.updateHeaderView(diamond: value.diamond, coin: value.coin, deposit: value.deposit, isSeleb: self.interactor.isSeleb)
        }
    }
    
    func displayConfirmationNewPriceError() {
        let vc = FailedSetDiamondViewController()
        vc.hidesBottomBarWhenPushed = true
        self.present(vc, animated: true)
    }
    
    func displayYouBlockUser(isBlock: Bool) {
        mainView.updateBlockByMeUI(block: isBlock, name: name)
    }
    
    func displayUnBlockAlert() {
        presentAlert(title: "Buka blokir", message: "Anda berhasil membuka blokir \(name)")
        NotificationCenter.default.post(name: .init("onReceiveConversationLock"), object: "c2c_\(userID)")
    }
}
