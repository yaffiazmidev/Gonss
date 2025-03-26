import UIKit
import KipasKipasLiveStream
import KipasKipasShared
import KipasKipasTRTC
import AVFoundation

extension  Notification.Name {
    static let pushNotifForLiveStart = Notification.Name("pushNotifForLiveStart")
}

public final class AnchorViewController: ContainerViewController {
    
    private lazy var preLiveToolbar = {
        let toolbar = AnchorPreLiveToolbarViewController()
        toolbar.delegate = self
        return toolbar
    }()
    
    private lazy var onLiveToolbar = {
        let toolbar = AnchorOnLiveToolbarViewController()
        toolbar.delegate = self
        toolbar.setBottomToolbarHorizontalInsets(20)
        return toolbar
    }()
    
    private lazy var liveStreamEndedController = {
        let controller = AnchorLiveStreamEndedViewController()
        controller.modalPresentationStyle = .overFullScreen
        return controller
    }()
    
    private lazy var liveStreamPausedController = {
        let controller = LiveStreamPausedViewController()
        controller.modalPresentationStyle = .overCurrentContext
        return controller
    }()
    
    private var isVideoPaused: Bool = false
    
    private lazy var countdownController = CountDownViewController()
    
    private lazy var startNewLiveConfirmationController = {
        let alert = UIAlertController(
            title: "Kamu sedang live di perangkat lain",
            message: "Memulai live akan membuat live di perangkat lain berhenti, yakin memulai live di perangkat ini?",
            preferredStyle: .alert
        )
        alert.setTitleFont(.roboto(.bold, size: 14))
        alert.setMessageFont(.roboto(.regular, size: 12))
        
        let ok = UIAlertAction(title: "Live Disini", style: .default) { [weak self] _ in
            self?.createNewRoom()
        }
        
        let cancel = UIAlertAction(title: "Batalkan", style: .default)
        
        alert.overrideUserInterfaceStyle = .dark
        alert.addAction(cancel)
        alert.addAction(ok)
        
        return alert
    }()
    
    private lazy var endLiveConfirmationController = {
        let alert = UIAlertController(
            title: "",
            message: "Apakah kamu yakin ingin mengakhiri sesi live ini?",
            preferredStyle: .alert
        )
        alert.setMessageFont(.roboto(.bold, size: 14))
        
        let ok = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.endLiveStreaming()
        }
        
        let cancel = UIAlertAction(title: "Batalkan", style: .default)
        
        alert.overrideUserInterfaceStyle = .dark
        alert.addAction(cancel)
        alert.addAction(ok)
        
        return alert
    }()
    
    private lazy var chatInputView = {
        let view = LiveRoomChatInputView()
        view.onTapSend = { [weak self] message in
            guard let self = self else { return }
            liveRoom.sendMessage(message, to: roomId)
        }
        return view
    }()
    
    private lazy var chatView = LiveRoomChatView()
    
    private var streamId: String = ""
    private var roomName: String = ""
    private var roomOwnerName: String = ""
    private var userId: String = ""
    private var roomId: String = ""
    
    var onLoadProfile: (() -> Void)?
    var onCreateNewRoom: ((_ roomName: String) -> Void)?
    var onValidateRoom: (() -> Void)?
    var onLeaveRoomWithoutLive: (() -> Void)?
    var onDestroyRoom: ((LiveRoomSummaryViewModel) -> Void)?
    var onAudienceClicked: ((String, String,@escaping()->Void,@escaping()->Void) -> Void)?
    var onDailyRankClicked: ((Bool,@escaping()->Void) -> Void)?
    
    private let liveRoom: AnchorLiveRoomManager
    private let audienceListAdapter: LiveStreamAudienceListAdapter
    
    init(
        liveRoom: AnchorLiveRoomManager,
        audienceListAdapter: LiveStreamAudienceListAdapter
    ) {
        self.liveRoom = liveRoom
        self.audienceListAdapter = audienceListAdapter
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    public override func loadView() {
        view = PassthroughView()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        liveRoom.giftDelegate = onLiveToolbar.giftPlayView
        
        onLoadProfile?()
        
        transition(
            to: preLiveToolbar,
            ignoreSafeArea: false
        ) { [weak self] in
            self?.preLiveToolbar.showToolbar()
        }
        
        addObserver()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        liveRoom.startCameraPreview(in: view)
    }
    
    
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        liveRoom.stopCamera()
    }
     
    
    private func configureChatView() {
        appWindow?.addSubview(chatInputView)
        chatInputView.anchors.edges.pin()
        
        liveRoom.chatDelegate = chatView
        onLiveToolbar.addBottomToolbarToFirstIndex(chatView)
        chatView.anchors.height.equal(onLiveToolbar.view.anchors.height * 0.3)
    }
}

// MARK: Pre Live
extension AnchorViewController: AnchorPreLiveToolbarDelegate {
    func preliveDidLiveCancel() {
        onLeaveRoomWithoutLive?()
    }
    
    func preliveDidStartLive(roomName: String) {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            self.roomName = roomName
            onValidateRoom?()
        } else {
            let settings = UIAlertAction(
                title: "Pengaturan",
                style: .default,
                handler: { _ in UIViewController.openSettings() }
            )
            settings.titleTextColor = .night
            
            let cancel = UIAlertAction(title: "Batal", style: .destructive)
            
            showAlertController(
                title: "Akses kamera tidak diizinkan",
                titleFont: .roboto(.bold, size: 18),
                message: "\nUntuk menggunakan LIVE, akses kamera harus diizinkan. \n\nKamu bisa mengubah izin akses kamera di pengaturan.\n",
                messageFont: .roboto(.regular, size: 14),
                backgroundColor: .white,
                actions: [settings, cancel]
            )
        }
    }
    
    private func createNewRoom() {
        onCreateNewRoom?(roomName)
    }
    
    private func createTRTCLiveRoom(roomId: String) {
        let parameter = LiveRoomParameter(
            roomId: roomId,
            ownerId: userId,
            roomName: roomName
        )
        
        let invisibleView = UIView()
        invisibleView.anchors.height.equal(8)
        invisibleView.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        onLiveToolbar.addBottomToolbarToFirstIndex(invisibleView)
        configureChatView()
        
        liveRoom.createRoom(parameter: parameter) { [weak self] error in
            guard error == nil else {
                self?.showToast(with: error?.localizedDescription ?? ""  )
                return
            }
            
            self?.preLiveToolbar.hideToolbar { [weak self] in
                NotificationCenter.default.post(name: .pushNotifForLiveStart, object: nil)
                self?.showCountdown(with: parameter)
            }
        }
    }
    
    func showCountdown(with parameter: LiveRoomParameter) {
        countdownController.onCountdownFinished = { [weak self] in
            guard let self = self else { return }
            liveRoom.startLiveStreaming(parameter: parameter, view: view)
            getAudienceList()
            NotificationCenter.default.post(name: .pushNotifForLiveStart, object: nil)
            transition(
                to: onLiveToolbar,
                ignoreSafeArea: false
            ) { [weak self] in
                self?.onLiveToolbar.showToolbar()
                self?.onLiveToolbar.startTimerDuration()
            }
        }
        
        transition(to: countdownController)
    }
}

// MARK: On Live
extension AnchorViewController: AnchorOnLiveToolbarDelegate {
    func onClickAudience() {
        onAudienceClicked?(
            String(roomId),
            userId,
            {},
            audienceListToTCWeb
        )
    }
    
    func audienceListToTCWeb(){
        dismiss(animated: false) {
            let controller = TeamConditionViewController()
            let navigation = PanNavigationViewController(rootViewController: controller)
            self.presentPanModal(navigation)
        }
    }
    
    func onClickDailyRanking() {
        onDailyRankClicked?(true,{})
    }
    
    func didClickPopularLive(){  
        onDailyRankClicked?(false,{})
    }
    
    func onLiveEndLiveStreaming() {
        present(endLiveConfirmationController, animated: true)
    }
    
    func onLiveRotateCamera() {
        liveRoom.toggleCamera()
    }
    
    func onLiveDidClickComment() {
        chatInputView.isHidden = false
    }
    
    private func endLiveStreaming() {
        onLiveToolbar.removeFromParentView()
        onLiveToolbar.hideToolbar()
        onLiveToolbar.stopTimerDuration { [weak self] duration in
            self?.createSummary(duration: duration)
        }
    }
    
    private func createSummary(duration: TimeInterval) {
        let room = liveRoom.getLiveRoomSummary()
        let viewModel = LiveRoomSummaryViewModel(
            duration: duration,
            likesCount: room.likeCount,
            viewersCount: room.viewerCount,
            streamId: streamId
        )
        destroyRoom(viewModel)
    }
    
    private func destroyRoom(_ summary: LiveRoomSummaryViewModel) {
        liveRoom.destroyLiveStreaming(roomId: roomId, userId: userId)
        onDestroyRoom?(summary)
        liveStreamPausedController.removeFromParentView()
        audienceListAdapter.cancel()
    }
}

extension AnchorViewController: LiveRoomDismissalAdapterDelegate {
    func didDismissedRoom(
        with result: Result<LiveStreamSummary, Error>,
        completion: @escaping () -> Void
    ) {
        switch result {
        case let .success(summary):
            liveStreamEndedController.setSummary(summary)
            liveStreamEndedController.onTapBackButton = completion
            present(liveStreamEndedController, animated: true)
            
        case .failure:
            completion()
        }
    }
}

extension AnchorViewController: LiveRoomDelegate {
    public func onLiveStreamingEnded() {}
    
    public func onLiveStreamingRealtimeAudiencesCount(_ count: String) {
        onLiveToolbar.setAudiencesCount(count)
    }
    
    public func onLiveStreamingKickedByDoubleLogin() {
        endLiveStreaming()
    }
    
    public func onLiveStreamingCheckNetwork(buffer isBuffering: Bool) {
        if isBuffering {
            if isVideoPaused == false {
                add(liveStreamPausedController, sendViewToBackOf: onLiveToolbar.view)
                isVideoPaused = true
                chatView.isHidden = true
            }
        } else {
            liveStreamPausedController.removeFromParentView()
            isVideoPaused = false
            chatView.isHidden = false
        }
    }
    
    public func onLiveStreamingRealtimeLikesCount(_ count: String) {
        onLiveToolbar.setLikesCount(count)
    }
    
    public func onLiveStreamingPaused(paused isPaused: Bool) {}
}

extension AnchorViewController: LiveRoomCreationAdapterDelegate {
    func creationResult(roomId: String, streamingId: String) {
        
        self.roomId = roomId
        streamId = streamingId
        onLiveToolbar.setRoomOwnerName(roomOwnerName)
     
        createTRTCLiveRoom(roomId: roomId)
    }
}

extension AnchorViewController: LiveRoomValidationAdapterDelegate {
    func validationResult(_ result: LiveStreamValidation) {
        guard let status = result.status, status == false else {
            present(startNewLiveConfirmationController, animated: true)
            return
        }
        
        guard let roomId = result.roomID,
              let streamingID = result.streamingID else {
            createNewRoom()
            return
        }
    
        self.roomId = roomId
        streamId = streamingID
        onLiveToolbar.setRoomOwnerName(roomOwnerName)
        
        createTRTCLiveRoom(roomId: roomId)
    }
    
    func validationResult(_ error: LiveStreamEndpoint.ValidationError) {
        let errorMessage = error == .general ? "General Error" : "Followers kamu tidak mencukupi untuk memulai Live Streaming"
        showToast(with: errorMessage, duration: 2, verticalSpace: 70)
    }
}

extension AnchorViewController: ProfileAdapterDelegate {
    func profileResult(_ result: Result<LiveUserProfile, Error>) {
        switch result {
        case .failure:
            return toast()
            
        case let .success(profile):
            guard let id = profile.id else {
                return toast()
            }
            roomOwnerName = profile.name ?? profile.username ?? ""
            userId = id
            preLiveToolbar.setUserPhoto(profile.photo)
            
            onLiveToolbar.setUserPhoto(profile.photo)
            onLiveToolbar.setVerifitedIcon(profile.isVerified ?? false) 
        }
        
        func toast() {
            showToast(with: "Gagal memuat profil") { [weak self] in
                self?.dismiss(animated: true)
            }
        }
    }
}


extension AnchorViewController: LiveStreamAudienceListAdapterDelegate {
    func didFinishRequestCoin(with coinBalance: Int) {}
    
    private func getAudienceList() {
        audienceListAdapter.loadTopSeats(
            every: 7,
            roomId: roomId
        )
    }
    
    func didFinishRequest(with audiences: [LiveStreamAudience]) {}
    func didFinishRequestClassicGift(with gifts: [LiveGift]){}
    
    func didFinishRequestTopSeats(with topSeats: [LiveTopSeat]) {
        KKCache.common.save(array: topSeats.map{$0.id ?? ""}, key: .topSeatsCache)
        onLiveToolbar.setTopSeatView(topSeats)
    }
}

 
extension AnchorViewController {
    func addObserver(){
        NotificationCenter.default.addObserver(
            self, selector: #selector(gobackground),
            name: UIApplication.didEnterBackgroundNotification, object: nil
        )
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(gotoActive),
            name: UIApplication.didBecomeActiveNotification, object: nil
        )
    }
//    YES：暂停；NO：恢复。
    @objc func gobackground() {
        
    }
    
    @objc func gotoActive() {
//        liveRoom.cloud.updateLocalView(view)
    }
     
}
