//
//  BaseFeedMultipleTableViewCell.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 26/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import FirebaseAnalytics

protocol MultipleFeedCell: AnyObject {
    func updateIndex(index: Int)
}

class BaseFeedMultipleTableViewCell: UITableViewCell {
    
    var delegateZoom: CellDelegate?
    var delegate: MultipleFeedCell?
    var feed: Feed?
    let suffixText = " See More"
    var prefixText = ""
    var row: Int = 0
    var descText: String = ""
    var isZooming = false
    var originalImageCenter:CGPoint?
    var indexScroll: Int? = nil
    var height: CGFloat?
    
    var isExpanded: Bool = false
    
    var updateFeed: ((_ feed: Feed) -> Void)?
    var profileHandler: ((_ id: String, _ type: String) -> Void)?
    var reportHandler: ((_ id: String, _ accountId: String, _ imageUrl: String) -> Void)?
    var followHandler: ((_ id: String) -> Void)?
    var sharedHandler: (() -> Void)?
    var mentionHandler: ((_ text: String) -> Void)?
    var hashtagHandler: ((_ text: String) -> Void)?
    var handler: ((Int) -> Void)?
    var commentHandler: ((_ item: Feed) -> Void)?
    var likeHandler: ((_ item: Feed) -> Void)?
    var seeProductHandler: (() -> Void)?
    var wikipediaHandler: ((_ url: String) -> Void)?
    var shopHandler: ((_ id: String) -> Void)?
    var dmHandler: ((_ account: Profile) -> Void)?
    
    var overlayView: UIView!
    var windowImageView: UIView?
    var initialCenter: CGPoint?
    var startingRect = CGRect.zero
    
    
    let maxOverlayAlpha: CGFloat = 0.8
    let minOverlayAlpha: CGFloat = 0.4
    var timer: Timer?
    var watchTime: Int = 0

    
    @IBOutlet weak var recomLabel: UILabel!
    @IBOutlet weak var recomStackView: UIStackView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var postTimeLabel: UILabel!
    @IBOutlet var commentCounterLabel: UILabel!
    @IBOutlet var likeCounterLabel: UILabel!
    @IBOutlet var descLabel: ActiveLabel!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var likeImageView: UIImageView!
    @IBOutlet weak var commentStack: UIStackView!
    @IBOutlet weak var likeStack: UIStackView!
    @IBOutlet weak var sharedImageView: UIImageView!
    @IBOutlet weak var profileStack: UIStackView!
    @IBOutlet weak var reportImageView: UIImageView!
    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var iconVerified: UIImageView!
    
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
    @IBOutlet weak var mediaHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var postTimeToCaptionConstraint: NSLayoutConstraint!
    @IBOutlet weak var postTimeToButtonConstraint: NSLayoutConstraint!
    
    lazy var selebCarouselView: NewSelebCarouselView = {
        let carousel = NewSelebCarouselView()
        carousel.view.translatesAutoresizingMaskIntoConstraints = false
        carousel.view.layer.masksToBounds = true
        carousel.view.isHidden = true
        carousel.view.backgroundColor = .white
        carousel.view.clipsToBounds = true
        return carousel
    }()
    
    var newView: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selebCarouselView.view.fillSuperview()
        if let height = height {
            updateHeightConstraint(height)
        }
        
        
        self.profileStack.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(self.handleWhenTappedProfile)
            )
        )
        
        self.likeStack.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self, action: #selector(self.whenHandleTappedLike)
            )
        )
        
        self.commentStack.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self, action: #selector(self.whenHandleTappedComment)
            )
        )
        
        self.sharedImageView.isUserInteractionEnabled = true
        self.sharedImageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(self.whenHandleTappedShared)
            )
        )
        
        self.reportImageView.isUserInteractionEnabled = true
        self.reportImageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action:
                                    #selector(self.whenHandleTappedReport))
        )
        
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            // Update the cell
//            updateHeightConstraint(10)
        }
    }
    
    override func prepareForReuse() {
        mediaView.isHidden = false // 1
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mediaView.addSubview(selebCarouselView.view)
        selebCarouselView.view.fillSuperview()
        mediaView.isHidden = false // 2
        if let height = height {
            updateHeightConstraint(height)
        }
        iconVerified.layer.cornerRadius = iconVerified.frame.width / 2
        iconVerified.layer.borderWidth = 1
        iconVerified.layer.borderColor = UIColor.white.cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}


extension BaseFeedMultipleTableViewCell {
    
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
    
    func setupRecomendation(feed: Feed) {
        enum TypeBase: String { case item, user }
        
        guard let value = feed.valueBased, let type = feed.typeBased, let _ = feed.similarBy else {
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
        self.height = height
        mediaView.isHidden = false
        updateHeightConstraint(height)
        selebCarouselView.height = height
        descText = feed.post?.postDescription ?? ""
        while descText.last == "\n" {
            descText.removeLast()
        }
        if feed.post?.postDescription == "-" {
            descText = ""
        }
        let isCaptionEmpty = descText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        postTimeToCaptionConstraint.isActive = !isCaptionEmpty
        postTimeToButtonConstraint.isActive = isCaptionEmpty
        
		var photo = feed.account?.photo ?? ""
		
		if URL(string: photo) != nil {
            userImageView.loadImage(at: photo, .w40)
        } else {
            userImageView.image = UIImage(named: .get(.empty))
        }
        prefixText = feed.account?.username ?? ""
        
        
        let hideVerifiedAccount = feed.account?.isVerified ?? false == false
        iconVerified.isHidden = hideVerifiedAccount
        likeImageView.image = feed.isLike ?? false ? #imageLiteral(resourceName: "iconHeart") : #imageLiteral(resourceName: "iconLike")
        likeCounterLabel.text = "\(feed.likes ?? 0)"
        commentCounterLabel.text = "\(feed.comments ?? 0)"
        usernameLabel.text = feed.account?.username ?? ""
        postTimeLabel.text = TimeFormatHelper.soMuchTimeAgoNew(date: feed.createAt ?? 0)
        selebCarouselView.priceLabel.text = feed.post?.product?.price?.toMoney()
        
        
        if !expanded { isExpanded = descText.count < 100 }
        
        descLabel.isHidden = descText.isEmpty == true ? true : false
        descLabel.setLabel(prefixText: prefixText, expanded: expanded, mainText: descText, 100) {
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
        
        if feed.post?.product != nil {
            selebCarouselView.isProduct = true
            selebCarouselView.seeProductHandler = {
                self.seeProductHandler?()
            }
        } else {
            selebCarouselView.isProduct = false
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
        printIfDebug("@@@ DEBUG:--- watch time multiple post \(watchTime)")
    }
    
    func startTimer() {
        watchTime = 0
        if feed?.mediaCategory ?? "" == "MULTIPLE" {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        }
        
    }

    
    func sendAnalyticsToFirebase() {
        guard AUTH.isLogin() else { return }
        guard Int(watchTime) >= 3 else { return }
        
        let evenName        = "kipas_\(feed?.id ?? "")"
        let viewDuration    = "\(Int(watchTime))"
        let totalDuration   = "0"
        let viewDate        = "\(Date().millisecondsSince1970)"
        let createAt        = "\(feed?.createAt ?? 0)"
        let typePost        = "\(feed?.typePost ?? "")"
        let uid             = getIdUser()
        let feedId          = feed?.id ?? ""
        let viewType        = feed?.mediaCategory ?? ""
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
    }
    
    func calculatePercentage(value:CGFloat, percentageVal:CGFloat) -> CGFloat{
        let val = value * percentageVal
        return val / 100.0
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
    
    func updateHeightConstraint(_ height: CGFloat) {
        mediaView.isHidden = false
        var newHeight: CGFloat = 0
        if height == 1920 {
            if let height = feed?.post?.medias?.first?.metadata?.height {
                print("Tinggi Baru: \(height)")
                newHeight = CGFloat(Int(height)!)
                mediaHeightConstraints.constant =  CGFloat(Int(height)!)
            }
        } else {
            print("Tinggi Lama: \(height)")
            newHeight = height
            mediaHeightConstraints.constant = height
        }
        
        let width: CGFloat = UIScreen.main.bounds.width
        print("\(width) WWIDTTTTTTHHH")
        selebCarouselView.view.fillSuperview()
        selebCarouselView.view.frame = CGRect(x: 0, y: 0, width: width, height: newHeight)
        mediaView.layoutIfNeeded()
        mediaView.isHidden = false
        selebCarouselView.view.isHidden = true
        selebCarouselView.view.layoutSubviews()
        selebCarouselView.view.layoutIfNeeded()
        if let medias = feed?.post?.medias {
            selebCarouselView.items = medias
            selebCarouselView.setIsPageView(values: medias.count)
            selebCarouselView.pageController.numberOfPages = medias.count
        }
        selebCarouselView.view.isHidden = false
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
    
    @objc func whenHandleTappedLike() {
        if(!AUTH.isLogin()){
            guard let item = self.feed else {
                return
            }
            self.likeHandler?(item)
        }else{
            let isLike = self.feed?.isLike ?? false
            let likeCounter = self.feed?.likes  ?? 0
            self.feed?.isLike = !isLike
            self.feed?.likes = likeCounter + (!isLike ? 1 : -1)
            configureStatusLike(status: !isLike)
            likeCounterLabel.text = "\(likeCounter + (!isLike ? 1 : -1))"
            if let feed = self.feed {
                self.updateFeed?(feed)
            }
            
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
}


