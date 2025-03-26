import UIKit
import KipasKipasShared

typealias AnchorOnLiveTopToolbar = AnchorOnLiveToolbar.TopToolbarView
typealias AnchorOnLiveSecondTopToolbar = AnchorOnLiveToolbar.SecondTopToolbarView
typealias AnchorOnLiveBottomToolbar = AnchorOnLiveToolbar.BottomToolbarView

// MARK: A namespace for clear context
enum AnchorOnLiveToolbar {}

// MARK: Main components
extension AnchorOnLiveToolbar {
    
    // MARK: Top Toolbar
    final class TopToolbarView: UIView {
        private let stackView = UIStackView()
        private let roomInfoToolbar = AnchorRoomInfoToolbar()
        
        private(set) var endLiveButton = KKBaseButton()
        private(set) var audienceToolbar = RealtimeAudienceToolbar()
        
        private(set) var firstTopSeatView = TopSeatView()
        private(set) var secondTopSeatView = TopSeatView()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            configureUI()
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            return nil
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            endLiveButton.layer.cornerRadius = bounds.height / 2
        }
        
        private func configureUI() {
            configureStackView()
        }
        
        private func configureStackView() {
            stackView.spacing = 5
            stackView.alignment = .center
            
            addSubview(stackView)
            stackView.anchors.edges.pin(axis: .vertical)
            stackView.anchors.edges.pin(insets: 12, axis: .horizontal)
            
            configureRoomInfoToolbar()
            configureInvisibleView()
            configureTopSeatView()
            configureAudienceToolbar()
            configureEndLiveButton()
        }
        
        private func configureRoomInfoToolbar() {
            stackView.addArrangedSubview(roomInfoToolbar)
            roomInfoToolbar.anchors.height.equal(anchors.height)
        }
        
        private func configureTopSeatView() {
            firstTopSeatView.image = .iconFirstTopSeat
            firstTopSeatView.contentMode = .center
            firstTopSeatView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            firstTopSeatView.layer.cornerRadius = 27 / 2
            
            secondTopSeatView.image = .iconSecondTopSeat
            secondTopSeatView.contentMode = .center
            secondTopSeatView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            secondTopSeatView.layer.cornerRadius = 27 / 2
            
            stackView.addArrangedSubview(firstTopSeatView)
            stackView.addArrangedSubview(secondTopSeatView)
            firstTopSeatView.anchors.width.equal(27)
            firstTopSeatView.anchors.height.equal(27)
            secondTopSeatView.anchors.width.equal(27)
            secondTopSeatView.anchors.height.equal(27)
        }
        
        private func configureAudienceToolbar() {
            stackView.addArrangedSubview(audienceToolbar)
            audienceToolbar.anchors.height.equal(27)
        }
        
        private func configureEndLiveButton() {
            endLiveButton.setImage(.iconEndLive, for: .normal)
            endLiveButton.clipsToBounds = true
            
            stackView.addArrangedSubview(endLiveButton)
            endLiveButton.anchors.height.equal(27)
            endLiveButton.anchors.width.equal(27)
        }
        
        private func configureInvisibleView() {
            let invisibleView = UIView()
            invisibleView.backgroundColor = .clear
            invisibleView.setContentHuggingPriority(.defaultLow, for: .horizontal)
            
            stackView.addArrangedSubview(invisibleView)
        }
    }
    
    final class SecondTopToolbarView: UIView {
        private let stackView = UIStackView()
        
        private (set) var dailyRankingButton = KKLoadingButton(icon: .iconDailyRanking)
        private (set) var popularLiveButton = KKLoadingButton(icon: .iconPopularLive)
        override init(frame: CGRect) {
            super.init(frame: frame)
            configureUI()
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            return nil
        }
        
        private func configureUI() {
            configureStackView()
        }
        
        private func configureStackView() {
            stackView.spacing = 8
            stackView.alignment = .center
            
            addSubview(stackView)
            stackView.anchors.edges.pin(axis: .vertical)
            stackView.anchors.edges.pin(insets: 12, axis: .horizontal)
            
            configureDailyRanking()
            configurePopularLive()
            configureInvisibleView()
        }
        
        private func configureDailyRanking() {
            dailyRankingButton.font = .roboto(.medium, size: 11)
            dailyRankingButton.setBackgroundColor(UIColor.black.withAlphaComponent(0.2), for: .normal)
            dailyRankingButton.setTitle("Daily Ranking")
            dailyRankingButton.cornerRadius = 10
            
            stackView.addArrangedSubview(dailyRankingButton)
            dailyRankingButton.anchors.width.equal(96)
            dailyRankingButton.anchors.height.equal(anchors.height)
        }
        
        private func configurePopularLive() {
            popularLiveButton.font = .roboto(.medium, size: 10)
            popularLiveButton.setBackgroundColor(UIColor.black.withAlphaComponent(0.2), for: .normal)
            popularLiveButton.setTitle("Popular LIVE")
            popularLiveButton.cornerRadius = 10
            
            stackView.addArrangedSubview(popularLiveButton)
            popularLiveButton.anchors.width.equal(96)
            popularLiveButton.anchors.height.equal(anchors.height)
        }
        
        private func configureInvisibleView() {
            let invisibleView = UIView()
            invisibleView.backgroundColor = .clear
            invisibleView.setContentHuggingPriority(.defaultLow, for: .horizontal)
            
            stackView.addArrangedSubview(invisibleView)
        }
    }
    
    // MARK: Bottom Toolbar
    final class BottomToolbarView: UIView {
        
        private let stackView = UIStackView()
        
        private let commentStack = UIStackView()
        private(set) var commentButton = KKBaseButton()
        private let commentLabel = UILabel()
        
        private let rotateCameraStack = UIStackView()
        private(set) var rotateCameraButton = KKBaseButton()
        private let rotateCameraLabel = UILabel()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            configureUI()
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            return nil
        }
        
        private func configureUI() {
            configureStackView()
        }
        
        private func configureStackView() {
            stackView.spacing = 8
            stackView.alignment = .leading
            
            addSubview(stackView)
            stackView.anchors.edges.pin()
            
            configureCommentStackView()
            configureRotateCameraStack()
            configureInvisibleView()
        }
        
        private func configureCommentStackView() {
            commentStack.axis = .vertical
            commentStack.alignment = .center
            commentStack.distribution = .equalCentering
            
            stackView.addArrangedSubview(commentStack)
            
            configureCommentButton()
            configureCommentTitle()
        }
        
        private func configureCommentButton() {
            commentButton.setImage(.iconLiveComment, for: .normal)
            commentButton.clipsToBounds = true
            
            commentStack.addArrangedSubview(commentButton)
            commentStack.anchors.height.equal(34)
            commentStack.anchors.width.equal(anchors.height)
        }
        
        private func configureCommentTitle() {
            commentLabel.text = "Chat"
            commentLabel.textAlignment = .center
            commentLabel.textColor = .white
            commentLabel.font = .roboto(.medium, size: 9)
            
            commentStack.addArrangedSubview(commentLabel)
        }
        
        private func configureRotateCameraStack() {
            rotateCameraStack.axis = .vertical
            rotateCameraStack.alignment = .center
            rotateCameraStack.distribution = .equalCentering
            
            stackView.addArrangedSubview(rotateCameraStack)
            
            configureRotateCameraButton()
            configureRotateCameraTitle()
        }
        
        private func configureRotateCameraButton() {
            rotateCameraButton.setImage(.iconCameraRotate, for: .normal)
            rotateCameraButton.clipsToBounds = true
            
            rotateCameraStack.addArrangedSubview(rotateCameraButton)
            rotateCameraStack.anchors.height.equal(34)
            rotateCameraStack.anchors.width.equal(anchors.height)
        }
        
        private func configureRotateCameraTitle() {
            rotateCameraLabel.text = "Camera"
            rotateCameraLabel.textAlignment = .center
            rotateCameraLabel.textColor = .white
            rotateCameraLabel.font = .roboto(.medium, size: 9)
            
            rotateCameraStack.addArrangedSubview(rotateCameraLabel)
        }
        
        private func configureInvisibleView() {
            let invisibleView = UIView()
            invisibleView.backgroundColor = .clear
            invisibleView.setContentHuggingPriority(.defaultLow, for: .horizontal)
            
            stackView.addArrangedSubview(invisibleView)
        }
    }
}

// MARK: API
extension AnchorOnLiveTopToolbar {
    var duration: String? {
        get { roomInfoToolbar.timeElapsedLabel.text }
        set  {
            roomInfoToolbar.timeElapsedLabel.text = newValue
        }
    }
    
    func startAnimation() {
        roomInfoToolbar.recordingDotView.blink()
    }
    
    func removeAnimation() {
        roomInfoToolbar.recordingDotView.layer.removeAllAnimations()
    }
    
    func setRoomOwnerName(_ ownerName: String) {
        roomInfoToolbar.ownerNameLabel.text = ownerName
    }
    
    func setAudiencesCount(_ count: String) {
        audienceToolbar.audienceCountLabel.text = count
    }
    
    func setLikesCount(_ count: String) {
        roomInfoToolbar.likesLabel.text = count + " Likes"
    }
    
    func setVerifitedIcon(_ isVerified: Bool) {
        roomInfoToolbar.verifitedIcon.isHidden = isVerified == false
    }
    
    func setUserPhoto(_ source: String?) {
        roomInfoToolbar.userImageView.setImage(with: source, placeholder: .defaultProfileImage)
    }
}
