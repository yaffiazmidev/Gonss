import UIKit
import KipasKipasLiveStream
import KipasKipasShared
import KipasKipasTRTC 
//import FeedCleeps

extension Notification.Name {
    static let updateIsFollowFromFolowingFolower = Notification.Name("updateIsFollowFromFolowingFolower")
}

public final class AudienceViewController: ContainerViewController {
    
    private lazy var onLiveToolbar = {
        let toolbar = AudienceOnLiveToolbarViewController()
        toolbar.delegate = self
        toolbar.setBottomToolbarHorizontalInsets(20)
        toolbar.setOwnerPhoto(liveRoomInfo.ownerPhoto)
        toolbar.setOwnerName(liveRoomInfo.ownerName)
        toolbar.setFollowButtonVisibility(liveRoomInfo.isFollowingOwner)
        toolbar.setVerifiedIcon(liveRoomInfo.isVerified)
        return toolbar
    }()
    
    private lazy var liveStreamEndedController = {
        let controller = AudienceLiveStreamEndedViewController()
        controller.setUserImage(liveRoomInfo.ownerPhoto)
        return controller
    }()
    
    private lazy var liveStreamPausedController = {
        let controller = LiveStreamPausedViewController()
        controller.modalPresentationStyle = .overCurrentContext
        return controller
    }()
    
    private lazy var giftErrorController = {
        let destination = CustomPopUpViewController(
            title: "Oops, sepertinya ada kesalahan :(",
            description: "Maaf ya, terdapat kendala teknis dalam proses ini, kami sedang berusaha memperbaikinya, silahkan ulangi beberapa saat lagi.",
            iconImage: .illustrationGiftError,
            iconHeight: 145,
            okBtnTitle: "OKE",
            isHideIcon: false
        )
        destination.modalPresentationStyle = .overCurrentContext
        return destination
    }()
    
    private(set) lazy var listGiftController: ListGiftViewController = {
        let controller = ListGiftUIComposer.composeListGiftUIWith(
            selection: { [weak self] viewModel in
                let data = GiftMetadata(
                    giftId: viewModel.id ?? "", 
                    lottieUrl: viewModel.lottieURL,
                    imageUrl: viewModel.giftURL,
                    message: "Mengirim " + (viewModel.title ?? "")
                )
                self?.liveRoom.sendGift(data)
            },
            onTapTopUpCoin: onTapTopUpCoin
        )
        controller.onLoadCoinBalance = onLoadCoinBalance
        controller.onLoadGifts = onLoadGifts
        return controller
    }()
    //    MARK: -  topSeatController
    private(set) lazy var topSeatController: LiveTopSeatViewController = {
        let controller = TopSeatUIComposer.composeTopSeatUIWith(
            seatProfileLoader: seatProfileLoader ,
            followLoader:followLoader,
            unfollowLoader: unfollowLoader,
            onUserImageClicked: seatImageClick,
            onClickRemind: clickRemind,
            onClickReport: clickReport
        )
        return controller
    }()
    
    func seatImageClick(_ seatId:String){
        dismiss(animated: true) {
            self.onUserImageClicked?(seatId)
        }
        
    }
    
    func clickRemind(_ seatName:String){
        dismiss(animated: true) {
            self.onLiveToolbar.chatInputView.isHidden = false
            self.onLiveToolbar.setTextViweText(seatName)
        }
    }
    
    func clickReport(){
        dismiss(animated: true) {
             
        }
    }
    
    func loadTopSeat(abc:String){
        
    }
    
    private var roomId: String {
        return String(liveRoomInfo.roomId)
    }
    
    private lazy var toastView = {
        let toast = KKFloatingToastView()
        toast.titleLabel?.text = "Koneksi internet tidak stabil."
        toast.leftIconView = UIImageView(image: .iconWarningWhite)
        toast.layout = .init()
        toast.direction = .bottom
        toast.duration = .infinity
        toast.textColor = .white
        toast.backgroundColor = .gravel
        return toast
    }()
    
    private var isLiveEnded: Bool = false
    private var shouldReload: Bool = true
    private var coinBalance: Int = 0
    
    private let liveRoom: AudienceLiveRoomManager
    private let liveRoomInfo: LiveRoomInfoViewModel
    private let audienceListAdapter: LiveStreamAudienceListAdapter
    
    var followLoader: (String) -> FollowLoader
    var unfollowLoader: (String) -> FollowLoader
    var seatProfileLoader: (String) -> LiveProfileLoader
    private var classicGift: LiveGift?
    private var gifts:[LiveGift]?
    private var myPhoto = ""
    private var profileName = ""

    var onClickShare: (([String:String]) -> Void)?
    var onClickFollow: ((String) -> Void)?
    var onClickAudience: ((String, String,@escaping()->Void,@escaping()->Void) -> Void)?
    var onDailyRankClicked: ((Bool,@escaping ()->Void) -> Void)?
    var onKicked: (() -> Void)?
    var onUserImageClicked: ((String) -> Void)?
    var onTapTopUpCoin: (() -> Void)?
    var onLoadGifts: (() -> Void)?
    var onLoadCoinBalance: (() -> Void)?
    var onLoadProfile: (() -> Void)?
    
    init(
        liveRoom: AudienceLiveRoomManager,
        liveRoomInfo: LiveRoomInfoViewModel,
        audienceListAdapter: LiveStreamAudienceListAdapter,
        seatProfileLoader: @escaping (String) -> LiveProfileLoader,
        followLoader: @escaping (String) -> FollowLoader,
        unfollowLoader: @escaping (String) -> FollowLoader
    ) {
        self.liveRoom = liveRoom
        self.liveRoomInfo = liveRoomInfo
        self.audienceListAdapter = audienceListAdapter
        self.seatProfileLoader = seatProfileLoader
        self.followLoader = followLoader
        self.unfollowLoader = unfollowLoader
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    public override func loadView() {
        view = PassthroughView()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        if shouldReload {
            liveRoom.enterRoom()
            liveRoom.enterChatRoom()
            liveRoom.delegate = self
            liveRoom.chatDelegate = onLiveToolbar.chatView
            liveRoom.giftDelegate = onLiveToolbar.giftPlayView
        }
        shouldReload = true
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        toastView.dismiss()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if shouldReload {
            liveRoom.exitRoom()
            liveRoom.leaveChatRoom()
            liveRoom.delegate = nil
            liveRoom.chatDelegate = nil
            liveRoom.giftDelegate = nil
            audienceListAdapter.cancel()
        }
        onLiveToolbar.chatInputView.isHidden = true
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getAudienceList()
        liveRoom.startPlay(on: view)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()   
        let invisibleView = UIView()
        invisibleView.anchors.height.equal(8)
        invisibleView.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        onLiveToolbar.addBottomToolbarToFirstIndex(invisibleView)
        audienceListAdapter.loadClassicGift()
        audienceListAdapter.loadCoinBalance()
        onLoadProfile?()
        transition(
            to: onLiveToolbar,
            ignoreSafeArea: false
        ) { [weak self] in
            self?.onLiveToolbar.showToolbar()
        }
        addObserver()
    }
     
    
    func saveRoomInfo(){
        let info:[String : Any] = ["userId":liveRoomInfo.ownerId,
                                "photo":liveRoomInfo.ownerPhoto,
                                "name":liveRoomInfo.ownerName,
                                "isVerified":liveRoomInfo.isVerified]
        KKCache.common.save(dictionary: info, key: .roomInfoCache)
    }
    
}

// MARK: On Live
extension AudienceViewController: AudienceOnLiveToolbarDelegate {
    func didReceiveGiftError() {
        listGiftController.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            present(giftErrorController, animated: true)
        }
    }
    
    func didReceieveGiftInsufficient() {
        didClickGift()
        onTapTopUpCoin?()
    }
    
    func didClickBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func didClickComment() {
        onLiveToolbar.chatInputView.isHidden = false
    }
    
    func didClickUserImage() {
//        onUserImageClicked?(liveRoomInfo.ownerId)
        didShowTopSeat(liveRoomInfo.ownerId, true)
    }
    
    func didClickLikeReaction() {
        liveRoom.didClickLikeReaction()
    }
    
    func didClickFollow() {
        onClickFollow?(liveRoomInfo.ownerId)
    }
    
    func didClickDailyRank() {
        shouldReload = false
        saveRoomInfo()
        onDailyRankClicked?(true, audienceListToGift )
    }
    
    func didClickPopularLive(){
        shouldReload = false
        saveRoomInfo()
        onDailyRankClicked?(false, audienceListToGift)
    }
    
    func didClickAudience() {
        shouldReload = false
        onClickAudience?(
             roomId,
             liveRoomInfo.ownerId,
             audienceListToGift,
             audienceListToTCWeb
        )
    }
    
    func didShowTopSeat(_ seatId: String, _ isAnchor:Bool = false){
        shouldReload = false
        topSeatController.seatId =  seatId
        topSeatController.isAnchor = isAnchor
        topSeatController.followChange = { [weak self]  isFollowed in 
            self?.onLiveToolbar.setFollowButtonVisibility(isFollowed)
            self?.onLiveToolbar.stopFollowButtonAnimation()
        }
        topSeatController.followAnimation = { [weak self] in
            self?.onLiveToolbar.startFollowButtonAnimation()
        }
        let navigation = PanNavigationViewController(rootViewController: topSeatController)
        presentPanModal(navigation)
    }
    
    func audienceListToGift(){
        dismiss(animated: false) {
            self.didClickGift()
        }
    }
    
    func audienceListToTCWeb(){
        dismiss(animated: false) {
            let controller = TeamConditionViewController()
            let navigation = PanNavigationViewController(rootViewController: controller)
            self.presentPanModal(navigation)
        }
    }
    
    func didClickGift(){
        shouldReload = false
        listGiftController.myPhoto = myPhoto
        let navigation = PanNavigationViewController(rootViewController: listGiftController)
        presentPanModal(navigation)
    }
    
    func didTapLikeAnywhere() {
        liveRoom.didClickLikeReaction()
    }
    
    func didReceiveGift(_ gift: GiftData, isSelf: Bool) {
        listGiftController.onReceiveGift(gift, isSelf: isSelf)
        if isSelf &&  (gifts != nil && gifts?.count ?? 0 > 0) {
            if let index = gifts?.firstIndex(where: { $0.id == gift.giftId }) {
                self.coinBalance -= gifts?[safe: index]?.price ?? 0
            }
        }
    }
    
    func didSendChat(_ message: String) {
        liveRoom.sendMessage(message)
    }
    
    func didClickClassicGift() {
        if self.classicGift?.price ?? 0 > self.coinBalance {
            didClickGift()
            onTapTopUpCoin?()
            return
        }
        let data = GiftMetadata(
            giftId: self.classicGift?.id ?? "",
            lottieUrl: self.classicGift?.lottieURL,
            imageUrl: self.classicGift?.giftURL,
            message: "Mengirim " + (self.classicGift?.title ?? "")
        )
        self.liveRoom.sendGift(data)
    }
    
    func didClickShare() {
//        let loginId:String = UserDefaults.standard.string(forKey: "USER_LOGIN_ID") ?? ""
        var img = " https://pics2.baidu.com/feed/0bd162d9f2d3572c01b0bd992203382162d0c33f.jpeg"
        img = "https://kipaskipas.com/"
        let item:[String:String] = ["id":liveRoomInfo.roomId,
                                    "message":"Sedang siaran langsung",
                                    "assetUrl":img,
                                    "accountId":liveRoomInfo.ownerId,
                                    "name":profileName ,
                                    "username":liveRoomInfo.ownerName ]

        
         onClickShare?(item)
    } 
}

// MARK: Room Observer
extension AudienceViewController: LiveRoomDelegate {
    
    public func onLiveStreamingRealtimeLikesCount(_ count: String) {
        onLiveToolbar.setLikesCount(count)
    }
    
    public func onLiveStreamingEnded() {
        if !isLiveEnded {
            liveRoom.exitRoom()
            onLiveToolbar.hideToolbar(animated: false)
            liveStreamPausedController.removeFromParentView()
            transition(to: liveStreamEndedController, ignoreSafeArea: false)
            toastView.dismiss()
            onLiveToolbar.chatInputView.isHidden = true
            audienceListAdapter.cancel()
        }
        
        isLiveEnded = true
    }
    
    public func onLiveStreamingRealtimeAudiencesCount(_ count: String) {
        onLiveToolbar.setAudiencesCount(count)
    }
    
    public func onLiveStreamingKickedByDoubleLogin() {
        onKicked?()
    }
    
    public func onLiveStreamingCheckNetwork(buffer isBuffering: Bool) {
        if isBuffering {
            toastView.present()
        } else {
            toastView.dismiss()
        }
        
        toastView.isPresentable = !isBuffering
    }
    
    public func onLiveStreamingPaused(paused isPaused: Bool) {
        if isPaused {
            add(liveStreamPausedController, sendViewToBackOf: onLiveToolbar.view)
            onLiveToolbar.chatView.isHidden = true
            onLiveToolbar.hideBottomToolbar()
            
        } else {
            liveStreamPausedController.removeFromParentView()
            onLiveToolbar.chatView.isHidden = false
            onLiveToolbar.showBottomToolbar()
        }
    }
}

extension AudienceViewController: ProfileFollowAdapterDelegate {
    public func unfollowStatus(_ isUnfollowed: Bool) { }
    
    public func requestFail() {  }
    
    public func followStatus(_ isFollowed: Bool) {
        onLiveToolbar.hideButtonLoading(isFollowed)
    }
}
 
extension AudienceViewController: ProfileAdapterDelegate {
    func profileResult(_ result: Result<KipasKipasLiveStream.LiveUserProfile, Error>) {
        switch result {
        case .failure:
            return toast()
            
        case let .success(profile):
            guard profile.id != nil else {
                return toast()
            }
            myPhoto = profile.photo ?? ""
            profileName = profile.name ?? ""
        }
        func toast() {
            showToast(with: "User ID tidak ditemukan") { [weak self] in
                self?.dismiss(animated: true)
            }
        }
        
    }
}

extension AudienceViewController: LiveStreamAudienceListAdapterDelegate {
    func didFinishRequestCoin(with coinBalance: Int) {
        self.coinBalance = coinBalance
    }
    
    private func getAudienceList() {
        audienceListAdapter.loadTopSeats(
            every: 7,
            roomId: roomId
        )
    }
    
    func didFinishRequestTopSeats(with topSeats: [LiveTopSeat]) {
        KKCache.common.save(array: topSeats.map{$0.id ?? ""}, key: .topSeatsCache)
        
        onLiveToolbar.setTopSeatView(topSeats) { [weak self] in
//            self?.onUserImageClicked?($0)  //原来跳转
            self?.didShowTopSeat($0)
        }
    }
    
    func didFinishRequestClassicGift(with gifts: [LiveGift]){
        print(gifts)
        guard gifts.count > 0 else {
            self.classicGift = nil
            return
        }
        self.gifts = gifts
        self.classicGift = gifts[0]
        onLiveToolbar.setClassicGift(self.classicGift!)
    }
    
    func didFinishRequest(with audiences: [LiveStreamAudience]) {}
}

extension AudienceViewController {
    func addObserver(){
        NotificationCenter.default.addObserver(
            self, selector: #selector(gobackground),
            name: UIApplication.didEnterBackgroundNotification, object: nil
        )
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(gotoActive),
            name: UIApplication.didBecomeActiveNotification, object: nil
        )
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateIsFollowFromFolowingFolower(_:)), name: .updateIsFollowFromFolowingFolower, object: nil)

    }
    
    @objc func gobackground() {
        liveRoom.freezePlay(true)
    }
    @objc func gotoActive() {
        liveRoom.freezePlay(false)
    }
    
    @objc private func handleUpdateIsFollowFromFolowingFolower(_ notification: Notification) {
        guard let object = notification.userInfo as? [String: Any] else { return }
        
        if let accountId = object["accountId"] as? String, accountId == liveRoomInfo.ownerId {
            let follow : Bool = object["isFollow"] as? Bool ?? false
            self.onLiveToolbar.setFollowButtonVisibility(follow)
        }
    }
}
