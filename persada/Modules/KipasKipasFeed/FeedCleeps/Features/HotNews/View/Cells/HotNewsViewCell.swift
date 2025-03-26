//
//  HotNewsViewCell.swift
//  FeedCleeps
//
//  Created by DENAZMI on 04/10/23.
//

import Foundation
import UIKit
import TUIPlayerShortVideo
import Lottie
import Kingfisher
import KipasKipasShared
import KipasKipasDonationCart

extension Notification.Name {
    static let handleTapActionOnHotNewsCell = Notification.Name("handleTapActionOnHotNewsCell")
    public static let handleUpdateHotNewsCellComments = Notification.Name("handleUpdateHotNewsCellComments")
    static let handleUpdateFeedHotNewsCell = Notification.Name("handleUpdateFeedHotNewsCell")
}

enum HotNewsCellEvent {
    case onPlay
    case profile(feed: FeedItem?)
    case like(feed: FeedItem?)
    case share(feed: FeedItem?)
    case follow(feed: FeedItem?)
    case comment(feed: FeedItem?)
    case productDetail(feed: FeedItem?)
    case donationDetail(feed: FeedItem?)
    case shortcutStartPaidDM(feed: FeedItem?)
    case hashtag(feed: FeedItem?, value: String)
    case donationFilterCategory(feed: FeedItem?)
    case mention(feed: FeedItem?, value: String)
    case playPause(feed: FeedItem?, isPlay: Bool)
    case newsPortal(feed: FeedItem?, url: String)
    case shortcutLiveStreaming(feed: FeedItem?)
    case floatingLink(feed: FeedItem?)
    case contentSetting(feed: FeedItem?)
    case bookmark(feed: FeedItem?)
    case donationCart(feed: FeedItem?)
    case donateStuff(feed: FeedItem?)
}

class HotNewsViewCell: UIView {
    
    @IBOutlet weak var usernameStackView: UIStackView!
    @IBOutlet weak var profileContainer: UIStackView!
    @IBOutlet weak var layerView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var totalLikeLabel: UILabel!
    @IBOutlet weak var trendingAtLabel: UILabel!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var donationCartButton: UIImageView!
    @IBOutlet weak var donationNowButton: UIButton!
    @IBOutlet weak var donateGoodsButton: UIButton!
    @IBOutlet weak var blurView: UIVisualEffectView?
    @IBOutlet weak var verifiedImageView: UIImageView!
    @IBOutlet weak var donationCategoryLabel: UILabel!
    @IBOutlet weak var cardProductPriceLabel: UILabel!
    @IBOutlet weak var playPauseImageView: UIImageView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var zoomableView: ZoomableView?
    @IBOutlet weak var followIconImageView: UIImageView!
    @IBOutlet weak var videoProgressBar: UIProgressView!
    @IBOutlet weak var cardProductImageView: UIImageView!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var cardProductTitleNameLabel: UILabel!
    @IBOutlet weak var miniCardProductPriceLabel: UILabel!
    @IBOutlet weak var likeContainerStackView: UIStackView!
    @IBOutlet weak var donationCoverImageView: UIImageView?
    @IBOutlet weak var badgeDonationImageView: UIImageView!
    @IBOutlet weak var shareContainerStackView: UIStackView!
    @IBOutlet weak var captionView: KKScrollableCaptionView?
    @IBOutlet weak var cardProductContainerStackView: UIView!
    @IBOutlet weak var donationAmountCollectedLabel: UILabel!
    @IBOutlet weak var miniCardProductTitleNameLabel: UILabel!
    @IBOutlet weak var commentContainerStackView: UIStackView!
    @IBOutlet weak var donationAmountProgressBar: UIProgressView!
    @IBOutlet weak var trendingAtContainerStackView: UIStackView!
    @IBOutlet weak var shortcutNewsContainerStackView: UIStackView!
    @IBOutlet weak var cardDonationContainerStackView: UIStackView!
    @IBOutlet weak var bottomCommentContainerStackView: UIStackView!
    @IBOutlet weak var miniCardProductContainerStackView: UIStackView!
    @IBOutlet weak var filterCategoryDonationContainerStackView: UIView!
    @IBOutlet weak var donationCoverHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var donationActionStackView: UIStackView!
    @IBOutlet weak var shortcutStartPaidDMContainerStackView: UIStackView!
    @IBOutlet weak var bottomCommentParentContainerStackView: UIStackView!
    @IBOutlet weak var cardProductCloseIconContainerStackView: UIStackView!
    @IBOutlet weak var bottomCommentParentContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var productAdsImageView: LottieAnimationView?
    @IBOutlet weak var productAdsContainerStackView: UIStackView!
    @IBOutlet weak var coinPriceLabel: UILabel!
    @IBOutlet weak var sosmedContainerStackView: UIStackView!
    @IBOutlet weak var sosmedDimmedView: UIView!
    @IBOutlet weak var newsPortalImageView: UIImageView!
    @IBOutlet weak var image1ProfileLocalRank: UIImageView!
    @IBOutlet weak var image2ProfileLocalRank: UIImageView!
    @IBOutlet weak var image3ProfileLocalRank: UIImageView!
    @IBOutlet weak var bookmarkContainerStackView: UIStackView!
    @IBOutlet weak var bookmarkCountLabel: UILabel!
    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var bookmarkImageView: UIImageView!
    @IBOutlet weak var commentImageView: UIImageView!
    
    @IBOutlet weak var pushEmptyView: UIView!
    
    private lazy var floatingLinkView: FloatingLinkView? = {
        let view = FloatingLinkView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private lazy var levelPriorityView = LevelPriorityView()
    
    private var isLike: Bool = false {
        didSet { likeImageView.set("ic_like_\(isLike ? "solid_red" : "solid_border_white" )") }
    }
    
    private var isCaptionExpanded: Bool = false
    private var isPlay: Bool = true
    
    private var isShowShortcutStartPaidDM: Bool = false {
        didSet {
            shortcutStartPaidDMContainerStackView.isHidden = true //!isShowShortcutStartPaidDM
        }
    }
    
    private var feed: FeedItem = FeedItem() {
        didSet { setupView(with: feed) }
    }
    
    private var isHiddenShortcutSosmed: Bool = true {
        didSet {
            sosmedContainerStackView.isHidden = isHiddenShortcutSosmed
            sosmedDimmedView.isHidden = isHiddenShortcutSosmed
        }
    }
    
    weak var delegate: TUIPlayerShortVideoControlDelegate?
    var renderMode: TUI_Enum_Type_RenderMode = .RENDER_MODE_FILL_SCREEN
    var tuiPlayer: TUITXVodPlayer? {
        didSet {
            guard tuiPlayer != nil, oldValue != nil, tuiPlayer != oldValue else { return }
//            oldValue?.pausePlay()
//            oldValue?.removeVideo()
        }
    }
    
    private let layerLess = CAGradientLayer()
    private let layerMore = CAGradientLayer()
    private let clear = UIColor.clear.cgColor
    private let screenWidth  = UIScreen.main.bounds.size.width
    private let screenHeight = UIScreen.main.bounds.size.height
    private let tabBarHeight = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 34
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("framef = \(frame)")
        commonInit()
        userProfileImageView.layer.borderWidth = 1
        userProfileImageView.layer.borderColor = UIColor.white.cgColor
        sosmedContainerStackView.layer.borderWidth = 1
        sosmedContainerStackView.layer.borderColor = UIColor(hexString: "#504D4D").cgColor
        
        let shadowOffset = CGSize(width: 0, height: 0)
        usernameLabel.addDropShadow(radius: 1.5, opacity: 0.5, offset: shadowOffset)
        totalLikeLabel.addDropShadow(radius: 1.5, opacity: 0.5, offset: shadowOffset)
        commentCountLabel.addDropShadow(radius: 1.5, opacity: 0.5, offset: shadowOffset)
        bookmarkCountLabel.addDropShadow(radius: 1.5, opacity: 0.5, offset: shadowOffset)
        shareLabel.addDropShadow(radius: 1.5, opacity: 0.5, offset: shadowOffset)
        likeImageView.setImage(.iconLikeSolidBorderWhite)
        
        handleNotificationCenterObserver()
        handleTapComponents()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func commonInit() {
        let nibName = type(of: self).description().components(separatedBy: ".").last ?? ""
        let nib = UINib(nibName: nibName, bundle: Bundle.init(identifier: "com.koanba.kipaskipas.mobile.FeedCleeps"))
        if let view = nib.instantiate(withOwner: self, options: nil).first as? UIView {
            addSubview(view)
            view.frame = bounds
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
//            view.addSubview(floatingLinkView!)
            //floatingLinkView.anchor(top: view.topAnchor, left: view.leftAnchor, paddingTop: 156, paddingLeft: 8)
//            floatingLinkView?.anchor(top: view.topAnchor, right: view.rightAnchor, paddingTop: 158, paddingRight: 8)
            let longPressContentViewGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleContentLongPress(_:)))
            view.addGestureRecognizer(longPressContentViewGesture)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
//        handleTapPlayPause()
    }
}

extension HotNewsViewCell {
    
    private func handleNotificationCenterObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeedHotNewsCell(_:)), name: .handleUpdateFeedHotNewsCell, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateHotNewsCellComments(_:)), name: .handleUpdateHotNewsCellComments, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateIsFollowFromFolowingFolower(_:)), name: .updateIsFollowFromFolowingFolower, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateHotNewsCellCommentsFromProfileFeed(_:)), name: Notification.Name("handleUpdateHotNewsCellCommentsFromProfileFeed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateHotNewsCellLikesFromProfileFeed(_:)), name: Notification.Name("handleUpdateHotNewsCellLikesFromProfileFeed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleHiddenShortcutSosmed(_:)), name: Notification.Name("handleHiddenShortcutSosmed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDonationCartUpdated), name: DonationCartManagerNotification.updated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shouldPausePlayer), name: .shouldPausePlayer, object: nil)
    }
    
    private func setupView(with feed: FeedItem) {
        self.pushEmptyView.isHidden =   feed.feedType != .deletePush
        
        
        captionView?.reset()    // needed to reset more/less
        let isVerified = feed.account?.isVerified ?? false
        isLike = feed.isLike ?? false
//        isPlay = true
        isHiddenShortcutSosmed = true
        var trendingAt = feed.trendingAt ?? 0
        trendingAtLabel.text = trendingAt.toDateString(with: "dd/MM/yyyy HH:mm:ss")
//        print("mj3kj3riri3nieff", feed.account?.username ?? "-", trendingAt)
        commentCountLabel.text = feed.comments?.countFormat()
        verifiedImageView.isHidden = feed.account?.isVerified == false
        totalLikeLabel.text = feed.likes?.countFormat()
        usernameLabel.addDropShadow(radius: 3.0, opacity: 0.2, offset: CGSize(width: 2, height: 1))
        captionView?.textColor = .white
        
        weak var startAnimation = LottieAnimation.named("ads")
        DispatchQueue.main.async {
            self.productAdsImageView?.animation = startAnimation
            self.productAdsImageView?.animation = LottieAnimation.named("ads")
            self.productAdsImageView?.loopMode = LottieLoopMode.loop
            self.productAdsImageView?.play()
        }
        usernameLabel.text =   feed.account?.name ?? "-"
        userProfileImageView.kf.indicatorType = .activity
        //userProfileImageView.kf.setImage(with: URL(string: feed.account?.photo ?? ""), placeholder: UIImage.defaultProfileImageCircle)
        userProfileImageView.loadImage(at: feed.account?.photo ?? "", .w100, emptyImageName: "iconProfileEmpty")
        
        if feed.account?.isShowBadge == true {
            if let url = feed.account?.urlBadge, !url.isEmpty {
                badgeDonationImageView.loadImageWithoutOSS(at: url)
                badgeDonationImageView.isHidden = false
            } else {
                badgeDonationImageView.isHidden = true
            }
        } else {
            badgeDonationImageView.isHidden = true
        }
        
        isHiddenShortcutSosmed = true
        followIconImageView.isHidden = false
        
        
        cardDonationContainerStackView.isHidden = true
        filterCategoryDonationContainerStackView.isHidden = true
        shortcutNewsContainerStackView.isHidden = true
        donationCategoryLabel.isHidden = true
        videoProgressBar.isHidden = false
        blurView?.isHidden = isHideBlur()
        thumbnailImageView.isHidden = true
        shortcutStartPaidDMContainerStackView.isHidden = true
        miniCardProductContainerStackView.isHidden = true
        miniCardProductContainerStackView.alpha = 0
        cardProductContainerStackView.isHidden = false
        bottomCommentContainerStackView.isHidden = true
        productAdsContainerStackView.isHidden = false
        isHideBottomCommentContainer(value: true)
        cardProductContainerStackView.alpha = 1
        cardProductContainerStackView.transform = .identity
        image1ProfileLocalRank.isHidden = true
        image2ProfileLocalRank.isHidden = true
        image3ProfileLocalRank.isHidden = true
        trendingAtContainerStackView.isHidden = true
        
        switch feed.feedType {
        case .donation:
            cardDonationContainerStackView.isHidden = false
            followIconImageView.isHidden = feed.account?.isFollow == true
            
            
            cardProductContainerStackView.isHidden = true
            cardProductContainerStackView.alpha = 0
            shortcutStartPaidDMContainerStackView.isHidden = true
            thumbnailImageView.isHidden = true
            donationCategoryLabel.isHidden = false
            cardDonationContainerStackView.isHidden = false
            filterCategoryDonationContainerStackView.isHidden = false
            productAdsContainerStackView.isHidden = true
            donationCategoryLabel.text = feed.post?.donationCategory?.name ?? ""
            donationCategoryLabel.textColor = .white
            donationCategoryLabel.font = .Roboto(.regular, size: 12)
            let localRanks = feed.post?.localRanks
            
            let image1URL = localRanks?[safe: 0]?.photo ?? ""
            let image2URL = localRanks?[safe: 1]?.photo ?? ""
            let image3URL = localRanks?[safe: 2]?.photo ?? ""
            let showBadgeImage1 = localRanks?[safe: 0]?.isShowBadge ?? false
            let showBadgeImage2 = localRanks?[safe: 1]?.isShowBadge ?? false
            let showBadgeImage3 = localRanks?[safe: 2]?.isShowBadge ?? false

            let isHiddenImage1: Bool = image1URL.isEmpty
            let isHiddenImage2: Bool = image2URL.isEmpty
            let isHiddenImage3: Bool = image3URL.isEmpty
            
            image1ProfileLocalRank.isHidden = false
            image2ProfileLocalRank.isHidden = false
            image3ProfileLocalRank.isHidden = false
            
            if showBadgeImage1 {
                image1ProfileLocalRank.loadImageWith(url: image1URL, .w100, emptyImage: .defaultProfileImageSmallCircle)
            } else {
                image1ProfileLocalRank.image = .anonimProfilePhoto
            }
            
            DispatchQueue.main.async {
                if localRanks?[safe: 0] == nil {
                    self.image1ProfileLocalRank.isHidden = true
                } else {
                    if localRanks?[safe: 0]?.photo == nil {
                        self.image1ProfileLocalRank.image = .defaultProfileImageSmallCircle
                    } else {
                        self.image1ProfileLocalRank.isHidden = isHiddenImage1
                    }
                    
                }
            }
            
            if showBadgeImage2 {
                image2ProfileLocalRank.loadImageWith(url: image2URL, .w100, emptyImage: .defaultProfileImageSmallCircle)
            } else {
                image2ProfileLocalRank.image = .anonimProfilePhoto
            }
            
            DispatchQueue.main.async {
                if localRanks?[safe: 1] == nil {
                    self.image2ProfileLocalRank.isHidden = true
                } else {
                    if localRanks?[safe: 1]?.photo == nil {
                        self.image2ProfileLocalRank.image = .defaultProfileImageSmallCircle
                    } else {
                        self.image2ProfileLocalRank.isHidden = isHiddenImage2
                    }
                }
            }
            
            if showBadgeImage3 {
                image3ProfileLocalRank.loadImageWith(url: image3URL, .w100, emptyImage: .defaultProfileImageSmallCircle)
            } else {
                image3ProfileLocalRank.image = .anonimProfilePhoto
            }
            
            DispatchQueue.main.async {
                if localRanks?[safe: 2] == nil {
                    self.image3ProfileLocalRank.isHidden = true
                } else {
                    if localRanks?[safe: 2]?.photo == nil {
                        self.image3ProfileLocalRank.image = .defaultProfileImageSmallCircle
                    } else {
                        self.image3ProfileLocalRank.isHidden = isHiddenImage3
                    }
                }
            }
            
            setupDonationCard(feed: feed)
        case .hotNews:
            followIconImageView.isHidden = feed.account?.isFollow == true
            
            
            cardProductContainerStackView.isHidden = feed.post?.product == nil
            cardProductContainerStackView.alpha = feed.post?.product == nil ? 0 : 1
            shortcutNewsContainerStackView.isHidden = false
            //isShowShortcutStartPaidDM = isVerified ? feed.typePost != "donation" : false
            isShowShortcutStartPaidDM = false
            if isVideoExtension() {
                thumbnailImageView.isHidden = true
            } else {
                thumbnailImageView.isHidden = false
                thumbnailImageView.contentMode = .scaleAspectFit
                thumbnailImageView.loadImage(at: feed.post?.medias?.first?.thumbnail?.large ?? "", .w720, emptyImageName: "empty")
            }
            
            if let levelPriority = feed.post?.levelPriority, let createdAt = feed.createAt {
                levelPriorityView.set(priority: levelPriority, createdAt: createdAt)
                levelPriorityView.isHidden = KKRuntimeEnvironment.instance.type == .appstore
                usernameStackView.addArrangedSubview(levelPriorityView)
            }
        case .feed:
            trendingAtContainerStackView.isHidden = trendingAt == 0
            if let feedMediaType = feed.feedMediaType {
                let themeColor: UIColor = feedMediaType == .image ? UIColor(named: "#4A4A4A") ?? .black : .white
                usernameLabel.textColor = themeColor
                captionView?.textColor = themeColor
                captionView?.attributeTextColor = themeColor
                captionView?.expandToggleTextColor = themeColor
                
                if feedMediaType == .video {
                    usernameLabel.addDropShadow(radius: 3.0, opacity: 0.2, offset: CGSize(width: 2, height: 1))
                    captionView?.addDropShadow(color: .white, radius: 3.0, opacity: 0.0, offset: CGSize(width: 2, height: 1))
                } else {
                    usernameLabel.addDropShadow(color: .white, radius: 4.0, opacity: 0.5, offset: CGSize(width: 0, height: 0))
                    captionView?.addDropShadow(color: .white, radius: 4.0, opacity: 0.5, offset: CGSize(width: 0, height: 0))
                }
            }
            
            followIconImageView.isHidden = feed.account?.isFollow == true
            
            
            cardProductContainerStackView.isHidden = feed.post?.product == nil
            cardProductContainerStackView.alpha = feed.post?.product == nil ? 0 : 1
            //isShowShortcutStartPaidDM = isVerified ? feed.typePost != "donation" : false
            isShowShortcutStartPaidDM = false
            videoProgressBar.isHidden = !isVideoExtension()
            if feed.post?.medias?.first?.type == "image" {
                thumbnailImageView.isHidden = false
                thumbnailImageView.contentMode = .scaleAspectFit
                thumbnailImageView.setImageOSS(with: feed.post?.medias?.first?.thumbnail?.large, .w720)
                
                zoomableView?.isHidden = false
                zoomableView?.sourceView = thumbnailImageView
                zoomableView?.isZoomable = true
            } else {
                thumbnailImageView.isHidden = true
            }
        case .following:
            followIconImageView.isHidden = true
            
            
            cardProductContainerStackView.isHidden = feed.post?.product == nil
            cardProductContainerStackView.alpha = feed.post?.product == nil ? 0 : 1
            //isShowShortcutStartPaidDM = isVerified ? feed.typePost != "donation" : false
            isShowShortcutStartPaidDM = false
            videoProgressBar.isHidden = !isVideoExtension()
            if feed.post?.medias?.first?.type == "image" {
                thumbnailImageView.isHidden = false
                thumbnailImageView.contentMode = .scaleAspectFit
                thumbnailImageView.setImageOSS(with: feed.post?.medias?.first?.thumbnail?.large, .w720)
            } else {
                thumbnailImageView.isHidden = true
            }
        case .profile:
            followIconImageView.isHidden = true
            
            
            trendingAtContainerStackView.isHidden = true
            donationCategoryLabel.isHidden = false
            bottomCommentContainerStackView.isHidden = false
            isHideBottomCommentContainer(value: false)
            cardProductContainerStackView.isHidden = feed.post?.product == nil
            cardProductContainerStackView.alpha = feed.post?.product == nil ? 0 : 1
            videoProgressBar.isHidden = !isVideoExtension()
            
            //let createAt = feed.createAt?.timeAgoDisplay() ?? ""
            let createAt = feed.createAt?.soMuchTimeAgoMini() ?? ""
            
            donationCategoryLabel.text = " •  \(createAt)"
            //donationCategoryLabel.textColor = .white.withAlphaComponent(0.7)
            
            donationCategoryLabel.shadowColor = .darkGray
            donationCategoryLabel.shadowOffset = CGSize(width: 0.5, height: 0.4)  //Here you control x and y

            
            donationCategoryLabel.font = .Roboto(.medium, size: 12)
            if feed.typePost == "donation" {
                thumbnailImageView.isHidden = true
            } else {
                if feed.post?.medias?.first?.type == "image" {
                    thumbnailImageView.isHidden = false
                    thumbnailImageView.contentMode = .scaleAspectFit
                    thumbnailImageView.setImageOSS(with: feed.post?.medias?.first?.thumbnail?.large, .w720)
                } else {
                    thumbnailImageView.isHidden = true
                }
            }
            
            if feed.account?.id == getUserLoginId() {
                followIconImageView.isHidden = true
                
                
                isShowShortcutStartPaidDM = false
            } else {
                followIconImageView.isHidden = feed.account?.isFollow == true
                
                
                //isShowShortcutStartPaidDM = isVerified ? feed.typePost != "donation" : false
                isShowShortcutStartPaidDM = false
            }
            
            setupDonationCard(feed: feed)
        case .explore:
            followIconImageView.isHidden = true
            
            
            trendingAtContainerStackView.isHidden = true
            donationCategoryLabel.isHidden = false
            bottomCommentContainerStackView.isHidden = false
            isHideBottomCommentContainer(value: false)
            cardProductContainerStackView.isHidden = feed.post?.product == nil
            cardProductContainerStackView.alpha = feed.post?.product == nil ? 0 : 1
            //isShowShortcutStartPaidDM = isVerified ? feed.typePost != "donation" : false
            isShowShortcutStartPaidDM = false
            videoProgressBar.isHidden = !isVideoExtension()
            let createAt = feed.createAt?.timeAgoDisplay() ?? ""
            donationCategoryLabel.text = " •  \(createAt)"
            donationCategoryLabel.textColor = .white.withAlphaComponent(0.7)
            donationCategoryLabel.font = .Roboto(.medium, size: 12)
            
            if feed.post?.medias?.first?.type == "image" {
                thumbnailImageView.isHidden = false
                thumbnailImageView.contentMode = .scaleAspectFit
                thumbnailImageView.setImageOSS(with: feed.post?.medias?.first?.thumbnail?.large, .w720)
            } else {
                thumbnailImageView.isHidden = true
            }
            
            if feed.account?.id == getUserLoginId() {
                followIconImageView.isHidden = true
                
                
                isShowShortcutStartPaidDM = false
            } else {
                followIconImageView.isHidden = feed.account?.isFollow == true
                
                
                //isShowShortcutStartPaidDM = isVerified ? feed.typePost != "donation" : false
                isShowShortcutStartPaidDM = false
            }
            
            setupDonationCard(feed: feed)
        case .channel:
            followIconImageView.isHidden = true
            
            
            trendingAtContainerStackView.isHidden = true
            donationCategoryLabel.isHidden = false
            bottomCommentContainerStackView.isHidden = false
            isHideBottomCommentContainer(value: false)
            cardProductContainerStackView.isHidden = feed.post?.product == nil
            cardProductContainerStackView.alpha = feed.post?.product == nil ? 0 : 1
            //isShowShortcutStartPaidDM = isVerified ? feed.typePost != "donation" : false
            isShowShortcutStartPaidDM = false
            videoProgressBar.isHidden = !isVideoExtension()
            let createAt = feed.createAt?.timeAgoDisplay() ?? ""
            donationCategoryLabel.text = " •  \(createAt)"
            donationCategoryLabel.textColor = .white.withAlphaComponent(0.7)
            donationCategoryLabel.font = .Roboto(.medium, size: 12)
            
            if feed.post?.medias?.first?.type == "image" {
                thumbnailImageView.isHidden = false
                thumbnailImageView.contentMode = .scaleAspectFit
                thumbnailImageView.setImageOSS(with: feed.post?.medias?.first?.thumbnail?.large, .w720)
            } else {
                thumbnailImageView.isHidden = true
            }
            
            if feed.account?.id == getUserLoginId() {
                followIconImageView.isHidden = true
                
                
                isShowShortcutStartPaidDM = false
            } else {
                followIconImageView.isHidden = feed.account?.isFollow == true
                
                
                //isShowShortcutStartPaidDM = isVerified ? feed.typePost != "donation" : false
                isShowShortcutStartPaidDM = false
            }
            
            setupDonationCard(feed: feed)
        case .searchTop:
            followIconImageView.isHidden = true
            trendingAtContainerStackView.isHidden = true
            donationCategoryLabel.isHidden = false
            bottomCommentContainerStackView.isHidden = false
            isHideBottomCommentContainer(value: false)
            cardProductContainerStackView.isHidden = feed.post?.product == nil
            cardProductContainerStackView.alpha = feed.post?.product == nil ? 0 : 1
            //isShowShortcutStartPaidDM = isVerified ? feed.typePost != "donation" : false
            isShowShortcutStartPaidDM = false
            videoProgressBar.isHidden = !isVideoExtension()
            let createAt = feed.createAt?.timeAgoDisplay() ?? ""
            donationCategoryLabel.text = " •  \(createAt)"
            donationCategoryLabel.textColor = .white.withAlphaComponent(0.7)
            donationCategoryLabel.font = .Roboto(.medium, size: 12)
            
            if feed.post?.medias?.first?.type == "image" {
                thumbnailImageView.isHidden = false
                thumbnailImageView.contentMode = .scaleAspectFit
                thumbnailImageView.setImageOSS(with: feed.post?.medias?.first?.thumbnail?.large, .w720)
            } else {
                thumbnailImageView.isHidden = true
            }
            
            if feed.account?.id == getUserLoginId() {
                followIconImageView.isHidden = true
                isShowShortcutStartPaidDM = false
            } else {
                followIconImageView.isHidden = feed.account?.isFollow == true
                //isShowShortcutStartPaidDM = isVerified ? feed.typePost != "donation" : false
                isShowShortcutStartPaidDM = false
            }
            
            setupDonationCard(feed: feed)
        default:
            followIconImageView.isHidden = true
            videoProgressBar.isHidden = true
            thumbnailImageView.isHidden = true
        }
        
        //setupFloatingLink()
        setupDescription(feed: feed)
        //setupProduct(with: feed.post?.product)
        if let product = feed.post?.product {
            setupProduct(with: product)
        }

        donationCategoryLabel.addDropShadow(radius: 3.0, opacity: 0.2, offset: CGSize(width: 2, height: 1))
        
        newsPortalImageView.kf.setImage(with: URL(string: "https://koanba-storage-prod.oss-cn-hongkong.aliyuncs.com/assets_public/mobile/portal_news/entry_point.png")!, options: [.forceRefresh])
    }
    
    func configureuserProfileImageViewTapGestures() {
        userProfileImageView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapUserProfile(_:)))
        userProfileImageView.addGestureRecognizer(tapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        userProfileImageView.addGestureRecognizer(longPressGesture)
        
        
    }
    
    @objc func handleOnTapUserProfile(_ gesture: UITapGestureRecognizer) {
        handleTapProfile()
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        
        guard getToken() != nil else { return }
        
        switch gesture.state {
        case .began:
            print("[azmi]- show")
            isHiddenShortcutSosmed = false
            playPause(isPlay: false)
//            postNotifCenter(with: .bookmark(feed: feed))
        case .ended:
            print("[azmi]- hide")
        default:
            break
        }
    }
    
    @objc func handleContentLongPress(_ gesture: UILongPressGestureRecognizer) {
        
        guard getToken() != nil else { return }
        
        switch gesture.state {
        case .began:
            print("[azmi]- show")
            delegate?.customCallbackEvent?(HotNewsCellEvent.contentSetting(feed: feed))
        case .ended:
            print("[azmi]- hide")
        default:
            break
        }
    }
    
    private func handleTapComponents() {
        likeContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.handleTapLike()
        }
        
        commentContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.customCallbackEvent?(HotNewsCellEvent.comment(feed: feed))
        }
        
        shareContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.customCallbackEvent?(HotNewsCellEvent.share(feed: feed))
        }
        
        configureuserProfileImageViewTapGestures()
        
        sosmedDimmedView.onTap { [weak self] in
            guard let self = self else { return }
            
            self.isHiddenShortcutSosmed = true
            self.playPause(isPlay: true)
        }
        
        usernameLabel.onTap { [weak self] in
            guard let self = self else { return }
            self.handleTapProfile()
        }
        
        trendingAtContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.trendingAtLabel.isHidden = !self.trendingAtLabel.isHidden
        }
        
        filterCategoryDonationContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.customCallbackEvent?(HotNewsCellEvent.donationFilterCategory(feed: feed))
        }
        
        shortcutStartPaidDMContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.customCallbackEvent?(HotNewsCellEvent.shortcutStartPaidDM(feed: feed))
        }
        
        followIconImageView.onTap { [weak self] in
            guard let self = self else { return }
            self.handleTapFollowAccount()
        }
        
        cardProductCloseIconContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.handleCloseCardProduct()
        }
        
        cardProductContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.customCallbackEvent?(HotNewsCellEvent.productDetail(feed: feed))
        }
        
        bottomCommentContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.customCallbackEvent?(HotNewsCellEvent.comment(feed: feed))
        }
        
        miniCardProductContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.customCallbackEvent?(HotNewsCellEvent.productDetail(feed: feed))
        }
        
        cardDonationContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.customCallbackEvent?(HotNewsCellEvent.donationDetail(feed: feed))
        }
        
        donationNowButton.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.customCallbackEvent?(HotNewsCellEvent.donationDetail(feed: feed))
        }
        
        donateGoodsButton.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.customCallbackEvent?(HotNewsCellEvent.donateStuff(feed: feed))
        }
        
        bookmarkContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.customCallbackEvent?(HotNewsCellEvent.bookmark(feed: feed))
        }
        
        donationCartButton.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.customCallbackEvent?(HotNewsCellEvent.donationCart(feed: feed))
        }
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSingleTapForPlayPause))
        layerView.isUserInteractionEnabled = true
        singleTapGesture.numberOfTapsRequired = 1
        layerView.addGestureRecognizer(singleTapGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapForLike))
        layerView.isUserInteractionEnabled = true
        doubleTapGesture.numberOfTapsRequired = 2
        layerView.addGestureRecognizer(doubleTapGesture)
        
        singleTapGesture.require(toFail: doubleTapGesture)
    }
    
    @objc func handleSingleTapForPlayPause() {
        print("hdrcvdswegwegwegwe, play pause", isPlay)
        handleTapPlayPause()
    }
    
    @objc func shouldPausePlayer() {
        guard isVideoExtension() else {
            return
        }
        isPlay = false
        playPause(isPlay: isPlay)
    }
    
    @objc func handleDoubleTapForLike() {
        print("hdrcvdswegwegwegwe, like", isPlay)
        guard feed.isLike == false else { return }
        handleTapLike()
    }
    
    private func isHideBottomCommentContainer(value: Bool) {
        bottomCommentParentContainerHeightConstraint.constant = value ? 0 : 70
        layoutIfNeeded()
    }
    
    private func getToken()  -> String? {
        let KEY_AUTH_TOKEN = "KEY_AUTH_TOKEN"
        
        if let token = DataCache.instance.readString(forKey: KEY_AUTH_TOKEN) {
            if token != "" {
                return token
            }
        }
        
        return nil
    }
    
    private func getUserLoginId() -> String? {
        return UserDefaults.standard.string(forKey: "USER_LOGIN_ID")
    }
    
    
    @objc private func handleHiddenShortcutSosmed(_ notification: Notification) {
        isHiddenShortcutSosmed = true
    }
    
    @objc private func handleUpdateHotNewsCellLikesFromProfileFeed(_ notification: Notification) {
        guard let object = notification.userInfo as? [String: Any] else { return }
        guard feed.post?.id == object["postId"] as? String else { return }
        
        if let accountId = object["accountId"] as? String, accountId == feed.account?.id {
            feed.likes = object["likes"] as? Int
            feed.isLike = object["isLike"] as? Bool
            KKFeedLike.instance.add(feedId: feed.id ?? "", isLike: feed.isLike ?? false, countLike: feed.likes ?? 0)
            isLike = feed.isLike ?? false
            model = feed
            likeImageView.set("ic_like_\(isLike ? "solid_red" : "solid_white" )")
            feed.comments = object["comments"] as? Int
            commentCountLabel.text = feed.comments?.countFormat()
        }
    }
    
    @objc private func handleUpdateHotNewsCellCommentsFromProfileFeed(_ notification: Notification) {
        guard let object = notification.userInfo as? [String: Any] else { return }
        guard feed.post?.id == object["postId"] as? String else { return }
        
        if let accountId = object["accountId"] as? String, accountId == feed.account?.id {
            feed.comments = object["comments"] as? Int
            commentCountLabel.text = feed.comments?.countFormat()
            model = feed
        }
    }
    
    @objc private func handleUpdateIsFollowFromFolowingFolower(_ notification: Notification) {
        guard let object = notification.userInfo as? [String: Any] else { return }
        
        if let accountId = object["accountId"] as? String, accountId == feed.account?.id {
            feed.account?.isFollow = object["isFollow"] as? Bool
            followIconImageView.isHidden = feed.account?.isFollow == true
            model = feed
            KKFeedFollow.instance.add(accountId: feed.account?.id ?? "", isFollow: feed.account?.isFollow ?? false)
        }
    }
    
    @objc private func handleUpdateHotNewsCellComments(_ notification: Notification) {
        guard let feed = notification.object as? FeedItem else { return }
        guard self.feed.feedType == feed.feedType && self.feed.id ?? "" == feed.id ?? "" else { return }
        commentCountLabel.text = feed.comments?.countFormat()
        self.feed.comments = feed.comments
    }
    
    @objc private func handleUpdateFeedHotNewsCell(_ notification: Notification) {
        guard let newFeed = notification.object as? FeedItem else { return }
        guard feed.feedType == newFeed.feedType && feed.id ?? "" == newFeed.id ?? "" else { return }
        feed = newFeed
        setupDonationCard(feed: newFeed)
        KKFeedLike.instance.add(feedId: feed.id ?? "", isLike: feed.isLike ?? false, countLike: feed.likes ?? 0)
    }
    
    @objc private func handleUpdateLocalRank(_ notification: Notification) {
        guard let urls = notification.object as? [String] else { return }
        
//        handleLocalRanks(image1URL: urls[safe: 0], image2URL: urls[safe: 1], image3URL: urls[safe: 2])
    }
    
    private func setupDescription(feed: FeedItem) {
        setupOverlayLayer()
        let isDonation = feed.typePost == "donation"
        let description = isDonation ? feed.post?.title : feed.post?.description
        
        shouldShowOverlay(captionView!.isExpanded)
        
        captionView?.text = description ?? ""
        captionView?.font = .roboto(.regular, size: 15)
        captionView?.attributeFont = .roboto(.medium, size: 15)
        coinPriceLabel.text = "\(feed.account?.chatPrice ?? 1)"
        
        captionView?.mentionTapHandler = { [weak self] in
            guard let self = self else { return }
            self.delegate?.customCallbackEvent?(HotNewsCellEvent.mention(feed: feed, value: $0))
        }
        
        captionView?.hashtagTapHandler = { [weak self] in
            guard let self = self else { return }
            self.delegate?.customCallbackEvent?(HotNewsCellEvent.hashtag(feed: feed, value: $0))
        }
        
        captionView?.toggleExpandHandler = { [weak self] isExpanded in
            guard let self = self else { return }
            self.shouldShowOverlay(isExpanded)
        }
        
    }

    func shouldShowOverlay(_ isExpanded: Bool) {
        isExpanded ? self.setupOverlayMoreLayer() : self.setupOverlayLayer()
    }

    private func setupOverlayLayer() {
        let blackLess = UIColor.black.withAlphaComponent(0.1).cgColor
        let blackMiddle = UIColor.black.withAlphaComponent(0.2).cgColor
        let blackDark = UIColor.black.withAlphaComponent(0.4).cgColor
        
        if let feedMediaType = feed.feedMediaType, feedMediaType == .image {
            layerLess.colors = [clear]
            layerView.isHidden = true
        } else {
            layerView.isHidden = false
            layerLess.colors = [
                blackMiddle, blackLess,
                //clear, clear,clear, clear, clear, clear, clear, clear, clear, clear, clear, clear, clear, clear,
                //blackLess, blackMiddle, blackDark
                clear, clear,clear, clear, clear, clear, clear, clear, clear, clear, clear, clear, clear, blackLess,
                blackMiddle, blackMiddle, blackMiddle
            ]
        }
        
        layerLess.startPoint = CGPoint(x: 0.0, y: 0.0)
        layerLess.endPoint = CGPoint(x: 0, y: 1)
        layerLess.frame = CGRectMake(0, 0, screenWidth, screenHeight - (feed.feedType == .profile ? 70 : tabBarHeight))
        layerMore.removeFromSuperlayer()
        layerView.backgroundColor = .clear
        layerView.layer.addSublayer(layerLess)
    }
    
    private func setupOverlayMoreLayer() {
        //var color = UIColor.black.withAlphaComponent(0.45).cgColor
        var color = UIColor.black.withAlphaComponent(0.55).cgColor
        
        if let feedMediaType = feed.feedMediaType {
            let colorWhite = UIColor.white.withAlphaComponent(0.65).cgColor
            let colorBlack = UIColor.black.withAlphaComponent(0.45).cgColor
            color = feedMediaType == .image ? colorWhite : colorBlack
            layerView.isHidden = false
        }
        
        layerMore.colors = [clear, color, color, color]        
//        layerMore.startPoint = CGPoint(x: 1, y: 1)
//        layerMore.endPoint = CGPoint(x: 1, y: 1)
//        layerMore.startPoint = CGPoint(x: 0.0, y: 0.0)
        layerMore.startPoint = CGPoint(x: 0.0, y: 0.5)
        layerMore.endPoint = CGPoint(x: 0, y: 1)
        
        layerMore.frame = CGRectMake(0, 0, screenWidth, screenHeight - (feed.feedType == .profile ? 70 : tabBarHeight))
        layerLess.removeFromSuperlayer()
        layerView.backgroundColor = .clear
        layerView.layer.addSublayer(layerMore)
    }

    private func handleTapLike() {
        guard getToken() != nil else {
            delegate?.customCallbackEvent?(HotNewsCellEvent.like(feed: feed))
            return
        }
        
//        if feed.isLike == false {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                KKLikeAnimation.shared.show()
//            }
//        }
        
        feed.likes = feed.isLike == true ? (feed.likes ?? 0) - 1 : (feed.likes ?? 0) + 1
        feed.isLike?.toggle()
        
        if let feedId = feed.id {
            KKFeedLike.instance.add(feedId: feedId, isLike: feed.isLike ?? false, countLike: feed.likes ?? 0)
        }
        
        model = feed
        delegate?.customCallbackEvent?(HotNewsCellEvent.like(feed: feed))
    }
    
    private func handleTapProfile() {
//        guard feed.feedType != .profile else { return }
        delegate?.customCallbackEvent?(HotNewsCellEvent.profile(feed: feed))
    }
    
    @objc private func handleTapPlayPause() {
        
        guard isVideoExtension() else {
            return
        }
        
        isPlay.toggle()
        playPause(isPlay: isPlay)
    }
    
    @objc private func handleDonationCartUpdated() {
        updateDonationCartView(feed: feed)
    }
    
    private func handleTapFollowAccount() {
        
        guard getToken() != nil else {
            delegate?.customCallbackEvent?(HotNewsCellEvent.follow(feed: feed))
            return
        }
        
        feed.account?.isFollow = true
        model = feed
                
        followIconImageView.isHidden = true
        
        if let accountId = feed.account?.id {
            KKFeedFollow.instance.add(accountId: accountId, isFollow: feed.account?.isFollow ?? false)
        }
        delegate?.customCallbackEvent?(HotNewsCellEvent.follow(feed: feed))
    }
    
    private func playPause(isPlay: Bool) {
        playPauseImageView.isHidden = isPlay
        delegate?.customCallbackEvent?(HotNewsCellEvent.playPause(feed: feed, isPlay: isPlay))
    }
    
    private func setupDonationCard(feed: FeedItem) {
        
        guard feed.typePost == "donation" else {
            cardDonationContainerStackView.isHidden = true
            return
        }
        
        let isCurrentUser = feed.account?.id == getUserLoginId()
        donationCoverHeightConstraint.constant = isCurrentUser ? 52 : 86
        donationActionStackView.isHidden = isCurrentUser
        layoutIfNeeded()
        
        cardDonationContainerStackView.isHidden = false
        donationAmountProgressBar.alpha = feed.post?.targetAmount == 0.0 ? 0.0 : 1
        
        let isNotDonationItem = feed.post?.isDonationItem == false
        
        donateGoodsButton.isHidden = isCurrentUser || isNotDonationItem
        donationNowButton.isHidden = isCurrentUser
        donationNowButton.setImage(isNotDonationItem ? nil : UIImage(named: "ic_money"), for: .normal)
        donationNowButton.setTitle(isNotDonationItem ? "Donasi Sekarang" : "Donasi Uang")
        
        donationCoverImageView?.isHidden = true
        //donationCoverImageView?.loadImage(at: feed.post?.medias?.first?.thumbnail?.medium ?? "", .w140, emptyImageName: "empty")
        
        
        var amountCollectedPercent: Float {
            return Float(Double(feed.post?.amountCollected ?? 0.0) / Double(feed.post?.targetAmount ?? 0.0))
        }
        
        donationAmountProgressBar.progress = amountCollectedPercent
        
        let amountCollected = feed.post?.amountCollected?.toMoney() ?? "Rp 0"
        let amountCollectedAttribute = amountCollected.attributedText(font: .Roboto(.bold, size: 15), textColor: .primary)
        
        if let targetAmount = feed.post?.targetAmount, targetAmount != 0.0 {
            let targetAmountAttribute = " / \(targetAmount.toMoney())".attributedText(font: .Roboto(.bold, size: 10), textColor: .contentGrey)
            amountCollectedAttribute.append(targetAmountAttribute)
        }

        donationAmountCollectedLabel.attributedText = amountCollectedAttribute
        updateDonationCartView(feed: feed)
    }
    
//    private func handleImageLocalRank(imageURL: String?, isShowBadge: Bool?, imageProfile: UIImageView) {
//        if let url = imageURL {
//            if let isShow = isShowBadge {
//                if isShow {
//                    imageProfile.loadImage(at: url, emptyImageName: "iconPersonFill")
//                    imageProfile.backgroundColor = .clear
//                } else {
//                    imageProfile.image = UIImage(named: "anonim-profile-photo")
//                }
//            } else {
//                imageProfile.image = UIImage(named: "anonim-profile-photo")
//            }
//        } else {
//            imageProfile.image = UIImage(named: "anonim-profile-photo")
//        }
//
//        imageProfile.isHidden = imageURL == nil
//    }
    
    private func handleLocalRanks(image1URL: String, image2URL: String, image3URL: String) {
        
//        image1ProfileLocalRank.isHidden = image1URL.isEmpty
//        image2ProfileLocalRank.isHidden = image2URL.isEmpty
//        image3ProfileLocalRank.isHidden = image3URL.isEmpty
        
//        image2ProfileLocalRank.loadImageWithoutOSS(at: image2URL)
//        image3ProfileLocalRank.loadImageWithoutOSS(at: image3URL)
        
//        image1ProfileLocalRank.loadImage(at: image1URL, .w360, emptyImageName: "iconProfileEmpty")
        
//        if let image1 = image1URL {
//            image1ProfileLocalRank.setImageOSS(with: image1, .w240)
//            image1ProfileLocalRank.backgroundColor = .clear
//            image1ProfileLocalRank.isHidden = false
//        }
//
//        if let image2 = image2URL {
//            image2ProfileLocalRank.loadImage(at: image2, .w240)
//            image2ProfileLocalRank.backgroundColor = .clear
//            image2ProfileLocalRank.isHidden = false
//        }
//
//        if let image3 = image3URL {
//            image3ProfileLocalRank.loadImage(at: image3, .w100)
//            image3ProfileLocalRank.backgroundColor = .clear
//            image3ProfileLocalRank.isHidden = false
//        }
        
//        image3ProfileLocalRank.isHidden = image3URL == nil
//        image2ProfileLocalRank.isHidden = image2URL == nil
//        image1ProfileLocalRank.isHidden = image1URL == nil
    }
    
    private func updateDonationCartView(feed: FeedItem) {
        let asset: AssetEnum = DonationCartManager.instance.isAdded(id: feed.id ?? "") ? .iconDonationCartPink : .iconDonationCartAddPink
        donationCartButton.image = UIImage(named: .get(asset))?.withTintColor(.white)
    }
    
    private func setupProduct(with product: FeedProduct?) {
        cardProductImageView.loadImage(at: product?.medias?.first?.thumbnail?.small ?? "", .w240)
        cardProductTitleNameLabel.text = product?.name ?? ""
        cardProductPriceLabel.text = product?.price?.toMoney()
        miniCardProductTitleNameLabel.text = product?.name ?? ""
        miniCardProductPriceLabel.text = product?.price?.toMoney()
    }
    
    private func handleCloseCardProduct() {
        guard !cardProductContainerStackView.isHidden else { return }
        
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self = self else { return }
            self.cardProductContainerStackView.transform = .init(translationX: 0, y: -50)
            self.cardProductContainerStackView.alpha = 0
            self.cardProductContainerStackView.isHidden = true
            self.miniCardProductContainerStackView.alpha = 1
            self.miniCardProductContainerStackView.isHidden = false
        }
    }
    @IBAction func didClickShortcutSosmedButton(_ sender: UIButton) {
//        var url: String {
//            switch sender.tag {
//            case 0: return "https://www.instagram.com/mastercorbuzier"
//            case 1: return "https://www.youtube.com/@corbuzier"
//            case 2: return "https://www.tiktok.com/@mastercorbuzier"
//            case 3: return "https://www.twitter.com/corbuzier"
//            case 4: return "https://www.facebook.com/mastercorbuzier"
//            default: return ""
//            }
//        }
        
//        postNotifCenter(with: .newsPortal(feed: feed, url: url))
        delegate?.customCallbackEvent?(HotNewsCellEvent.bookmark(feed: feed))
    }
    
    @IBAction func didClickViewProfileOnShortcutSosmedButton(_ sender: UIButton) {
        isHiddenShortcutSosmed = true
        handleTapProfile()
    }
    
    @IBAction func didClickShortcutNewsButton(_ sender: UIButton) {
        let news = ["kompas", "detik", "cnnindonesia", "cumicumi", "suara"]
        let url = "https://www.\(news[sender.tag]).com/"
        delegate?.customCallbackEvent?(HotNewsCellEvent.newsPortal(feed: feed, url: url))
    }
    
    private func isHideBlur() -> Bool {
        if isVideoExtension() || feed.post?.medias?.first?.type == "video" {
            return true
        }
        
        return feed.coverPictureUrl == HotnewsCoverManager.instance.themeUrl
    }
    
    private func isVideoExtension() -> Bool {
        return KKMediaItemExtension.isVideo(feed.videoUrl) || feed.videoUrl.hasSuffix(".m3u8")
    }
    
    private func setupFloatingLink() {
        floatingLinkView?.delegate = self
        floatingLinkView?.viewMargin = .init(top: 158, left: 8, bottom: 16, right: 8)
        
        let post = feed.post
        floatingLinkView?.alpha = (post?.floatingLink?.isEmpty ?? true) ? 0 : 1
        floatingLinkView?.isHidden = (post?.floatingLink?.isEmpty ?? true)
        floatingLinkView?.setupView(title: post?.floatingLinkLabel, siteName: post?.siteName, siteLogo: post?.siteLogo, accountPhotoUrl: feed.account?.photo)
    }
}

extension HotNewsViewCell: FloatingLinkViewDelegate {
    func didClose() {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            guard let self = self else { return }
            self.floatingLinkView?.alpha = 0 }, completion: { [weak self] _ in
                guard let self = self else { return }
                self.floatingLinkView?.isHidden = true
        })
    }
    
    func didOpen() {
        delegate?.customCallbackEvent?(HotNewsCellEvent.floatingLink(feed: feed))
    }
}

extension HotNewsViewCell: TUIPlayerShortVideoControl {
    func onPlayEvent(_ player: TUITXVodPlayer, event EvtID: Int32, withParam param: [AnyHashable : Any]) {
        delegate?.customCallbackEvent?(HotNewsCellEvent.onPlay)
        guard renderMode == .RENDER_MODE_FILL_EDGE else { return }
        guard player.currentPlaybackTime() < 1 else { return }
        player.setRenderMode(renderMode)
    }
    
    func getPlayer(_ player: TUITXVodPlayer) {
        tuiPlayer = player
        if let media = feed.post?.medias?.first, media.type == "video", isVideoExtension() {
            let width = Double(media.metadata?.width ?? "550") ?? 550
            let height =  Double(media.metadata?.height ?? "550") ?? 550
            
            let ratio = height / width
            if width >= height {
                renderMode = .RENDER_MODE_FILL_EDGE
            } else {
                if(ratio < 1.5){
                    renderMode = .RENDER_MODE_FILL_EDGE
                } else {
                    renderMode = .RENDER_MODE_FILL_SCREEN
                }
            }
        }
    }
    
    var model: TUIPlayerVideoModel {
        get { feed }
        set {
            var item: FeedItem = FeedItem()
            
            if let feed = newValue as? FeedItem {
                if let feedId = feed.id {
                    if let feedExist =  KKFeedLike.instance.isExist(feedId: feedId) {
                        feed.likes = feedExist.countLike
                        feed.isLike = feedExist.isLike
                    }
                }
                
                item = feed
            }
            
            item.coverPictureUrl = newValue.coverPictureUrl
            item.videoUrl = newValue.videoUrl
            item.duration = newValue.duration
            feed = item
        }
    }
    
    var currentPlayerStatus: TUITXVodPlayerStatus {
        get { return self.currentPlayerStatus }
        set(currentPlayerStatus) {}
    }
    
    func setCurrentTime(_ time: Float) {
        isHiddenShortcutSosmed = true
        if let feedId = feed.id {
            if let feedExist =  KKFeedLike.instance.isExist(feedId: feedId) {
                feed.likes = feedExist.countLike
                feed.isLike = feedExist.isLike
                isLike = feedExist.isLike
                totalLikeLabel.text = feed.likes?.countFormat()
            }
        }
        
        if Int(time) >= 2 {
            handleCloseCardProduct()
        }
    }
    
    func setProgress(_ progress: Float) {
        isHiddenShortcutSosmed = true
        // PE-11985, prevent flicker progress from 0.0 then suddenly 1.0 when play
        if(progress < 1.0){
            videoProgressBar.setProgress(progress, animated: false)
        }
        
        isPlay = true
        playPauseImageView.isHidden = true
    }
    
    func reloadData() {}
    func showCenterView() {}
    func hideCenterView() {}
    func showLoadingView() {}
    func hiddenLoadingView() {}
    func setDurationTime(_ time: Float) {}
    func showSlider() {}
    func hideSlider() {}
}

extension Array {
    subscript (safe index: Index) -> Element? {
        0 <= index && index < count ? self[index] : nil
    }
}
