import UIKit
import KipasKipasLiveStream
import KipasKipasShared
import Kingfisher

typealias AudienceOnLiveTopToolbar = AudienceOnLiveToolbar.TopToolbarView
typealias AudienceOnLiveSecondTopToolbar = AudienceOnLiveToolbar.SecondTopToolbarView
typealias AudienceOnLiveBottomToolbar = AudienceOnLiveToolbar.BottomToolbarView

// MARK: A namespace for clear context
enum AudienceOnLiveToolbar {}

// MARK: Main components
extension AudienceOnLiveToolbar {
    
    final class TopToolbarView: PassthroughView {
        
        private let stackView = UIStackView()
        
        private(set) var roomInfoToolbar = AudienceRoomInfoToolbar()

        private(set) var backButton = KKBaseButton()
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
            backButton.layer.cornerRadius = bounds.height / 2
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
            configureBackButton()
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
        
        private func configureBackButton() {
            backButton.setImage(.iconCloseWhite, for: .normal)
            backButton.clipsToBounds = true
            
            stackView.addArrangedSubview(backButton)
            backButton.anchors.height.equal(27)
            backButton.anchors.width.equal(27)
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
            dailyRankingButton.font = .roboto(.medium, size: 10)
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
    
    /// Bottom-toolbar
    final class BottomToolbarView: PassthroughView {
        
        private let stackView = UIStackView()
        
        private(set) var commentButton = KKBaseButton()
        private(set) var reactionLikeButton = KKBaseButton()
        private(set) var giftButton = KKBaseButton()
        
        private(set) var classicBtnView =  TitleButton()
        private(set) var giftButtonView = TitleButton()
        private(set) var shareButtonView = TitleButton()
         
        
        
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
            commentButton.layer.cornerRadius = 18
        }
        
        private func configureUI() {
            configureStackView()
        }
        
        private func configureStackView() {
            stackView.spacing = 8 //16
            stackView.distribution = .equalCentering
            stackView.alignment = .leading
            addSubview(stackView)
            stackView.anchors.edges.pin()
            
            configureCommentButton()
            configureClassicGiftButton()
            configureGiftButton()
//            configureReactionLikeButton()
            configureShareButton()
        }
        
        private func configureCommentButton() {
            commentButton.setBackgroundColor(UIColor.white.withAlphaComponent(0.1), for: .normal)
            commentButton.setTitle("Tambah komentar", for: .normal)
            commentButton.setTitleColor(UIColor.gainsboro.withAlphaComponent(0.6), for: .normal)
            commentButton.font = .roboto(.regular, size: 16)
            commentButton.contentHorizontalAlignment = .left
            commentButton.titleEdgeInsets.left = 24
            commentButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
            
            stackView.addArrangedSubview(commentButton)
            commentButton.anchors.height.equal(anchors.height)
            commentButton.anchors.width.equal(anchors.width * 0.62)
        }
        
        private func configureClassicGiftButton() {
            stackView.addArrangedSubview(classicBtnView)
            classicBtnView.anchors.height.equal(anchors.height)
            classicBtnView.anchors.width.equal(anchors.height)
            classicBtnView.imageV.anchors.width.equal(30)
        }
        
        private func configureGiftButton() {
            giftButtonView.label.text = "gift"
            giftButtonView.imageV.image = .iconGift
            
            stackView.addArrangedSubview(giftButtonView)
            giftButtonView.anchors.height.equal(anchors.height)
            giftButtonView.anchors.width.equal(anchors.height)
            giftButtonView.imageV.anchors.width.equal(24)
        }
        
        private func configureShareButton(){
            shareButtonView.label.text = "share"
            shareButtonView.imageV.image = .iconShareWithe
            
            stackView.addArrangedSubview(shareButtonView)
            shareButtonView.anchors.height.equal(anchors.height)
            shareButtonView.anchors.width.equal(anchors.height)
            shareButtonView.imageV.anchors.width.equal(24)
        }
        
        private func configureReactionLikeButton() {
            reactionLikeButton.setImage(.iconReactionLike, for: .normal)
            reactionLikeButton.clipsToBounds = true
            
            stackView.addArrangedSubview(reactionLikeButton)
            reactionLikeButton.anchors.height.equal(anchors.height)
            reactionLikeButton.anchors.width.equal(anchors.height)
        }
    }
}

// MARK: API
extension AudienceOnLiveBottomToolbar {
    func setClassicGiftBtn(_ gift: LiveGift){
        classicBtnView.imageV.setImage(with: gift.giftURL)
        classicBtnView.label.text = gift.title
         
    }
}


extension AudienceOnLiveTopToolbar {
    var followButton: KKLoadingButton {
        return roomInfoToolbar.followButton
    }
      
    func setOwnerName(_ ownerName: String) {
        roomInfoToolbar.ownerNameLabel.text = ownerName
    }
    
    func setAudiencesCount(_ count: String) {
        audienceToolbar.audienceCountLabel.text = count
    }
    
    func setFollowButtonVisibility(_ isHidden: Bool) {
        roomInfoToolbar.configureFollow(isHidden) 
    }
    
    func setVerifiedIcon(_ isVerified: Bool) {
        roomInfoToolbar.verifitedIcon.isHidden = isVerified == false
    }
    
    func setOwnerPhoto(_ urlString: String) {
        roomInfoToolbar.userImageView.setImage(with: urlString, placeholder: .defaultProfileImage)
    }
    
    func setLikesCount(_ count: String) {
        roomInfoToolbar.likesLabel.text = count + " Likes"
        
        UIView.animate(withDuration: 0.3) {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
     
}
