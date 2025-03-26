//
//  ProfileFeedViewCell.swift
//  FeedCleeps
//
//  Created by DENAZMI on 01/11/23.
//

import Foundation
import UIKit
import TUIPlayerShortVideo
import KipasKipasShared

extension Notification.Name {
    static let handleTapActionOnProfileFeedCell = Notification.Name("handleTapActionOnProfileFeedCell")
    public static let handleUpdateProfileFeedCellComments = Notification.Name("handleUpdateProfileFeedCellComments")
    public static let handleUpdateProfileFeed = Notification.Name("handleUpdateProfileFeed")
}

public enum ProfileFeedCellTapAction {
    case like(feed: FeedItem?)
    case comment(feed: FeedItem?)
    case share(feed: FeedItem?)
    case profile(feed: FeedItem?)
    case playPause(feed: FeedItem?, isPlay: Bool)
    case hashtag(feed: FeedItem?, value: String)
    case mention(feed: FeedItem?, value: String)
    case shortcutStartPaidDM(feed: FeedItem?)
    case follow(feed: FeedItem?)
    case donationDetail(feed: FeedItem?)
}

class ProfileFeedViewCell: UIView {
    
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var videoProgressBar: UIProgressView!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var verifiedImageView: UIImageView!
    @IBOutlet weak var totalLikeLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var likeContainerStackView: UIStackView!
    @IBOutlet weak var commentContainerStackView: UIStackView!
    @IBOutlet weak var shareContainerStackView: UIStackView!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var captionView: KKScrollableCaptionView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var shortcutStartPaidDMContainerStackView: UIStackView!
    @IBOutlet weak var followIconImageView: UIImageView!
    @IBOutlet weak var bottomCommentContainerStackView: UIStackView!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var donationAmountLabel: UILabel!
    @IBOutlet weak var donationCoverImageView: UIImageView!
    @IBOutlet weak var donationProgressBar: UIProgressView!
    @IBOutlet weak var donationNowButton: UIButton!
    @IBOutlet weak var cardDonationContainerStackView: UIStackView!
    @IBOutlet weak var donationCoverImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var layerView: UIView!
    @IBOutlet weak var cardProductContainerStackView: UIView!
    @IBOutlet weak var cardProductTitleNameLabel: UILabel!
    @IBOutlet weak var cardProductImageView: UIImageView!
    @IBOutlet weak var cardProductPriceLabel: UILabel!
    @IBOutlet weak var cardProductCloseIconContainerStackView: UIStackView!
    @IBOutlet weak var miniCardProductContainerStackView: UIStackView!
    @IBOutlet weak var miniCardProductTitleNameLabel: UILabel!
    @IBOutlet weak var miniCardProductPriceLabel: UILabel!
    
    weak var delegate: TUIPlayerShortVideoControlDelegate?
    
    private let layerLess = CAGradientLayer()
    private let layerMore = CAGradientLayer()
    private var timer: Timer?
    private var cardProductSecondsLeft = 3
    
    private var isLike: Bool = false {
        didSet {
            likeImageView.set("ic_like_\(isLike ? "fill_red" : "outline_white" )")
        }
    }
    
    private var isPlay: Bool = true {
        didSet {
            playImageView.isHidden = isPlay
        }
    }
    
    private var feed: FeedItem = FeedItem() {
        didSet {
            isLike = feed.isLike ?? false

            isPlay = true
            miniCardProductContainerStackView.isHidden = true
            cardProductContainerStackView.isHidden = false
            
            if feed.typePost == "donation" {
                cardProductContainerStackView.isHidden = true
            } else {
                cardProductContainerStackView.isHidden = feed.post?.product == nil
            }
            
            shortcutStartPaidDMContainerStackView.isHidden = true//feed.account?.id == getUserLoginId()
            postDateLabel.text = Date(timeIntervalSince1970: TimeInterval((feed.createAt ?? 1000)/1000 )).timeAgoDisplay()
            commentCountLabel.text = "\(feed.comments ?? 0)"
            verifiedImageView.isHidden = feed.account?.isVerified == false
            totalLikeLabel.text = "\(feed.likes ?? 0)"
            usernameLabel.text = feed.account?.name ?? "-"
            setupDescription(feed: feed)
            userProfileImageView.loadImage(at: feed.account?.photo ?? "", .w360, emptyImageName: "iconProfileEmpty")
            
            if feed.post?.medias?.first?.type == "image" {
                blurView.isHidden = false
                thumbnailImageView.isHidden = false
                thumbnailImageView.contentMode = .scaleAspectFit
                thumbnailImageView.loadImage(at: feed.post?.medias?.first?.url ?? "", .w720, emptyImageName: "empty")
            } else {
                blurView.isHidden = true
                thumbnailImageView.isHidden = true
            }
            
            setupDonationCard(feed: feed)
            setupProduct(with: feed.post?.product)
        }
    }
    
    private var currentTime: Int = 0
    
    private func getToken()  -> String? {
        let KEY_AUTH_TOKEN = "KEY_AUTH_TOKEN"
        
        if let token = DataCache.instance.readString(forKey: KEY_AUTH_TOKEN) {
            return token
        }

        return nil
    }
    
    private func getUserLoginId()  -> String? {
        let KEY_USER_LOGIN_ID = "USER_LOGIN_ID"
        
        if let token = DataCache.instance.readString(forKey: KEY_USER_LOGIN_ID) {
            return token
        }

        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        
        userProfileImageView.layer.borderWidth = 1
        userProfileImageView.layer.borderColor = UIColor.white.cgColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateProfileFeedCellComments(_:)), name: .handleUpdateProfileFeedCellComments, object: nil)
        
        let onTapLikeGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapLike(_:)))
        likeContainerStackView.isUserInteractionEnabled = true
        likeContainerStackView.addGestureRecognizer(onTapLikeGesture)
        
        let onTapCommentGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapComment(_:)))
        commentContainerStackView.isUserInteractionEnabled = true
        commentContainerStackView.addGestureRecognizer(onTapCommentGesture)
        
        let onTapShareGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapShare(_:)))
        shareContainerStackView.isUserInteractionEnabled = true
        shareContainerStackView.addGestureRecognizer(onTapShareGesture)
        
        let onTapProfileGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapProfile(_:)))
        userProfileImageView.isUserInteractionEnabled = true
        userProfileImageView.addGestureRecognizer(onTapProfileGesture)
        
        let onTapUsernameGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapProfile(_:)))
        usernameLabel.isUserInteractionEnabled = true
        usernameLabel.addGestureRecognizer(onTapUsernameGesture)
        
        let onTapBottomCommentGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapComment(_:)))
        bottomCommentContainerStackView.isUserInteractionEnabled = true
        bottomCommentContainerStackView.addGestureRecognizer(onTapBottomCommentGesture)
        
        let onTapStartPaidDMGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapShortcutStartPaidDM(_:)))
        shortcutStartPaidDMContainerStackView.isUserInteractionEnabled = true
        shortcutStartPaidDMContainerStackView.addGestureRecognizer(onTapStartPaidDMGesture)
        
        let onTapCardDonationGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapCardDonation(_:)))
        cardDonationContainerStackView.isUserInteractionEnabled = true
        cardDonationContainerStackView.addGestureRecognizer(onTapCardDonationGesture)
        
        let onTapCloseCardProductGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapCloseCardProduct(_:)))
        cardProductCloseIconContainerStackView.isUserInteractionEnabled = true
        cardProductCloseIconContainerStackView.addGestureRecognizer(onTapCloseCardProductGesture)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        handleTapPlayPause()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        timer?.fire()
        timer = nil
    }
    
    func commonInit() {
        let nibName = type(of: self).description().components(separatedBy: ".").last ?? ""
        let nib = UINib(nibName: nibName, bundle: Bundle.init(identifier: "com.koanba.kipaskipas.mobile.FeedCleeps"))
        if let view = nib.instantiate(withOwner: self, options: nil).first as? UIView {
            addSubview(view)
            view.frame = bounds
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }
    
    private func handleCloseCardProduct() {
        guard !cardProductContainerStackView.isHidden else { return }
//        cardProductContainerStackView.transform = .identity
        cardProductContainerStackView.alpha = 1
        miniCardProductContainerStackView.isHidden = false
        miniCardProductContainerStackView.alpha = 0
        
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self = self else { return }
//            self.cardProductContainerStackView.transform = .init(translationX: -100, y: 0)
            self.cardProductContainerStackView.alpha = 0
            self.cardProductContainerStackView.isHidden = true
            self.miniCardProductContainerStackView.alpha = 1
        }
    }
    
    private func setupProduct(with product: FeedProduct?) {
        guard !cardProductContainerStackView.isHidden else { return }
        cardProductImageView.loadImage(at: product?.medias?.first?.thumbnail?.small ?? "", .w240)
        cardProductTitleNameLabel.text = product?.name ?? ""
        cardProductPriceLabel.text = product?.price?.toMoney()
        
        miniCardProductTitleNameLabel.text = product?.name ?? ""
        miniCardProductPriceLabel.text = product?.price?.toMoney()
    }
    
    func setupDescription(feed: FeedItem) {
        setupOverlayLayer()
        let isDonation = feed.typePost == "donation"
        let description = isDonation ? feed.post?.title : feed.post?.description
        captionView.text = description ?? ""
        
        captionView.mentionTapHandler = { [weak self] in
            guard self != nil else { return }
            
            let action = ProfileFeedCellTapAction.mention(feed: feed, value: $0)
            NotificationCenter.default.post(name: .handleTapActionOnProfileFeedCell, object: action)
        }
        
        captionView.hashtagTapHandler = { [weak self] in
            guard self != nil else { return }
            
            let action = ProfileFeedCellTapAction.hashtag(feed: feed, value: $0)
            NotificationCenter.default.post(name: .handleTapActionOnProfileFeedCell, object: action)
        }
        
        captionView.toggleExpandHandler = { [weak self] isExpanded in
            guard let self = self else { return }
            
            if isExpanded {
                self.setupOverlayMoreLayer()
            } else {
                self.setupOverlayLayer()
            }
        }
    }
    
    func setupOverlayLayer() {
        let clear = UIColor.clear.cgColor
        let blackLight = UIColor.black.withAlphaComponent(0.2).cgColor
        let blackMiddle = UIColor.black.withAlphaComponent(0.3).cgColor
        let blackDark = UIColor.black.withAlphaComponent(0.4).cgColor
        
        layerLess.colors = [blackLight, clear, clear,clear, clear, clear, clear, clear, blackLight, blackMiddle, blackDark]
        layerLess.startPoint = CGPoint(x: 0.0, y: 0.0)
        layerLess.endPoint = CGPoint(x: 0, y: 1)
        layerLess.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        layerMore.removeFromSuperlayer()
        layerView.backgroundColor = .clear
        layerView.layer.addSublayer(layerLess)
    }
    
    func setupOverlayMoreLayer() {
        let clear = UIColor.clear.cgColor
        let color = UIColor.black.withAlphaComponent(0.45).cgColor

        layerMore.colors = [color, clear, color]
        layerMore.startPoint = CGPoint(x: 1, y: 1)
        layerMore.endPoint = CGPoint(x: 1, y: 1)
        layerMore.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

        layerLess.removeFromSuperlayer()
        layerView.backgroundColor = .clear
        layerView.layer.addSublayer(layerMore)
    }
    
    private func setupDonationCard(feed: FeedItem) {
        
        guard feed.typePost == "donation" else {
            cardDonationContainerStackView.isHidden = true
            return
        }
        
        let isCurrentUser = feed.feedType == .profile
        donationCoverImageHeightConstraint.constant = isCurrentUser ? 38 : 66
        layoutIfNeeded()
        
        cardDonationContainerStackView.isHidden = false
        donationProgressBar.alpha = feed.post?.targetAmount == 0.0 ? 0.0 : 1
        donationNowButton.isHidden = isCurrentUser
        donationCoverImageView.loadImage(at: feed.post?.medias?.first?.thumbnail?.small ?? "", .w240, emptyImageName: "empty")
        
        var amountCollectedPercent: Float {
            return Float(Double(feed.post?.amountCollected ?? 0.0) / Double(feed.post?.targetAmount ?? 0.0))
        }
        
        donationProgressBar.progress = amountCollectedPercent
        
        let amountCollected = feed.post?.amountCollected?.toMoney() ?? "Rp 0"
        let amountCollectedAttribute = amountCollected.attributedText(font: .Roboto(.bold, size: 15), textColor: .primary)

        if let targetAmount = feed.post?.targetAmount, targetAmount != 0.0 {
            let targetAmountAttribute = " / \(targetAmount.toMoney())".attributedText(font: .Roboto(.bold, size: 10), textColor: .contentGrey)
            amountCollectedAttribute.append(targetAmountAttribute)
        }

        donationAmountLabel.attributedText = amountCollectedAttribute
    }
    
    @objc func handleUpdateProfileFeedCellComments(_ notification: Notification) {
        
        guard let feed = notification.object as? FeedItem else {
            return
        }
        
        guard self.feed.feedType == feed.feedType && self.feed.id ?? "" == feed.id ?? "" else { return }
        print("azmiiiiiiii", "handleUpdateProfileFeedCellComments", feed.post?.description, feed.feedType)
        commentCountLabel.text = "\(feed.comments ?? 0)"
        self.feed.comments = feed.comments
        NotificationCenter.default.post(
            name: Notification.Name("handleUpdateHotNewsCellCommentsFromProfileFeed"), 
            object: nil,
            userInfo: [
                "accountId": self.feed.account?.id ?? "",
                "comments": self.feed.comments ?? 0
            ]
        )
    }
    
    @objc private func handleTapLike(_ tapGesture: UITapGestureRecognizer) {
        
        if getToken() != nil {
            feed.likes = feed.isLike == true ? (feed.likes ?? 0) - 1 : (feed.likes ?? 0) + 1
            feed.isLike?.toggle()
            
            if let feedId = feed.id {
                KKFeedLike.instance.add(feedId: feedId, isLike: feed.isLike ?? false, countLike: feed.likes ?? 0)
            }
            
            model = feed
            
            NotificationCenter.default.post(
                name: Notification.Name("handleUpdateHotNewsCellLikesFromProfileFeed"),
                object: nil,
                userInfo: [
                    "accountId": feed.account?.id ?? "",
                    "likes": feed.likes ?? 0,
                    "isLike": feed.isLike ?? false
                ]
            )
            
            let action = ProfileFeedCellTapAction.like(feed: feed)
            NotificationCenter.default.post(name: .handleTapActionOnProfileFeedCell, object: action)
        }

    }
    
    @objc private func handleTapComment(_ tapGesture: UITapGestureRecognizer) {
        let action = ProfileFeedCellTapAction.comment(feed: feed)
        NotificationCenter.default.post(name: .handleTapActionOnProfileFeedCell, object: action)
    }
    
    @objc private func handleTapShare(_ tapGesture: UITapGestureRecognizer) {
        let action = ProfileFeedCellTapAction.share(feed: feed)
        NotificationCenter.default.post(name: .handleTapActionOnProfileFeedCell, object: action)
    }
    
    @objc private func handleTapProfile(_ tapGesture: UITapGestureRecognizer) {
        let action = ProfileFeedCellTapAction.profile(feed: feed)
        NotificationCenter.default.post(name: .handleTapActionOnProfileFeedCell, object: action)
    }
    
    @objc private func handleTapPlayPause() {
        
        guard feed.videoUrl.hasSuffix(".mp4") || feed.videoUrl.hasSuffix(".m3u8") else {
            return
        }
        
        isPlay.toggle()
        let action = ProfileFeedCellTapAction.playPause(feed: feed, isPlay: isPlay)
        NotificationCenter.default.post(name: .handleTapActionOnProfileFeedCell, object: action)
    }
    
    @objc private func handleTapShortcutStartPaidDM(_ tapGesture: UITapGestureRecognizer) {
        let action = ProfileFeedCellTapAction.shortcutStartPaidDM(feed: feed)
        NotificationCenter.default.post(name: .handleTapActionOnProfileFeedCell, object: action)
    }
    
    @objc private func handleTapCardDonation(_ tapGesture: UITapGestureRecognizer) {
        let action = ProfileFeedCellTapAction.donationDetail(feed: feed)
        NotificationCenter.default.post(name: .handleTapActionOnProfileFeedCell, object: action)
    }
    
    @objc func handleTapCloseCardProduct(_ tapGesture: UITapGestureRecognizer) {
        handleCloseCardProduct()
    }
    
    @IBAction func didClickDonationNowButton(_ sender: Any) {
        let action = ProfileFeedCellTapAction.donationDetail(feed: feed)
        NotificationCenter.default.post(name: .handleTapActionOnProfileFeedCell, object: action)
    }
}

extension ProfileFeedViewCell: TUIPlayerShortVideoControl {
    func reloadData() {
        
    }
    
    var model: TUIPlayerVideoModel {
        get {
            return self.feed
        }
        set {
            var item = FeedItem()
            
            if let feed = newValue as? FeedItem {
                if let feedId = feed.id {
                    if let feedExist =  KKFeedLike.instance.isExist(feedId: feedId) {
                        feed.likes = feedExist.countLike
                        feed.isLike = feedExist.isLike
                    }
                }
                
                item = feed
                item.coverPictureUrl = newValue.coverPictureUrl
                item.videoUrl = newValue.videoUrl
                item.duration = newValue.duration
            }
            
            self.feed = item
        }
    }
    
    var currentPlayerStatus: TUITXVodPlayerStatus {
        get {
            return self.currentPlayerStatus
        }
        set(currentPlayerStatus) {
//            self.currentPlayerStatus = currentPlayerStatus
        }
    }
    
    
    func showCenterView() {
//        print("a")
    }
    
    func hideCenterView() {
//        print("--- b")
    }
    
    func showLoadingView() {
//        print("--- c")
    }
    
    func hiddenLoadingView() {
//        print("--- d")
    }
    
    func setDurationTime(_ time: Float) {
//        print("--- e")
    }
    
    func setCurrentTime(_ time: Float) {
        print("kwkwkwkwkw", Int(time))
        if Int(time) == 0 && cardProductContainerStackView.isHidden == false {
            cardProductContainerStackView.alpha = 1
        }
        
        if Int(time) >= 2 {
            cardProductContainerStackView.alpha = 1
            handleCloseCardProduct()
        }
    }
    
    func setProgress(_ progress: Float) {
        // PE-11985, prevent flicker progress from 0.0 then suddenly 1.0 when play
        if(progress < 1.0){
            videoProgressBar.setProgress(progress, animated: false)
        }
        isPlay = true
    }
    
    func showSlider() {}
    
    func hideSlider() {}
    
    private func convertTime(_ time: Float) -> String {

        /// 错误时间戳设置
        if time <= 0 {
            return "00:00"
        }
        /// 返回正常时间戳设置
        return String(format: "%02d:%02d", Int(time) / 60, Int(time) % 60)
    }
}
