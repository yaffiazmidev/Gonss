import UIKit
import Combine
import KipasKipasLiveStream
import KipasKipasShared

protocol AnchorOnLiveToolbarDelegate: AnyObject {
    func onLiveRotateCamera()
    func onLiveEndLiveStreaming()
    func onLiveDidClickComment()
    func onClickAudience()
    func onClickDailyRanking()
    func didClickPopularLive()
}

class AnchorOnLiveToolbarViewController: ToolbarContainerViewController {
    
    private var topToolbarView: AnchorOnLiveTopToolbar!
    private var secondTopToolbarView: AnchorOnLiveSecondTopToolbar!
    private var bottomToolbarView: AnchorOnLiveBottomToolbar!
    
    private var duration: TimeInterval = 0
    
    private lazy var stopwatch = Stopwatch(timeUpdated: { [weak self] timeInterval in
        self?.topToolbarView.duration = String.duration(from: timeInterval)
        self?.duration = timeInterval
    })
    
    private(set) lazy var giftPlayView = GiftPlayView()
    
    private var cancellables: Set<AnyCancellable> = []
        
    weak var delegate: AnchorOnLiveToolbarDelegate?
    
    convenience init() {
        let topToolbarView = AnchorOnLiveTopToolbar().height(35)
        let secondTopToolbarView = AnchorOnLiveSecondTopToolbar().height(22)
       
        let bottomToolbarView = AnchorOnLiveBottomToolbar().height(38)
        
        self.init(topToolbars: [topToolbarView, secondTopToolbarView], bottomToolbars: [bottomToolbarView])
        self.topToolbarView = topToolbarView
        self.secondTopToolbarView = secondTopToolbarView
        self.bottomToolbarView = bottomToolbarView
    }
    
    override func loadView() {
        view = giftPlayView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        topToolbarView.startAnimation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let endLiveButtonPublisher = topToolbarView.endLiveButton.tapPublisher
        let dailyRankButtonPublisher = secondTopToolbarView.dailyRankingButton.tapPublisher
        let popularLiveButtonPublisher = secondTopToolbarView.popularLiveButton.tapPublisher
        let rotateCameraPublisher = bottomToolbarView.rotateCameraButton.tapPublisher
        let commentButtonPublisher = bottomToolbarView.commentButton.tapPublisher

        dailyRankButtonPublisher
            .sink { [weak self] in
                self?.delegate?.onClickDailyRanking()
            }
            .store(in: &cancellables)
        
        popularLiveButtonPublisher
            .sink { [weak self] in
                self?.delegate?.didClickPopularLive()
            }
            .store(in: &cancellables)
        
        endLiveButtonPublisher
            .sink { [weak self] in
                self?.delegate?.onLiveEndLiveStreaming()
            }
            .store(in: &cancellables)
        
        rotateCameraPublisher
            .sink { [weak self] in
                self?.delegate?.onLiveRotateCamera()
            }
            .store(in: &cancellables)
        
        commentButtonPublisher
            .sink { [weak self] in
                self?.delegate?.onLiveDidClickComment()
            }
            .store(in: &cancellables)
        
        topToolbarView.audienceToolbar.onTap { [weak self] in
            self?.delegate?.onClickAudience()
        }
    }
    
    // MARK: API
    func startTimerDuration() {
        stopwatch.toggle()
    }
    
    func stopTimerDuration(completion: @escaping (TimeInterval) -> Void) {
        stopwatch.stop()
        topToolbarView.removeAnimation()
        
        completion(duration)
    }
    
    func setUserPhoto(_ source: String?) {
        topToolbarView.setUserPhoto(source)
    }
    
    func setRoomOwnerName(_ ownerName: String) {
        topToolbarView.setRoomOwnerName(ownerName)
    }
    
    func setAudiencesCount(_ count: String) {
        topToolbarView.setAudiencesCount(count)
    }
    
    func setLikesCount(_ count: String) {
        topToolbarView.setLikesCount(count)
    }
    
    func setVerifitedIcon(_ isVerified: Bool) {
        topToolbarView.setVerifitedIcon(isVerified)
    }
    
    func setTopSeatView(_ audiencesImage: [LiveTopSeat]) {
        let firstId = audiencesImage[safe: 0]?.id
        let firstImage = audiencesImage[safe: 0]?.photo
        
        topToolbarView.firstTopSeatView.setProfileImage(firstImage, isExists: firstId != nil)
        topToolbarView.firstTopSeatView.ribbonColor = firstImage == nil ? .clear : .yellow
        topToolbarView.firstTopSeatView.ribbonText = firstId == nil ? nil : "1"
        
        let secondId = audiencesImage[safe: 1]?.id
        let secondImage = audiencesImage[safe: 1]?.photo
        
        topToolbarView.secondTopSeatView.setProfileImage(secondImage, isExists: secondId != nil)
        topToolbarView.secondTopSeatView.ribbonColor = secondImage == nil ? .clear : .softPeach
        topToolbarView.secondTopSeatView.ribbonText = secondId == nil ? nil : "2"
    }
}
