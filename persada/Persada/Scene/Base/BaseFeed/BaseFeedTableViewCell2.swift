//
//  BaseFeedTableViewCell2.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 07/01/21.
//  Copyright © 2021 Muhammad Noor. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation
import ModernAVPlayer
import FirebaseAnalytics

protocol CellDelegate: AnyObject {
    func zooming(started: Bool)
}

class BaseFeedTableViewCell2: UITableViewCell {
    
    weak var delegateZoom: CellDelegate?
//    let video = AGVideoPlayerView()
    
    
    let player: ModernAVPlayer = {
        let config = PlayerConfigurationEx()
        return ModernAVPlayer(config: config, loggerDomains: [.error, .unavailableCommand])
    }()
    
//    @IBOutlet var layerVideoView: AVPlayerView!

    
    let image = UIImageView(frame: .zero)

    @IBOutlet weak var recomLabel: UILabel!
    @IBOutlet weak var recomStackView: UIStackView!
    @IBOutlet var labelTime: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var postTimeLabel: UILabel!
    @IBOutlet var usernameImageView: UIImageView!
    
    @IBOutlet weak var videoPlayerView: AVPlayerView!
//    @IBOutlet weak var videoPlayerView: AVPlayerView!
    
    @IBOutlet var thumbnailImageView: UIImageView!
    
    @IBOutlet var mediaView: UIView!
    
    
    @IBOutlet var mediaHeightConstraints: NSLayoutConstraint!
    @IBOutlet var descLabel: ActiveLabel!
    @IBOutlet var timeView: UIView!
    @IBOutlet var likeImageView: UIImageView!
    @IBOutlet var likeCounterLabel: UILabel!
    @IBOutlet var commentCounterLabel: UILabel!
    @IBOutlet var shareImageView: UIImageView!
    @IBOutlet var kebabImageView: UIImageView!
    @IBOutlet var profileStackView: UIStackView!
    @IBOutlet var commentStackView: UIStackView!
    @IBOutlet var likeStackView: UIStackView!
    @IBOutlet var pauseImageView: UIImageView!
    @IBOutlet weak var iconVerified: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var waImageView: UIImageView!
    @IBOutlet weak var shopButton: UIButton!
    @IBOutlet weak var wikipediaLabel: UILabel! {
        didSet {
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(named: AssetEnum.wikipedia.rawValue.uppercased())
            imageAttachment.bounds = CGRect(x: 0, y: -1, width: imageAttachment.image!.size.width * 1.1, height: imageAttachment.image!.size.height * 1.1)
            
            let wikiImage = NSAttributedString(attachment: imageAttachment)
            let onText = NSAttributedString(string: "on ")
            
            let completeText = NSMutableAttributedString(string: "")
            completeText.append(onText)
            completeText.append(wikiImage)
            self.wikipediaLabel.textAlignment = .center
            self.wikipediaLabel.attributedText = completeText
        }
    }
    
    @IBOutlet weak var buttonSeeProduct: UIButton!
    @IBOutlet weak var viewSeeProduct: UIView!
    @IBOutlet weak var postTimeToCaptionConstraint: NSLayoutConstraint!
    @IBOutlet weak var postTimeToButtonConstraint: NSLayoutConstraint!
    // the view that will be overlayed, giving a back transparent look
    var overlayView: UIView!
    var windowImageView: UIView?
    var initialCenter: CGPoint?
    var startingRect = CGRect.zero
    
    // a property representing the maximum alpha value of the background
    let maxOverlayAlpha: CGFloat = 0.8
    // a property representing the minimum alpha value of the background
    let minOverlayAlpha: CGFloat = 0.4
    
    var temporaryImage: UIImageView?
    
    var seeProductHandler: (() -> Void)?
    
    func statusDidChange(status: Int) {
        //todo: should be enum
        if status == 0 {
            showLoading()
        } else {
            hideLoading()
        }
    }
    
    func setInitialVideoTime (_ time: String) {
        if timeView.isHidden {
            timeView.isHidden = false
        }
        labelTime.text = time
    }
    
    var isZooming = false
    var originalImageCenter:CGPoint?
        
    var videoURL: String? = ""
    
    
    var updateFeed: ((_ feed: Feed) -> Void)?
    var profileHandler: ((_ id: String, _ type: String) -> Void)?
    var reportHandler: ((_ id: String, _ accountId: String, _ imageUrl: String) -> Void)?
    var kebabAsUserHandler: ((_ id: String) -> Void)?
    var followHandler: ((_ id: String) -> Void)?
    var sharedHandler: (() -> Void)?
    var mentionHandler: ((_ text: String) -> Void)?
    var hashtagHandler: ((_ text: String) -> Void)?
    var handler: ((Int) -> Void)?
    var commentHandler: ((_ item: Feed) -> Void)?
    var likeHandler: ((_ item: Feed) -> Void)?
    var wikipediaHandler: ((_ url: String) -> Void)?
    var shopHandler: ((_ id: String) -> Void)?
    var dmHandler: ((_ account: Profile) -> Void)?
    
    let suffixText = " See More"
    var prefixText = ""
    
    var isExpanded: Bool = false
    
    lazy var loadingView: UIView = {
        //TODO: LOADING STATE MASIH BLM BENER JADI DIMATIIN DULU, KALAU ADA YANG MAU COBA2 SILAHKAN
        let view = UIView()
        //        view.isHidden = true
        //        view.layer.cornerRadius = 8
        //        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        //        var loadingView = RPLoadingAnimationView(
        //            frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 50)),
        //            type: RPLoadingAnimationType.spininngDot,
        //            colors:  [UIColor.red,  .blue,  .orange, .purple],
        //            size:  CGSize(width: 150, height: 150)
        //        )
        //        view.addSubview(loadingView)
        //        loadingView.anchor(width: 50, height: 50)
        //        loadingView.centerVertically()
        //        loadingView.centerHorizontally()
        
        //        loadingView.setupAnimation()
        return view
    }()
    
    
    var row: Int = 0
    var descText: String = ""
    var feed: Feed? = nil
    var watchTime: Double = 0.0
    var tempWatchTime: Double = 0.0
    var videoDuration: Int = 0
    var timer: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        player.delegate = self
        
//        self.thumbnailImageView.isUserInteractionEnabled = true
//        self.thumbnailImageView.addGestureRecognizer(
//            UITapGestureRecognizer(target: self, action: #selector(self.didTap)
//            )
//        )
        self.videoPlayerView.isUserInteractionEnabled = true
        self.videoPlayerView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(self.didTap)
            )
        )

        
        
        addMovementGesturesToView(mediaView)
        
        //        viewSeeProduct.roundBottom(radius: 5)
        viewSeeProduct.layoutIfNeeded()

        
        self.profileStackView.isUserInteractionEnabled = true
        self.profileStackView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(self.handleWhenTappedProfile)
            )
        )
        
        self.likeStackView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self, action: #selector(self.whenHandleTappedLike)
            )
        )
        
        self.commentStackView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self, action: #selector(self.whenHandleTappedComment)
            )
        )
        
        self.shareImageView.isUserInteractionEnabled = true
        self.shareImageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(self.whenHandleTappedShared)
            )
        )
        
        self.kebabImageView.isUserInteractionEnabled = true
        self.kebabImageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action:
                                    #selector(self.whenHandleTappedReport))
        )
        
        
        self.mediaView.addSubview(loadingView)
//        self.mediaView.addSubview(layerView)
        
        
        //TODO: LOADING STATE MASIH BLM BENER JADI DIMATIIN DULU, KALAU ADA YANG MAU COBA2 SILAHKAN
        //        loadingView.anchor(top: mediaView.topAnchor, left: mediaView.leftAnchor, bottom: mediaView.bottomAnchor, right: mediaView.rightAnchor)
//        delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
        
        iconVerified.layer.cornerRadius = iconVerified.frame.width / 2
        iconVerified.layer.borderWidth = 1
        iconVerified.layer.borderColor = UIColor.white.cgColor
    }
    
    override func prepareForReuse() {
        isExpanded = false
        videoURL = nil
        timeView.isHidden = true
        descLabel.attributedText = nil
    }
    
    func setupRecomendation(feed: Feed) {
        enum TypeBase: String { case item, user }
        
        guard let value = feed.valueBased, let type = feed.typeBased, let similarBy = feed.similarBy else {
            recomStackView.isHidden = true
            return
        }
        
        let typeBase: TypeBase = type == "item" ? .item : .user
        recomStackView.isHidden = false
        
        #if DEBUG
        recomLabel.attributedText = makeRecomendationText(
            title: "Rekomendasi karena kamu \(typeBase == .item ? "menyukai " : "sama dengan ")",
            value: typeBase == .item ? value : "@\(value)"
        )
        #elseif STAGING
        recomLabel.attributedText = makeRecomendationText(
            title: "Rekomendasi karena kamu \(typeBase == .item ? "menyukai " : "sama dengan ")",
            value: typeBase == .item ? value : "@\(value)"
        )
        #else
        recomLabel.attributedText = makeRecomendationText(
            title: "Rekomendasi \(typeBase == .item ? "karena kamu menyukai " : "buat kamu ")",
            value: typeBase == .item ? value : ""
        )
        #endif
        
        if typeBase == .user && similarBy == "duration" {
            recomLabel.attributedText = makeRecomendationText(
                title: "Rekomendasi karena kamu tertarik dengan postingan ",
                value: "@\(value)"
            )
        }
    }
    
    private func makeRecomendationText(title: String, value: String) -> NSMutableAttributedString {
        let myString = NSMutableAttributedString(string: title)
        let myAttribute = [NSAttributedString.Key.font: UIFont.Roboto(.bold, size: 10)]
        myString.append(NSMutableAttributedString(string: value, attributes: myAttribute))
        return myString
    }
    
    
    func setup(feed: Feed, expanded: Bool, height: CGFloat) {
        self.feed = feed
        setupRecomendation(feed: feed)
        descText = feed.post?.postDescription ?? ""
        if feed.post?.postDescription == "-" {
            descText = ""
        }
        while descText.last == "\n" {
            descText.removeLast()
        }
        let isCaptionEmpty = descText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        postTimeToCaptionConstraint.isActive = !isCaptionEmpty
        postTimeToButtonConstraint.isActive = isCaptionEmpty
        
        let photo = feed.account?.photo ?? ""
        
        if URL(string: photo) != nil {
            usernameImageView.loadImage(at: photo, low: photo, .w240,.w140)

        } else {
            usernameImageView.image = UIImage(named: .get(.empty))
        }
        
        prefixText = feed.account?.username ?? ""
        
        let hideVerifiedAccount = feed.account?.isVerified ?? false == false
        iconVerified.isHidden = hideVerifiedAccount
        likeImageView.image = feed.isLike ?? false ? #imageLiteral(resourceName: "iconHeart") : #imageLiteral(resourceName: "iconLike")
        likeCounterLabel.text = "\(feed.likes ?? 0)"
        commentCounterLabel.text = "\(feed.comments ?? 0)"
//        var usernameLabelText =  String(row) + "  -  " + (feed.account?.username)!
        usernameLabel.text = feed.account?.username ?? ""
        
        postTimeLabel.text = TimeFormatHelper.soMuchTimeAgoNew(date: feed.createAt ?? 0)
        priceLabel.text = feed.post?.product?.price?.toMoney()

        
        if !expanded { isExpanded = descText.count < 100 }
        
        descLabel.isHidden = descText.isEmpty == true ? true : false
        descLabel.setLabel(prefixText: prefixText, expanded: expanded, mainText: descText, 100) { [weak self] in
            guard let self = self else { return }
            self.handleWhenTappedProfile()
        } suffixTap: {
            if !self.isExpanded {
                self.taplabel()
            }
        } mentionTap: { [weak self] (String) in
            guard let self = self else { return }
            self.handleWhenTappedMention(String, type: wordType.mention)
        } hashtagTap: { [weak self] (String) in
            guard let self = self else { return }
            self.handleWhenTappedMention(String, type: wordType.hashtag)
        }
        
        guard let medias = feed.post?.medias else {return}
        
        guard !medias.isEmpty else {
            setupSingle(media: Medias.toMedias())
            return
        }
        
        
        
        setupSingle(media: medias.first!)
        
        updateHeightConstraint(height)

        
        if feed.post?.product != nil {
            viewSeeProduct.isHidden = false
            mediaView.bringSubviewToFront(viewSeeProduct)
        } else {
            viewSeeProduct.isHidden = true
        }
        
        self.wikipediaLabel.isHidden = !isWikipediaExist(feed: feed)
        self.wikipediaLabel.isUserInteractionEnabled = true
        self.wikipediaLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.whenHandleTappedWikipedia)))
        
        
        self.shopButton.isHidden = (!(feed.isProductActiveExist ?? false) || feed.account?.id == getIdUser())
        self.shopButton.layer.cornerRadius = 12
        self.shopButton.addTarget(self, action: #selector(self.whenHandleTappedShop), for: .touchUpInside)
        
        self.waImageView.isHidden = feed.account?.id == getIdUser()
        self.waImageView.isUserInteractionEnabled = true
        self.waImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.whenHandleTappedDM)))
        
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        sendAnalyticsToFirebase()
    }
    
    @objc func timerAction() {
        watchTime += 1
        print("@@@ DEBUG:--- watch time single image \(watchTime)")
    }
    
    func startTimer() {
        watchTime = 0
        if feed?.mediaCategory ?? "" == "SINGLE_IMAGE" {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        }
        
    }
    
    func sendAnalyticsToFirebase() {
        guard AUTH.isLogin() else { return }
        guard Int(watchTime) != 0 else { return }
        
        let evenName        = "kipas_\(feed?.id ?? "")"
        let viewDuration    = "\(Int(watchTime))"
        let viewDate        = "\(Date().millisecondsSince1970)"
        let createAt        = "\(feed?.createAt ?? 0)"
        let typePost        = "\(feed?.typePost ?? "")"
        let uid             = getIdUser()
        let feedId          = feed?.id ?? ""
        let viewType        = feed?.mediaCategory ?? ""
        let totalDuration   = viewType == "SINGLE_IMAGE" ? "0" : "\(videoDuration)"
        let hashtags        = feed?.post?.hashtags?.map({ "#\($0.value ?? "")" }).joined(separator: " ") ?? ""
        
        let logParam = [
            "user_id"       : uid,          "feed_id"       : feedId,
            "view_duration" : viewDuration, "total_duration": totalDuration,
            "view_date"     : viewDate,     "view_type"     : viewType,
            "type_post"     : typePost,     "hashtag"       : hashtags,
            "create_at"     : createAt,     "channel_code"  : "home",
            "platform"      : "ios"
        ]
        
        Analytics.logEvent(evenName, parameters: logParam)
        
        watchTime = 0
    }
    
    func isWikipediaExist(feed: Feed?) -> Bool {
        if let socialMedias = feed?.account?.socialMedias {
            for socialMedia in socialMedias {
                if socialMedia.socialMediaType == SocialMediaType.wikipedia.rawValue {
                    if !(socialMedia.urlSocialMedia?.isEmpty ?? true) {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    var isAlreadyHasvideo = false
    func setupSingle(media: Medias){
        
        let width = Double(media.metadata?.width ?? "550") ?? 550
        let height =  Double(media.metadata?.height ?? "550") ?? 550
        if width > height || width == height  {
            self.image.contentMode = .scaleAspectFit
            guard let videoLayer = self.videoPlayerView.layer as? AVPlayerLayer else { return }
            videoLayer.videoGravity = .resizeAspect

        } else {
            self.image.contentMode = .scaleAspectFill
            guard let videoLayer = self.videoPlayerView.layer as? AVPlayerLayer else { return }
            videoLayer.videoGravity = .resizeAspectFill
        }
        
        
        mediaView.addSubview(image)
        image.clipsToBounds = true
        image.fillSuperview()
        
        image.loadImage(at: media.thumbnail?.large ?? "", low: media.thumbnail?.medium ?? "", .w1280, .w576)

            if media.type == "video" {
                
                
                videoPlayerView.isHidden = false
                videoPlayerView.isUserInteractionEnabled = true

                if let _ = media.isHlsReady {
                    guard let hlsUrl = media.hlsUrl else { return }
                    self.videoURL = URL(string: hlsUrl)?.absoluteString
                } else {
                    self.videoURL = URL(string: media.url ?? "")?.absoluteString
                }
                
                guard let url = self.videoURL else { return }
                let asset = AVAsset(url: URL(string: url)!)
                let avPlayerItem = AVPlayerItem(asset: asset)
                avPlayerItem.preferredForwardBufferDuration = 3
                guard let item = ModernAVPlayerMediaItem(item: avPlayerItem, type: .clip, metadata: nil) else { return }
                player.load(media: item, autostart: false)
                player.loopMode = true
                
                guard let videoLayer = videoPlayerView.layer as? AVPlayerLayer else { return }

                videoLayer.videoGravity = .resizeAspectFill
                
                if let playerLayer = videoLayer.player {
                    playerLayer.replaceCurrentItem(with: player.player.currentItem)
                } else {
                    videoLayer.player = player.player
                }
                mediaView.bringSubviewToFront(videoPlayerView)
                mediaView.bringSubviewToFront(timeView)
                mediaView.bringSubviewToFront(pauseImageView)
                mediaView.bringSubviewToFront(labelTime)
                
                isAlreadyHasvideo = true
                
                timeView.isHidden = false
                
                
            } else {
                self.videoURL = ""
                
                videoPlayerView.isHidden = true
                videoPlayerView.isUserInteractionEnabled = false
                timeView.isHidden = true
                pauseImageView.isHidden = true
            }
        }

    
    @IBAction func seeProductAction(_ sender: UIButton) {
        self.seeProductHandler?()
    }
    
    
    func updateHeightConstraint(_ height: CGFloat) {
        
                
        let width: CGFloat = UIScreen.main.bounds.width
        
        // rony - if ratio more than 1,7 (vertical video) then resize height to 70%
        // ex : width = 300, height = 500, then ratio = 1,66
        let ratio:CGFloat = height / width
        
        if(ratio > 1.7){
            let shrinkPercetange:CGFloat = 0.7
            
            // need to "round" height, because somehow video wont play if height is fraction (eg: 340.33 or 480.555)
            let heightShrink:CGFloat = ceil( height * shrinkPercetange )
            
            mediaHeightConstraints.constant = heightShrink
            videoPlayerView.frame = CGRect(x: 0, y: 0, width: width, height: heightShrink)
            
        } else {
            mediaHeightConstraints.constant = height
            videoPlayerView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        }
                
        

    }
    
    func playVideo() -> Bool {
        if(hasVideo()){
            if (self.player.player.rate == 0) {
                if tempWatchTime != 0.0 {
                      self.player.seek(position: tempWatchTime)
                }
                self.player.play()
                
                print("KE PLAY YA X")
                return true
            }
        }
        return false
    }
    
    func hasVideo() -> Bool {
        if(self.videoURL == nil || self.videoURL == ""){
            return false
        }
        return true
    }
    
    func stopVideo() {
        if(hasVideo()){
            if (self.player.player.rate != 0) {
                self.player.pause()
                self.sendAnalyticsToFirebase()
            }
        }
    }
    
    
    func taplabel() {
        descLabel.text = prefixText + " " + descText
        descLabel.setLabel(prefixText: prefixText, expanded: true, mainText: descText, 10000) {
            self.handleWhenTappedProfile()
        } suffixTap: { [weak self] in
            guard let self = self else { return }
            if !self.isExpanded {
                self.taplabel()
            }
        } mentionTap: { [weak self] (String) in
            guard let self = self else { return }
            self.handleWhenTappedMention(String, type: wordType.mention)
        } hashtagTap: { [weak self] (String) in
            guard let self = self else { return }
            self.handleWhenTappedMention(String, type: wordType.hashtag)
        }
        handler?(row)
        isExpanded = true
    }
    
    @objc func didTap() {
        
        if self.player.player.rate == 0 {
//            playerController?.paused = false
//            videoPlayerView.player?.play()
            self.player.play()
            pauseImageView.isHidden = true
        } else {
//            playerController?.paused = true
            pauseImageView.isHidden = false
//            videoPlayerView.player?.pause()
            self.player.pause()
        }
    }
    
    @objc func handleTap(onLabel tapGesture: UITapGestureRecognizer) {
        if (!isExpanded) {
            taplabel()
        }
    }
    
    @objc func handleWhenTappedProfile() {
        self.profileHandler?(self.feed?.account?.id ?? "", self.feed?.typePost ?? "")
    }
    
    func handleWhenTappedMention(_ value: String, type: wordType) {
        if type == .mention {
            self.mentionHandler?(value)
        } else {
            self.hashtagHandler?(value)
        }
    }
    
    @objc func whenHandleTappedLike() {
        if AUTH.isLogin(){
            let isLike = self.feed?.isLike ?? false
            let likeCounter = self.feed?.likes  ?? 0
            self.feed?.isLike = !isLike
            self.feed?.likes = likeCounter + (!isLike ? 1 : -1)
            configureStatusLike(status: !isLike)
            likeCounterLabel.text = "\(likeCounter + (!isLike ? 1 : -1))"
            if let feed = self.feed {
                self.updateFeed?(feed)
            }
        } else {
            guard let item = self.feed else {
                return
            }
            
            self.likeHandler?(item)
        }
    }
    
    @objc func whenHandleTappedWikipedia() {
        if let socialMedias = self.feed?.account?.socialMedias {
            for socialMedia in socialMedias {
                if socialMedia.socialMediaType == SocialMediaType.wikipedia.rawValue {
                    self.wikipediaHandler?(socialMedia.urlSocialMedia ?? "")
                }
            }
        }
    }
    
    @objc func whenHandleTappedShop() {
        self.shopHandler?(feed?.account?.id ?? "")
    }
    
    @objc func whenHandleTappedDM() {
        guard let account = feed?.account else {
            return
        }
        self.dmHandler?(account)
    }
    
    func configureStatusLike(status: Bool) {
        if status {
            self.likeImageView.image = UIImage(named: String.get(.iconHeart))
        } else {
            self.likeImageView.image = UIImage(named: String.get(.iconLike))
        }
    }
    
    @objc func whenHandleTappedShared() {
        self.sharedHandler?()
    }
    
    @objc func whenHandleTappedReport() {
        self.reportHandler?(self.feed?.id ?? "", self.feed?.account?.id ?? "" ,self.feed?.post?.medias?.first?.thumbnail?.medium ?? "")
    }
    
    @objc func whenHandleTappedComment() {
        guard let item = self.feed else {
            return
        }
        
        self.commentHandler?(item)
    }
    
    func showLoading() {
        loadingView.isHidden = false
        
    }
    
    func hideLoading() {
        loadingView.isHidden = true
    }
    
//    func didEndDisplaying() {
//        self.player.pause()
//        guard let videoLayer = layerView.layer as? AVPlayerLayer else { return }
//        if let playerLayer = videoLayer.player {
//            playerLayer.replaceCurrentItem(with: player.player.currentItem)
//        } else {
//            videoLayer.player = player.player
//        }
//    }

}


extension Date {
    
    func getElapsedInterval() -> String {
        
        let interval = Calendar.current.dateComponents([.year, .month, .day], from: self, to: Date())
        
        if let year = interval.year, year > 0 {
            return year == 1 ? "\(year)" + " " + "year ago" :
                "\(year)" + " " + "years ago"
        } else if let month = interval.month, month > 0 {
            return month == 1 ? "\(month)" + " " + "month ago" :
                "\(month)" + " " + "months ago"
        } else if let day = interval.day, day > 0 {
            return day == 1 ? "\(day)" + " " + "day ago" :
                "\(day)" + " " + "days ago"
        } else {
            return "a moment ago"
            
        }
        
    }
}

extension BaseFeedTableViewCell2 {
    
    func addMovementGesturesToView(_ view: UIView) {
        view.isUserInteractionEnabled = true
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        pinchGesture.delegate = self
        view.addGestureRecognizer(pinchGesture)
    }
    
    @objc private func handlePinchGesture(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .began {
            let currentScale = self.mediaView.frame.size.width / self.mediaView.bounds.size.width
            let newScale = currentScale * sender.scale
            
            if newScale > 1 {
                isZooming = true
                guard let currentWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {return}
                
                print("media view frame = \(mediaView.frame) \(mediaView.bounds)")
                self.delegateZoom?.zooming(started: true)
                
                overlayView = UIView.init(
                    frame: CGRect(
                        x: 0,
                        y: 0,
                        width: (currentWindow.frame.size.width),
                        height: (currentWindow.frame.size.height)
                    )
                )
                
                overlayView.backgroundColor = UIColor.black
                overlayView.alpha = CGFloat(minOverlayAlpha)
                currentWindow.addSubview(overlayView)
                
                initialCenter = sender.location(in: currentWindow)
                print("INITIAL CENTER \(String(describing: initialCenter))")
                
                guard let medias = self.feed?.post?.medias else {return}
                if medias.first?.type == "video" {
                    let viewVideo = UIView(frame: mediaView.frame)
                    
                    guard let videoLayer = videoPlayerView.layer as? AVPlayerLayer else { return }

                    viewVideo.layer.addSublayer(videoLayer)
                    windowImageView = viewVideo
                } else {
                    windowImageView = UIImageView.init(image: self.image.image)
                }
                print(mediaView.frame)
                
                windowImageView!.contentMode = .scaleAspectFill
                windowImageView!.clipsToBounds = true
                
                let point = self.mediaView.convert(
                    mediaView.frame.origin,
                    to: nil
                )
                
                print("point: \(point)")
                
                startingRect = CGRect(
                    x: point.x,
                    y: point.y,
                    width: mediaView.frame.size.width,
                    height: mediaView.frame.size.height
                )
                
                print("startingRect" + "\(startingRect)")
                windowImageView?.frame = startingRect
                currentWindow.addSubview(windowImageView!)
                currentWindow.bringSubviewToFront(overlayView)
                currentWindow.bringSubviewToFront(windowImageView!)
                mediaView.isHidden = true
            }
        } else if sender.state == .changed {
            guard let currentWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
                  let initialCenter = initialCenter,
                  let windowImageWidth = windowImageView?.frame.size.width
            else { return }
            
            let currentScale = windowImageWidth / startingRect.size.width
            let newScale = currentScale * sender.scale
            overlayView.alpha = minOverlayAlpha + (newScale - 1) < maxOverlayAlpha ? minOverlayAlpha + (newScale - 1) : maxOverlayAlpha
            
            let pinchCenter = CGPoint(
                x: sender.location(in: currentWindow).x - (currentWindow.bounds.midX),
                y: sender.location(in: currentWindow).y - (currentWindow.bounds.midY)
            )
            
            let centerXDif = initialCenter.x - sender.location(in: currentWindow).x
            let centerYDif = initialCenter.y - sender.location(in: currentWindow).y
            let zoomScale = (newScale * windowImageWidth >= mediaView.frame.width) ? newScale : currentScale
            
            let transform = currentWindow.transform
                .translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                .scaledBy(x: zoomScale, y: zoomScale)
                .translatedBy(x: -centerXDif, y: -centerYDif)
            
            windowImageView?.transform = transform
            
            sender.scale = 1
        } else if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
            guard let windowImageView = self.windowImageView else { return }
            
            UIView.animate(withDuration: 0.3, animations: {
                windowImageView.transform = CGAffineTransform.identity
                self.mediaView?.transform = CGAffineTransform.identity
                
            }, completion: { [weak self] _ in
                guard let self = self else { return }
                guard let medias = self.feed?.post?.medias else {return}
                self.mediaView.isHidden = false
                if medias.first?.type == "video" {
                    guard let videoLayer = self.videoPlayerView.layer as? AVPlayerLayer else { return }
                    self.mediaView.layer.addSublayer(videoLayer)
                    self.mediaView.layer.addSublayer(self.timeView.layer)
                    self.timeView.layer.addSublayer(self.pauseImageView.layer)
                    self.timeView.layer.addSublayer(self.labelTime.layer)
                }
                windowImageView.removeFromSuperview()
                self.overlayView.removeFromSuperview()
                self.delegateZoom?.zooming(started: false)
                self.isZooming = false
            })
        }
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension BaseFeedTableViewCell2 : AGVideoPlayerViewDelegate {
    func videoPlaying() {
        pauseImageView.isHidden = true
    }

    func videoPause() {
        pauseImageView.isHidden = false
    }

    func timeChange(_ time: String) {
        if !timeView.isHidden {
            labelTime.text = time
        }
    }
}

private func getFormattedVideoTime(totalVideoDuration: Int) -> (hour: Int, minute: Int, seconds: Int){
    let seconds = totalVideoDuration % 60
    let minutes = (totalVideoDuration / 60) % 60
    let hours   = totalVideoDuration / 3600
    return (hours,minutes,seconds)
}

extension BaseFeedTableViewCell2 : ModernAVPlayerDelegate {
    func modernAVPlayer(_ player: ModernAVPlayer, didStateChange state: ModernAVPlayer.State) {
    }
    
    func modernAVPlayer(_ player: ModernAVPlayer, didCurrentTimeChange currentTime: Double) {
        let floatDuration = Float(CMTimeGetSeconds(player.player.currentItem?.duration ?? .zero))
        
        if(floatDuration > 0){
            let videoDuration = Int(floatDuration)
            let remainingDuration = videoDuration - Int(currentTime)
            let timeInMinutesSecond = getFormattedVideoTime(totalVideoDuration: remainingDuration)
           
            let time = String(format: "%2d:%02d", timeInMinutesSecond.1, timeInMinutesSecond.2)

            labelTime.text = time
            self.videoDuration = videoDuration
            
            if Int(currentTime) > Int(tempWatchTime) {
                tempWatchTime = currentTime
                
                if Int(tempWatchTime) == videoDuration {
                    tempWatchTime = 0
                    return
                }
                watchTime += 1
                printIfDebug("video Durasi: \(videoDuration), Berjalan \(currentTime) total di tonton \(watchTime)")
            }
        }
    }
}
