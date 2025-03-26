import UIKit
import Combine
import KipasKipasTRTC
import KipasKipasShared
import KipasKipasLiveStream

protocol AudienceOnLiveToolbarDelegate: AnyObject {
    func didClickComment()
    func didClickLikeReaction()
    func didClickBack()
    func didClickAudience()
    func didClickFollow()
    func didClickDailyRank()
    func didClickPopularLive()
    func didClickUserImage()
    func didClickGift()
    func didTapLikeAnywhere()
    func didReceiveGift(_ gift: GiftData, isSelf: Bool)
    func didReceiveGiftError()
    func didReceieveGiftInsufficient()
    func didSendChat(_ message: String)
    func didClickClassicGift()
    func didClickShare()
}

class AudienceOnLiveToolbarViewController: ToolbarContainerViewController {
    
    private var topToolbarView: AudienceOnLiveTopToolbar!
    private var secondTopToolbarView: AudienceOnLiveSecondTopToolbar!
    private var bottomToolbarView: AudienceOnLiveBottomToolbar!
      
    private(set) lazy var giftPlayView = {
        let view = GiftPlayView()
        view.onTapLikeAnywhere = delegate?.didTapLikeAnywhere
        view.onReceiveGift = delegate?.didReceiveGift
        view.onGiftError = delegate?.didReceiveGiftError
        view.onInsufficientBalance = delegate?.didReceieveGiftInsufficient
        return view
    }()
    
    private(set) lazy var chatView = LiveRoomChatView()
    
    private(set) lazy var chatInputView = {
        let view = LiveRoomChatInputView()
        view.onTapSend = delegate?.didSendChat
        return view
    }()
    
    weak var delegate: AudienceOnLiveToolbarDelegate?
    
    private var cancellables: Set<AnyCancellable> = []
            
    convenience init() {
        let topToolbarView = AudienceOnLiveTopToolbar().height(35)
        let secondTopToolbarView = AudienceOnLiveSecondTopToolbar().height(22)
        
        let bottomToolbarView = AudienceOnLiveBottomToolbar().height(38)
        
        self.init(topToolbars: [topToolbarView, secondTopToolbarView], bottomToolbars: [bottomToolbarView])
        self.topToolbarView = topToolbarView
        self.secondTopToolbarView = secondTopToolbarView
        self.bottomToolbarView = bottomToolbarView
    }
    
    override func loadView() {
        view = giftPlayView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let followButtonPublisher = topToolbarView.followButton.tapPublisher
        let backButtonPublisher = topToolbarView.backButton.tapPublisher
        let dailyRankButtonPublisher = secondTopToolbarView.dailyRankingButton.tapPublisher
        let popularLiveButtonPublisher = secondTopToolbarView.popularLiveButton.tapPublisher
        let commentButtonPublisher = bottomToolbarView.commentButton.tapPublisher
        
        followButtonPublisher
            .sink { [weak self] in
                self?.topToolbarView.followButton.showLoader(userInteraction: false)
                self?.delegate?.didClickFollow()
            }
            .store(in: &cancellables)
        
        dailyRankButtonPublisher
            .sink { [weak self] in
                self?.delegate?.didClickDailyRank()
            }
            .store(in: &cancellables)
        
        popularLiveButtonPublisher
            .sink { [weak self] in
                self?.delegate?.didClickPopularLive()
            }
            .store(in: &cancellables)
        
        backButtonPublisher
            .sink { [weak self] in
                self?.delegate?.didClickBack()
            }
            .store(in: &cancellables)
        
        commentButtonPublisher
            .sink { [weak self] in
                self?.delegate?.didClickComment()
            }
            .store(in: &cancellables)
         
        
        topToolbarView.roomInfoToolbar.onClickUserImage = { [weak self] in
            self?.delegate?.didClickUserImage()
        }
        
        topToolbarView.audienceToolbar.onTap { [weak self] in
            self?.delegate?.didClickAudience()
        }
        
        bottomToolbarView.classicBtnView.onTap { [weak self] in
            self?.delegate?.didClickClassicGift()
        }
        bottomToolbarView.giftButtonView.onTap { [weak self] in
            self?.delegate?.didClickGift()
        }
        bottomToolbarView.shareButtonView.onTap { [weak self] in
            self?.delegate?.didClickShare()
        }
        
        
        configureChatView()
    }
    
    private func configureChatView() {
        appWindow?.addSubview(chatInputView)
        chatInputView.anchors.edges.pin()
        
        let stack = UIStackView()
        let invisibleView = UIView()
        invisibleView.isUserInteractionEnabled = false
       
        stack.addArrangedSubview(chatView)
        stack.addArrangedSubview(invisibleView)
        
        invisibleView.anchors.width.equal(stack.anchors.width * 0.15)
        
        addBottomToolbarToFirstIndex(stack)
        stack.anchors.height.equal(view.anchors.height * 0.3)
    }

    
    // MARK: API
    func setAudiencesCount(_ count: String) {
        topToolbarView.setAudiencesCount(count)
    }
    
    func setOwnerPhoto(_ urlString: String) {
        topToolbarView.setOwnerPhoto(urlString)
    }
    
    func setOwnerName(_ name: String) {
        topToolbarView.setOwnerName(name)
    }
    
    func setFollowButtonVisibility(_ isFollowingOwner: Bool) {
        topToolbarView.setFollowButtonVisibility(isFollowingOwner) 
    }
    
    func startFollowButtonAnimation(){
        topToolbarView.followButton.showLoader(userInteraction: true)
    }
    func stopFollowButtonAnimation(){
        topToolbarView.followButton.hideLoader()
    }
    
    func setVerifiedIcon(_ isVerified: Bool) {
        topToolbarView.setVerifiedIcon(isVerified)
    }
    
    func hideButtonLoading(_ isFollowed: Bool) {
        topToolbarView.followButton.hideLoader { [weak self] in
            self?.topToolbarView.setFollowButtonVisibility(isFollowed)
        }
    }
    
    func setLikesCount(_ count: String) {
        topToolbarView.setLikesCount(count)
    }
    
    func showBottomToolbar() {
        bottomToolbarView.isHidden = false
    }
    
    func hideBottomToolbar() {
        bottomToolbarView.isHidden = true
    }
    
    func setTopSeatView(
        _ audiences: [LiveTopSeat],
        selection: @escaping (String) -> Void
    ) {
        let first = audiences[safe: 0]
        let firstId =  first?.id
        let firstImage = first?.photo
        
        topToolbarView.firstTopSeatView.setProfileImage(firstImage, isExists: firstId != nil)
        topToolbarView.firstTopSeatView.ribbonColor = firstImage == nil ? .clear : .yellow
        topToolbarView.firstTopSeatView.ribbonText = firstId == nil ? nil : "1"
        topToolbarView.firstTopSeatView.onTap {
            if let firstId { selection(firstId) }
        }
        
        let second = audiences[safe: 1]
        let secondId =  second?.id
        let secondImage = second?.photo 
        
        topToolbarView.secondTopSeatView.setProfileImage(secondImage, isExists: secondId != nil)
        topToolbarView.secondTopSeatView.ribbonColor = secondImage == nil ? .clear : .softPeach
        topToolbarView.secondTopSeatView.ribbonText = secondId == nil ? nil : "2"
        topToolbarView.secondTopSeatView.onTap {
            if let secondId { selection(secondId) }
        }
    }
    
    func setClassicGift( _ gift: LiveGift) {
        bottomToolbarView.setClassicGiftBtn(gift)
    }
    
    func setTextViweText( _ text: String){
        chatInputView.emojiInput.changeTextStr(text) 
    }
}

extension Array {
    subscript (safe index: Index) -> Element? {
        0 <= index && index < count ? self[index] : nil
    }
}
