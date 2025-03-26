//
//  HomeTableViewCell.swift
//  KD Tiktok-Clone
//
//  Created by Sam Ding on 9/8/20.
//  Copyright © 2020 Kaishan. All rights reserved.
//

import UIKit
import AVFoundation
import Kingfisher
//import VersaPlayer
import FirebaseAnalytics
import KipasKipasShared

class TiktokPostViewCell: UICollectionViewCell {
    
    // MARK: - Variables
    var feed: Feed? {
        didSet {
            handleShareView()
        }
    }
    var currentMediaIndex: Int = 0
    var backHandler: (() -> Void)?
    var productBeliOnClick: ((_ id: String, _ product: Product, _ feed: Feed) -> Void)?
    var commentHandler: ((_ item: Feed, _ autoFocusToField: Bool) -> Void)?
    var likeFeed: ((_ feed: Feed) -> Void)?
    var profileHandler: ((_ id: String, _ type: String) -> Void)?
    var userNameHandler: ((_ id: String, _ type: String) -> Void)?
    var mentionHandler: ((_ mention: String) -> Void)?
    var hashtagHandler: ((_ hashtag: String) -> Void)?
    var shareHandler: (() -> Void)?
    var refresh: (() -> Void)?
    var productBgOnClick: ((_ feed: Feed) -> Void)?
    var followIconOnClick: ((_ feed: Feed) -> Void)?
    var donationCategoryOnClick: ((_ feed: Feed) -> Void)?
    var donationCardOnClick: ((_ feed: Feed) -> Void)?
    var floatingLinkOnClick: ((_ feed: Feed) -> Void)?
    var detikHandler: (() -> Void)?
    var kompasHandler: (() -> Void)?
    var cumicumiHandler: (() -> Void)?
    var cnnHandler: (() -> Void)?
    var suaraHandler: (() -> Void)?
    var startPaidMessageHandler: ((_ feed: Feed) -> Void)?
//    var videoTiktokPlaying: (() -> Void)?

    // MARK: - IBOutlet
    
    @IBOutlet weak var captionView: KKScrollableCaptionView!
    @IBOutlet weak var trendingAtContainerStackView: UIStackView!
    @IBOutlet weak var trendingAtLabel: UILabel!
    @IBOutlet weak var videoProgressView: UIProgressView!
    @IBOutlet weak var progressBarContainerView: UIView!
    @IBOutlet weak var recomLabel: UILabel!
    @IBOutlet weak var recomStackView: UIStackView!
    @IBOutlet weak var invisibleView: UIView!
    @IBOutlet weak var invisibleViewLeft: UIView!
    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet var commentImageView: UIImageView!
    @IBOutlet var commentCounterLabel: UILabel!
    @IBOutlet var loveCounterLabel: UILabel!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var postedDateLabel: UILabel!
    @IBOutlet var postDescLabel: ActiveLabel!
    @IBOutlet var shareImageView: UIImageView!
    @IBOutlet var verifiedImageView: UIView!
    @IBOutlet weak var descProductLabel: UILabel!
    @IBOutlet weak var imageProduct: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var beliButton: UIButton!
    @IBOutlet weak var productBgView: UIView!
    @IBOutlet weak var commentSectionView: UIView!
    
    @IBOutlet weak var closeProductCardIconStackView: UIStackView!
    @IBOutlet weak var miniCardProductTitle: UILabel!
    @IBOutlet weak var miniCardProductPrice: UILabel!
    @IBOutlet weak var miniCardProductStackView: UIStackView!
    
    @IBOutlet weak var postComponentsStackView: UIStackView!
    @IBOutlet var shortcutExtImages: [UIImageView]!
    @IBOutlet weak var shortcutExtStackView: UIStackView!
    @IBOutlet weak var shortcutLiveStreaming: UIView!
    
    @IBOutlet weak var coinPriceLabel: UILabel!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var bottomConstraintLiveStreaming: NSLayoutConstraint!
    @IBOutlet weak var paidMessageContainerStackView: UIStackView!
    @IBOutlet weak var startPaidMessageButtonView: UIView!
    weak var weakParent: UIViewController?
    @IBOutlet var innerCollection: UICollectionView!
    @IBOutlet weak var likeImageView: UIImageView!
    var feedbarController: FeedbarController?
    
    var timer: Timer?
    var watchTime = 0
    var tempWatchTime: Int = 0
    var videoDuration: Double = 0.0
    var isLogin: Bool = !HelperSingleton.shared.token.isEmpty
    var userID: String = "" {
        didSet {
            handleShareView()
        }
    }
    var isCleeps = false
    private var limitTextCaption: Int?
    
    @IBOutlet weak var layerView: PassThroughView!
    private let layerLess = CAGradientLayer()
    private let layerMore = CAGradientLayer()
    
    @IBOutlet weak var viewSpaceFeedBar: UIView!
    @IBOutlet weak var viewSpaceProduct: UIView!
    @IBOutlet weak var followIconImageView: UIImageView!
    
    @IBOutlet weak var donationContainerStackView: UIStackView!
    @IBOutlet weak var donationCoverImageView: UIImageView!
    @IBOutlet weak var amountColledtedProgressBar: UIProgressView!
    @IBOutlet weak var amountCollectedLabel: UILabel!
    @IBOutlet weak var donationCategoryBlurView: UIVisualEffectView!
    @IBOutlet weak var donationCategoryContainetView: UIView!
    // MARK: - Lifecycles
    @IBOutlet weak var donationCategoryLabel: UILabel!
    @IBOutlet weak var donationNowButton: UIButton!
    
    @IBOutlet weak var videoProgressBarContainerView: UIView!
    @IBOutlet weak var loadingBuffer: KKLoadingIdicatorV1!
    
    lazy var cellShortCutExternal: [KKFloatingActionButtonCell] = []
    var isVideoPlaying: ((Bool) -> Void)?
    
    lazy var cnnCell: KKFloatingActionButtonCell = {
       let cell = KKFloatingActionButtonCell()
        cell.size = 40
        let imageView = UIImageView()
        imageView.loadImage(at: "https://koanba-storage-prod.oss-cn-hongkong.aliyuncs.com/img/media/CNN.png")
        cell.image = imageView.image
        return cell
    }()
    
    lazy var detikCell: KKFloatingActionButtonCell = {
       let cell = KKFloatingActionButtonCell()
        cell.size = 40
        let imageView = UIImageView()
        imageView.loadImage(at: "https://koanba-storage-prod.oss-cn-hongkong.aliyuncs.com/img/media/Detik.png")
        cell.image = imageView.image
        return cell
    }()
    
    lazy var kompasCell: KKFloatingActionButtonCell = {
       let cell = KKFloatingActionButtonCell()
        cell.size = 40
        let imageView = UIImageView()
        imageView.loadImage(at: "https://koanba-storage-prod.oss-cn-hongkong.aliyuncs.com/img/media/Kompas.png")
        cell.image = imageView.image
        return cell
    }()
    
    lazy var newsExternal: KKFloatingActionButton = {
        let screenWidth = UIScreen.main.bounds.width
        let button = KKFloatingActionButton(x: screenWidth - 56, y: 140)
        button.size = 40
        button.color =  UIColor(white: 0, alpha: 0.3)
        button.shadowOffset = CGSize(width: 0.0, height: 2.0)
        button.shadowOpacity = 0.5
        button.shadowRadius = 2.0
        button.shadowPath = button.circlePath
        button.closedImage = UIImage(named: .get(.iconNewsExternal))
        button.openedImage = UIImage(named: .get(.iconCloseWhite))
        button.cellHorizontalAlign = .left
        button.isHidden = true
        return button
    }()
    
    private lazy var floatingLinkView: FloatingLinkView = {
        let view = FloatingLinkView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        feed = nil
        usernameLabel.text = ""
        verifiedImageView.isHidden = true
        postDescLabel.text = ""
        userImageView.image = nil
        progressBarContainerView.isHidden = true
        viewSpaceFeedBar.isHidden = true
        currentMediaIndex = 0
        miniCardProductTitle.text = nil
        miniCardProductPrice.text = nil
        miniCardProductStackView.isHidden = true
        productBgView.isHidden = true
//        self.productBgView.alpha = 1
        commentSectionView.isHidden = true
        watchTime = 0
        tempWatchTime = 0
        videoDuration = 0.0
        timer?.invalidate()
        timer = nil
        isCleeps = false
        productBgView.alpha = 1
        miniCardProductStackView.alpha = 0
        feedbarController = nil
        trendingAtContainerStackView.isHidden = true
        trendingAtLabel.isHidden = true
        trendingAtLabel.text = nil
        donationContainerStackView.isHidden = true
        donationCategoryContainetView .isHidden = true
        loadingBuffer.isHidden = true
        videoProgressBarContainerView.isHidden = true
        newsExternal.isHidden = true
        shortcutExtStackView.isHidden = true
        captionView.reset()
        paidMessageContainerStackView.isHidden = true
        shortcutLiveStreaming.isHidden = true
    }
    
    deinit {
        self.clean()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        shortcutLiveStreaming.isHidden = true
        
        innerCollection.register(UINib(nibName: "TiktokPostMediaViewCell", bundle: SharedBundle.shared.bundle), forCellWithReuseIdentifier: "MediaCell")
        
        commentImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.whenHandleTappedCommentButton)))
        commentImageView.isUserInteractionEnabled = true
        
        likeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.whenHandleTappedLikeButton)))
        likeImageView.isUserInteractionEnabled = true
        
        usernameLabel.textColor = .white
        captionView.textColor = .white
        
        startPaidMessageButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleWhenTappedStartPaidMessageView)))
        userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleWhenTappedProfile)))
        usernameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleWhenTappedUsername)))
        shareImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleWhenTappedShare)))
        productBgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.whenProductBgTapped)))
        closeProductCardIconStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleCloseProductCardTapped)))
        miniCardProductStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleWhenMiniProductCardTapped)))
        commentSectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.whenHandleTappedCommentSection)))
        followIconImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.whenHandleTappedFollowIconSection)))
        trendingAtContainerStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.whenHandleTappedTrendingIconSection)))
        donationContainerStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.whenHandleTappedContainerStackView)))
        donationCategoryContainetView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.whenHandleTappedDonationCategoryView)))

        usernameLabel.addDropShadow()
        loveCounterLabel.addDropShadow()
        postDescLabel.addDropShadow()
        commentCounterLabel.addDropShadow()
        shareLabel.addDropShadow()
        setupOverlayLayer()
        donationCategoryContainetView.alpha = 0.5
        
        loadingBuffer.lineColor = .secondary
        loadingBuffer.trackColor = .contentGrey
        
        shortcutExtImages.forEach { icon in
            if icon.tag == 1 {
                icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapKompasIcon)))
            } else if icon.tag == 2 {
                icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDetikIcon)))
            } else if icon.tag == 3 {
                icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapCNNIcon)))
            } else if icon.tag == 4 {
                icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapCumiCumiIcon)))
            } else if icon.tag == 5 {
                icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapSuaraIcon)))
            }
        }
    }

    @objc func handleTapDetikIcon() {
        detikHandler?()
    }

    @objc func handleTapKompasIcon() {
        kompasHandler?()
    }


    @objc func handleTapCumiCumiIcon() {
       cumicumiHandler?()
    }

    @objc func handleTapCNNIcon() {
       cnnHandler?()
    }

    @objc func handleTapSuaraIcon() {
       suaraHandler?()
    }
    
    func setupRecomendation(feed: Feed?) {
        enum TypeBase: String { case item, user }
        recomStackView.isHidden = false
        
        if let _ = feed?.post?.product {
            recomStackView.isHidden = true
            return
        }
        
        guard let value = feed?.valueBased, let type = feed?.typeBased, let _ = feed?.similarBy else {
            recomStackView.isHidden = true
            return
        }
        
        let typeBase: TypeBase = type == "item" ? .item : .user
        
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
        let myAttribute = [NSAttributedString.Key.font: UIFont.Roboto(.bold, size: 12), NSAttributedString.Key.foregroundColor: UIColor.white]
        myString.append(NSMutableAttributedString(string: value, attributes: myAttribute))
        return myString
    }
    
    func sendAnalyticsToFirebase(cleepsCountry: CleepsCountry, isCleeps: Bool) {
        
        guard self.isLogin else { return }
        
        DispatchQueue.main.async {
            self.getMediaCell { [weak self] cell in
                guard let self = self else { return }
                if isCleeps {
                    guard Int(self.watchTime) != 0 else { return }
                } else {
                    if self.feed?.mediaCategory ?? "" == "SINGLE_VIDEO" {
//                        self.watchTime = Int(cell.watchTime)
                        guard self.watchTime >= 1 else {
                            print("@@@ watchTime single video kurang dari 1 detik \(self.watchTime)")
                            return
                        }
                    } else {
                        guard self.watchTime >= 3 else {
                            print("@@@ watchTime bukan single video kurang dari 3 detik \(self.watchTime)")
                            return
                        }
                    }
                }
                
                var evenName = ""
                if isCleeps {
                    evenName = "clp\(cleepsCountry.code)_\(self.feed?.id ?? "")"
                } else {
                    evenName = "kipas_\(self.feed?.id ?? "")"
                }

                let hashtags = self.feed?.post?.hashtags?.map({ "#\($0.value ?? "")" }).joined(separator: " ") ?? ""
                var item = RecomAnalyticsItem(
                    uid: self.userID,
                    feedId: self.feed?.id,
                    typePost: self.feed?.typePost,
                    createAt: self.feed?.createAt,
                    viewType: self.feed?.mediaCategory,
                    hashtags: hashtags,
                    channelCode: isCleeps ? cleepsCountry.rawValue : "home",
                    viewDuration: Double(self.watchTime),
                    totalDuration: cell.videoDuration).param
                
                Analytics.logEvent(evenName, parameters: item)
                
                evenName = ""
                item = [:]
                cell.watchTime = 0
                self.watchTime = 0
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func timerAction() {
        watchTime += 1
        // print("@@@ Timer: watch time \(feed?.mediaCategory ?? "") \(watchTime)")
        if watchTime == 3, productBgView.isHidden == false {
//            closeProductCard()
        }
    }
    
    func startTimer() {
        watchTime = 0
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        
    }
    
    //MARK: - Tap Handler
    
    @objc
    func handleWhenTappedStartPaidMessageView() {
        guard let item = self.feed else {
            return
        }
        startPaidMessageHandler?(item)
    }
    
    @objc
    func whenHandleTappedTrendingIconSection() {
        trendingAtLabel.isHidden = !trendingAtLabel.isHidden
    }


    @objc
    func whenHandleTappedDonationCategoryView() {
        guard let item = self.feed else {
            return
        }
        donationCategoryOnClick?(item)
    }

    @objc
    func whenHandleTappedContainerStackView() {
        guard let item = self.feed else {
            return
        }
        donationCardOnClick?(item)
    }

    @objc
    func whenHandleTappedFollowIconSection() {
        guard let item = self.feed else {
            return
        }
        self.followIconOnClick?(item)
    }
    
    @objc
    func handleWhenMiniProductCardTapped() {
        self.productBgOnClick?(feed!)
    }
    
    @objc
    func handleCloseProductCardTapped() {
        closeProductCard()
    }
    
    @objc
    func handleWhenTappedProfile() {
        self.profileHandler?(self.feed?.account?.id ?? "", self.feed?.typePost ?? "")
    }
    
    @objc
    func handleWhenTappedUsername() {
        self.userNameHandler?(self.feed?.account?.id ?? "", self.feed?.typePost ?? "")
    }
    
    @objc
    func handleWhenTappedShare(){
        self.shareHandler?()
    }
    
    @objc
    func backClicked() {
        backHandler?()
    }

    @objc
    func whenHandleTappedCommentButton() {
        guard let item = self.feed else {
            return
        }
        self.commentHandler?(item, false)
    }

    @objc
    func whenHandleTappedCommentSection() {
        guard let item = self.feed else {
            return
        }
        self.commentHandler?(item, true)
    }
    
    @objc
    func whenHandleTappedLikeButton() {
        likeImageView.transform = .init(scaleX: 0.5, y: 0.5)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.likeImageView.transform = .identity
            }
        }
        if feed != nil{
            let isLike = feed?.isLike ?? false
            let likeCounter = feed?.likes ?? 0
            feed?.isLike = !isLike
            feed?.likes = likeCounter + (!isLike ? 1 : -1)
            NotificationCenter.default.post(
                name: Notification.Name("handleUpdateHotNewsCellLikesFromProfileFeed"),
                object: nil,
                userInfo: [
                    "postId": feed?.post?.id ?? "",
                    "feedId": feed?.id ?? "",
                    "accountId": feed?.account?.id ?? "",
                    "likes": feed?.likes ?? 0,
                    "isLike": feed?.isLike ?? false
                ]
            )
            self.likeFeed?(feed!)
            if self.isLogin {
                self.configureStatusLike(status: feed?.isLike ?? false)
                self.updateLikedFeedNumber(feed?.likes)
            }
        }
    }
    
    func setupOverlayLayer() {
        let clear = UIColor.clear.cgColor
        let blackLight = UIColor.black.withAlphaComponent(0.2).cgColor
        let blackMiddle = UIColor.black.withAlphaComponent(0.3).cgColor
        let blackDark = UIColor.black.withAlphaComponent(0.4).cgColor
        
        layerLess.colors = [blackLight,clear,clear,clear, clear, clear, clear, clear, clear, clear,blackLight, blackMiddle, blackDark]
//        layerLess.startPoint = CGPoint(x: 0.5, y: 0.9)
//        layerLess.endPoint = CGPoint(x: 0.5, y: 0)

        layerLess.startPoint = CGPoint(x: 0.0, y: 0.0)
        layerLess.endPoint = CGPoint(x: 0, y: 1)

        layerLess.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        layerMore.removeFromSuperlayer()
        layerView.backgroundColor = .clear
        layerView.layer.addSublayer(layerLess)
    }
    
    func setupOverlayMoreLayer() {
        let clear = UIColor.clear.cgColor
        let color = UIColor.black.withAlphaComponent(0.3).cgColor

        layerMore.colors = [color, clear, color]
        layerMore.startPoint = CGPoint(x: 1, y: 1)
        layerMore.endPoint = CGPoint(x: 1, y: 1)
        layerMore.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

        layerLess.removeFromSuperlayer()
        layerView.backgroundColor = .clear
        layerView.layer.addSublayer(layerMore)
    }
    
    @objc
    func whenProductBgTapped() {
        self.productBgOnClick?(feed!)
//        var dataSource = AnotherProductModel.DataSource()
//        dataSource.id = self.feed?.account?.id ?? ""
//        ProductSheetView.openSheet(
//            from: weakParent!,
//            products: [feed!.post!.product!],
//            dataSource: dataSource,
//            onShop: { [weak self] in
//                guard let self = self else { return }
//                guard self.isLogin else {
//                    self.showAuthPopUp()
//                    return
//                }
//
////                let storeController = AnotherProductController(mainView: AnotherProductView(), dataSource: dataSource)
////                storeController.bindNavigationBar(.get(.shopping), true)
////                storeController.hidesBottomBarWhenPushed = true
////                self.weakParent?.navigationController?.pushViewController(storeController, animated: true)
//            },
//            onMessage: { product in
//                guard self.isLogin else {
//                    self.showAuthPopUp()
//                    return
//                }
//            },
//            onShare: { [weak self] product in
//                guard let self = self else { return }
//                guard self.isLogin else {
//                    self.showAuthPopUp()
//                    return
//                }
//
////                if let name = product.name, let productID = product.id , let url = product.medias?.first?.thumbnail?.large{
////                    let text =  "Beli produk \(name) - Klik link berikut untuk membuka tautan: \(APIConstants.webURL)/shop/\(productID)"
////
////                    let vc = makeCustomShare(url: url, message: text, product: product)
////                    self?.weakParent?.present(vc, animated: true, completion: nil)
////                }
//            },
//            onBuy: { product in
//                self.productBeliOnClick?(self.feed?.post?.id ?? "", product)
//            }
//        )
    }
    
    private func showAuthPopUp() {
//        let popup = AuthPopUpViewController(mainView: AuthPopUpView())
//        popup.modalPresentationStyle = .overFullScreen
//        self.weakParent!.present(popup, animated: false, completion: nil)
//
//        popup.handleWhenNotLogin = {
//            popup.dismiss(animated: false, completion: nil)
//        }
    }
    
    @IBAction func whenHandleTappedBeliButton(_ sender: Any) {
        guard let feed = self.feed, let product = feed.post?.product else { return }
        self.productBeliOnClick?(feed.post?.id ?? "", product, feed)
    }
    
    func updateLikedFeedNumber(_ likes: Int?) {
        self.loveCounterLabel.text = likes?.countFormat()
    }
    
    func configureStatusLike(status: Bool) {
        if status {
            self.likeImageView.image = UIImage(named: String.get(.iconTiktokLikeActive))
        } else {
            self.likeImageView.image = UIImage(named: "ic_like_white")
            //self.likeImageView.image = UIImage(named: "ic_like_border")
        }
        self.likeImageView.contentMode = .scaleAspectFill
        feed?.isLike = status
    }
    
    func resetViewsForReuse(){
//        loveImageView.tintColor = .white
    }
    
    func handleRegexForCaptionColor(text: String) -> NSAttributedString {
        let words = text.components(separatedBy: " ").filter { $0.hasPrefix("#") || $0.hasPrefix("@") }
        let attributed = NSMutableAttributedString(string: text as String)
        for word in words {
            let range = (text as NSString).range(of: word)
            attributed.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hexString: "E7F3FF"), range: range)
        }
        return attributed
    }
    
    func setupViewWithFeed(isCleeps: Bool, limitTextCaption: Int? = nil) {
        self.isCleeps = isCleeps
        self.limitTextCaption = limitTextCaption
        
        if let validProduct = self.feed?.post?.product {
            self.priceLabel.text = MoneyHelper.toMoney(amount: validProduct.price)
            self.descProductLabel.text = validProduct.name ?? ""
            self.miniCardProductTitle.text = "BELI \(validProduct.name ?? "")"
            self.miniCardProductPrice.text = MoneyHelper.toMoney(amount: validProduct.price)
            
            //            self.priceLabel.text = "Rp 15.000.000"
            //            self.descProductLabel.text = "Plastik Anti debu Plastik Anti debu Plastik Anti debu Plastik Anti debu Plastik Anti debu "
            
            self.imageProduct.loadImage(at: validProduct.medias?.first?.thumbnail?.large ?? "", .w360)
        }
        if FollowingUsers.shared.getUsers().contains(where: { $0["id"] as? String == feed?.account?.id }) {
            feed?.account?.isFollow = true
            followIconImageView.isHidden = true
        } else {
            followIconImageView.isHidden = feed?.account?.isFollow ?? false
        }
        
        if let post = self.feed?.post {
            donationCategoryLabel.text = post.donationCategory?.name ?? ""
            amountColledtedProgressBar.alpha = post.targetAmount == 0.0 ? 0.0 : 1
            amountColledtedProgressBar.progress = post.amountCollectedPercent
            donationCoverImageView.loadImage(at: post.medias?.first?.thumbnail?.large ?? "")
            let amountCollected = post.amountCollected?.toMoney() ?? "Rp 0"
            let amountCollectedAttribute = amountCollected.attributedText(font: .Roboto(.bold, size: 15), textColor: .primary)

            if let targetAmount = post.targetAmount, targetAmount != 0.0 {
                let targetAmountAttribute = " / \(targetAmount.toMoney())".attributedText(font: .Roboto(.bold, size: 10), textColor: .contentGrey)
                amountCollectedAttribute.append(targetAmountAttribute)
            }

            amountCollectedLabel.attributedText = amountCollectedAttribute
        }

        self.coinPriceLabel.text = "\(feed?.account?.chatPrice ?? 1)"
        self.setupFloatingLink()
        self.usernameLabel.text = feed?.account?.name ?? ""
        self.setupDescription()
        
        if let profilePhoto = self.feed?.account?.photo, !profilePhoto.isEmpty {
            self.userImageView.loadImage(at: profilePhoto, .w80)
        } else {
            let image = UIImage(named: "iconProfileEmpty", in: SharedBundle.shared.bundle, compatibleWith: nil)
            self.userImageView.image = image
        }
        
        let isProductHidden = self.feed?.post?.product == nil
        self.productBgView.isHidden = isProductHidden
        self.viewSpaceProduct.isHidden = isProductHidden
        self.beliButton.isHidden = isProductHidden
        
        if !isCleeps {
            miniCardProductStackView.isHidden = isProductHidden || !self.productBgView.isHidden
            trendingAtContainerStackView.isHidden = true
            trendingAtLabel.isHidden = true
            trendingAtLabel.text = nil
        } else {
            miniCardProductStackView.isHidden = true
            trendingAtContainerStackView.isHidden = true
            trendingAtContainerStackView.isHidden = self.feed?.trendingAt ?? 0 == 0
            trendingAtLabel.text = self.feed?.trendingAt?.toDateString(with: "dd/MM/yyyy HH:mm:ss")
        }
        
        let isDonation = feed?.post?.type == "donation"
        let font: UIFont = isDonation ? .roboto(.medium, size: 12) : .roboto(.regular, size: 15)
        postDescLabel.font = font
        captionView.font = font
        
        self.configureStatusLike(status: self.feed?.isLike ?? false)
        self.updateLikedFeedNumber(self.feed?.likes)
        self.commentCounterLabel.text = feed?.comments?.countFormat()
        
        self.postedDateLabel.text = Date(timeIntervalSince1970: TimeInterval((self.feed?.createAt ?? 1000)/1000 )).timeAgoDisplay()
        
        if let isVerified = self.feed?.account?.isVerified {
            verifiedImageView.isHidden = !isVerified
            paidMessageContainerStackView.isHidden = true//isVerified == true ? false : true
        } else {
            paidMessageContainerStackView.isHidden = true
        }
        
        resetFeedbar()
        viewSpaceFeedBar.isHidden = true
        progressBarContainerView.isHidden = true
        if let count = self.feed?.post?.medias?.count, count > 1 {
            viewSpaceFeedBar.isHidden = false
            progressBarContainerView.isHidden = false
        }
        showProgressView()
        
        self.contentView.layoutIfNeeded()
        innerCollection.reloadData()
    }
    
    func showOrHideNewsExternal(with country: TiktokType) {
        newsExternal.isHidden = country.rawValue != "CLEEPS_INDO"
//        shortcutExtStackView.isHidden = country.rawValue != "CLEEPS_INDO"
    }
    
    func setupDescription() {
        self.setupOverlayLayer()
        self.postDescLabel.sizeToFit()
  
        let isDonation = feed?.typePost == "donation"
        let description = isDonation ? feed?.post?.title : feed?.post?.postDescription
        
        captionView.text = description ?? ""
        captionView.mentionTapHandler = { [weak self] in
            self?.mentionHandler?($0)
        }
        captionView.hashtagTapHandler = { [weak self] in
            self?.hashtagHandler?($0)
        }
        captionView.toggleExpandHandler = { [weak self] isExpanded in
            if isExpanded {
                self?.setupOverlayMoreLayer()
            } else {
                self?.setupOverlayLayer()
            }
        }

        self.postDescLabel.setTiktokCaption(
            text: description ?? "",
            limitText: self.limitTextCaption,
            moreTap: { [weak self] in
                self?.setupOverlayMoreLayer()
            },
            lessTap: { [weak self] in
                self?.setupOverlayLayer()
            },
            mentionTap: { [weak self] username in
                self?.mentionHandler?(username)
            },
            hashtagTap: { [weak self] hashtag in
                self?.hashtagHandler?(hashtag)
            }
        )
    }
    
    private func showProgressView() {
        if  checkIfOnlySingleMediaAndIsAVideo() {
            videoProgressView.setProgress(0.0, animated: false)
            videoProgressView.isHidden = false
            videoProgressBarContainerView.isHidden = false
        } else {
            videoProgressView.isHidden = true
            videoProgressBarContainerView.isHidden = true
        }
    }
    
    private func checkIfOnlySingleMediaAndIsAVideo() -> Bool {
        if  let count = self.feed?.post?.medias?.count, count == 1,
            let type = self.feed?.post?.medias?.first?.type, type == "video" {
            return true
        } else {
            return false
        }
    }
    
    func setupFeedbar(){
        if !isMultiple() {
            return
        }
        
        var durations = [TimeInterval]()
        for item in feed?.post?.medias ?? [] {
            if item.type == "image"{
                durations.append(2.5)
            }else {
                if let time = item.metadata?.duration {
                    durations.append(time)
                } else {
                    durations.append(2.5)
                }
            }
        }
        
        print("***-TPVC setupFeedbar medias count : \(feed?.post?.medias?.count) \(durations.count)")
        if feedbarController == nil || feedbarController?.barCount != durations.count {
            feedbarController = FeedbarController(delegate: self, container: progressBarContainerView, durations: durations)
        }
    }
    
    func removeFeedbar() {
        if isMultiple() {
            return
        }
        
        progressBarContainerView.isHidden = true
        viewSpaceFeedBar.isHidden = true
        feedbarController?.stop()
        feedbarController?.removeFromContainer()
        feedbarController = nil
    }
}

// MARK: - Floating Link
extension TiktokPostViewCell: FloatingLinkViewDelegate {
    func setupFloatingLink() {
        addSubview(floatingLinkView)
        floatingLinkView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 150, paddingLeft: 24)
        
        floatingLinkView.delegate = self
        floatingLinkView.viewMargin = .init(top: 150, left: 24, bottom: 16, right: 24)
        
        let post = feed?.post
        floatingLinkView.alpha = (post?.floatingLink?.isEmpty ?? true) ? 0 : 1
        floatingLinkView.isHidden = (post?.floatingLink?.isEmpty ?? true)
        floatingLinkView.setupView(title: post?.floatingLinkLabel, siteName: post?.siteName, siteLogo: post?.siteLogo, accountPhotoUrl: feed?.account?.photo)
    }
    
    func didClose() {
        UIView.animate(withDuration: 0.2, animations: { self.floatingLinkView.alpha = 0 }, completion: { _ in
            self.floatingLinkView.isHidden = true
        })
    }
    
    func didOpen() {
        if let feed = feed {
            floatingLinkOnClick?(feed)
        }
    }
}


// MARK: -  FeedBar Delegate
extension TiktokPostViewCell: FeedbarDelegate{
    func hasReachStart() {
        scrollMedia(to: 0)
        changeFeedbar(to: 0)
    }
    
    func hasChanged(to index: Int)   {
        let curIndex = validateIndex(index)
        let isRepeat = curIndex == 0
        scrollMedia(to: curIndex, animated: !isRepeat)
        print("***- hasChanged to \(index), validated = \(curIndex), current index is \(currentMediaIndex)")
    }
    
    func hasReachEnd() {
        let countDiff = (feed?.post?.medias?.count != feedbarController?.barCount)
        if countDiff {
            let newIndex = currentMediaIndex + 1
            scrollMedia(to: newIndex, animated: true)
            reloadFeedbar(animateTo: newIndex)
        }else {
            scrollMedia(to: 0)
            changeFeedbar(to: 0)
        }
    }
    
    private func reloadFeedbar(animateTo: Int = 0){
        feedbarController = nil
        setupFeedbar()
        changeFeedbar(to: animateTo)
    }
    
    private func changeFeedbar(to index: Int, withHandler: Bool = false){
        let handler = { [weak self] in
            guard let self = self else { return }
            self.reloadFeedbar(animateTo: index)
        }
        
        if feed?.post?.medias?[index].type == "video" {
            feedbarController?.jump(to: index, whenOutOfRange: withHandler ? handler : nil)
        }else{
            feedbarController?.animate(to: index, whenOutOfRange: withHandler ? handler : nil)
        }
    }
    
    private func handleShareView(){
        guard let feedUserId = feed?.account?.id, !userID.isEmpty else { return }
        let isMe = (feedUserId == userID)
        if isMe {
            shareLabel.isHidden = true
            shareImageView.image = UIImage(named: .get(.iconKebabHorizontal))
        }
    }
}

// MARK: - Image Zoom Delegate
extension TiktokPostViewCell: ImageZoomDelegate {
    func imageZoomStart() {
        onPause()
    }
    
    func imageZoomEnd() {
        onPlay()
    }
}

// MARK: - Collection View Data Source and Delegate
extension TiktokPostViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        newsExternal.close()
        if scrollView.isDragging {
            feedbarController?.pause()
        }
    }
    
    func resetFeedbar() {
        currentMediaIndex = 0
        feedbarController?.stop()
        self.pause()
        getMediaCell { [weak self] cell in
            guard self != nil else { return }
            if !(cell.isImage){
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        newsExternal.close()
        print("*****debug PV scrollViewDidEndDecelerating")
        let visibleRect = CGRect(origin: innerCollection.contentOffset, size: innerCollection.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let index = innerCollection.indexPathForItem(at: visiblePoint)!
        
        feedbarController?.play()
        if currentMediaIndex != index.item {
            currentMediaIndex = index.item
            changeFeedbar(to: currentMediaIndex, withHandler: true)
        }
        
        checkAutoplay()
        handleInvisibleLayer()
        //setupDescription()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feed?.post?.medias?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! TiktokPostMediaViewCell
        cell.isBufferingVideo = { [weak self] isBuffer in
            guard let self = self else { return }
            isBuffer ? self.loadingBuffer.startAnimating() : self.loadingBuffer.stopAnimating()
        }
        cell.pauseAndSeek()
        newsExternal.close()
        //print("****** PV didEndDisplaying", feed?.account?.username)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCell", for: indexPath) as! TiktokPostMediaViewCell
        cell.delegate = self
        
        //coba produce ini setelah pertama install (kalo mulai double, berarti udah mulai masalah)
        if let medias = feed?.post?.medias {
            if medias.indices.contains(indexPath.item) {
                let media = medias[indexPath.item]
                //print("***debug PV cellForItemAt getVideoId:", ProxyServer.shared.getVideoId(urlPath: media.hlsUrl ?? ""), " now-playing-id:", ProxyServer.shared.nowPlayingId, feed?.account?.username ?? "" )
                cell.setMedia(media: media, parent: self)
                if isMultiple() {
                    addObserverVideoForFeedbar(media: medias[indexPath.item], cell: cell)
                }else{
                    addObserverForSingleVideo(medias: medias, cell: cell)
                }
            }
        }

        cell.isMp4 = { isMp4 in
            if isMp4 {
                if self.postedDateLabel.isHidden {
                    self.postedDateLabel.isHidden = false
                    self.postedDateLabel.text = "*"
                } else {
                    if let text = self.postedDateLabel.text, !text.contains("*") {
                        let isMp4Label = "\(self.postedDateLabel.text ?? "")-*"
                        self.postedDateLabel.text = isMp4Label
                    }
                }
            }
        }

        cell.showCover()
        cell.removeGesture()
        
        //rony, try to move setupVideo here
        //cell.setupVideo()
        
        let medias = feed?.post?.medias
        if !(medias?.count == 1 && medias?.first?.type == "image"){
            cell.setupGesture(views: [invisibleView, invisibleViewLeft])
        }
        
        return cell
    }
    
    private func addObserverForSingleVideo(medias: [Medias], cell: UICollectionViewCell) {
        guard let cell = cell as? TiktokPostMediaViewCell else { return }
        guard medias.count == 1 else { return }
        guard medias.first?.type == "video" else {
            print("bukan video")
            return
        }
        
        cell.singleVideoObserver = { [weak self] observer in
            guard let self = self else { return }
            switch observer {
            case let .timeChange(time, totalDuration):
                self.isVideoPlaying?(true)
//                self.videoTiktokPlaying?()
                let currentTime = Float(time.seconds)
                let totalTime = self.setTotalDurationMinus1SecondToPreventProgressViewResetToZeroBeforeFill100PercentOfTheView(duration: Float(floor(totalDuration.seconds)))
                
                self.updateSingleVideoProgress(current: currentTime, total: totalTime)
                
                if !self.isCleeps {
                    return
                }
                
                if Int(time.seconds) > self.tempWatchTime {
                    self.tempWatchTime = Int(time.seconds)
                    self.watchTime += 1
                    //print("@@@ Video change: current time \(self.tempWatchTime), watchTime \(self.watchTime)")
                    if self.watchTime == 3, self.productBgView.isHidden == false {
//                        self.closeProductCard()
                    }
                } else {
                    self.tempWatchTime = 0
                }
            case .hasEnded:
                self.isVideoPlaying?(false)
                KKVideoManager.instance.player.play(fromBegining: true)
            }
        }
    }
    
    func closeProductCard() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                self.productBgView.alpha = 0
                self.productBgView.transform = .init(translationX: -100, y: 0)
                self.postComponentsStackView.alpha = 0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.productBgView.isHidden = true
            self.productBgView.transform = .identity
            self.miniCardProductStackView.transform = .init(translationX: -100, y: 0)
            if self.feed?.post?.product == nil {
                self.miniCardProductStackView.isHidden = true
            } else {
                self.miniCardProductStackView.isHidden = false
                UIView.animate(withDuration: 0.5) {
                    self.postComponentsStackView.alpha = 1
                    UIView.animate(withDuration: 0.5, delay: 0.5) {
                        self.miniCardProductStackView.alpha = 1
                        self.miniCardProductStackView.transform = .identity
                    }
                }
            }
        }
    }
    
    private func setTotalDurationMinus1SecondToPreventProgressViewResetToZeroBeforeFill100PercentOfTheView(duration: Float) -> Float {
        return duration - 1.0
    }
    
    private func updateSingleVideoProgress(current: Float, total: Float) {
        DispatchQueue.main.async {
            let progress = Float(current / total)
            if progress == 0.0 {
                self.videoProgressView.setProgress(progress, animated: false)
            } else {
                UIView.animate(
                    withDuration: 1.0,
                    delay: 0.0,
                    options: [.curveLinear, .beginFromCurrentState, .preferredFramesPerSecond60],
                    animations: {
                        if progress != 0.0 {
                            self.videoProgressView.setProgress(progress, animated: true)
                            self.videoProgressView.layoutIfNeeded()
                        }
                    }, completion: nil)
            }
        }
    }
}

// MARK: - Helper
extension TiktokPostViewCell {
    func getMediaCell(_ callback: ((_ cell: TiktokPostMediaViewCell) -> Void))  {
        if !innerCollection.visibleCells.isEmpty {
            if let cell = innerCollection.visibleCells.first as? TiktokPostMediaViewCell{
                callback(cell)
            }
        }
    }
    
    func isMultiple() -> Bool { return feed?.post?.medias?.count ?? 0  > 1 }
    
    func checkAutoplay(fromBegining: Bool = true, file: String = #file, function: String = #function, line: Int = #line) {
        print("***TPVC checkAutoPlay", file.split(separator: "/").last, function, line)
        getMediaCell{ [weak self] cell in
            guard let self = self else { return }

            guard let cellIndex = self.innerCollection.indexPath(for: cell)?.item, currentMediaIndex == cellIndex else { return }
            
            
            if !cell.isImage{
                print("**** KKVideoPlayer isVideo")
                //cell.setupVideo()
                //cell.play(isFromPause: false, from: "TPV 939 -> \(from)")
                
                //cell.preparePlayer()
                
                cell.prepareKKPlayer(withThumbnail: fromBegining)
                KKVideoManager.instance.player.play(fromBegining: fromBegining)
                
                self.feedbarController?.setProgressCurrentBar(progress: 0)
            } else {
                KKVideoManager.instance.player.pause()
                //TiktokPostMediaViewCell.instance.curPlaying = cell.getMediaNameMP4()
            }
            
            
        }
    }
    
    func pause() {
        getMediaCell { [weak self] cell in
            guard self != nil else { return }
            if !(cell.isImage){
                //cell.setupVideo()
                //cell.pause()
            }
        }
    }
    
    func didEndDisplaying(fromComment: Bool = false, cleepsCountry: CleepsCountry, isCleeps: Bool){
        trendingAtLabel.isHidden = true
        newsExternal.close()
        //self.setupDescription()
        getMediaCell { [weak self] cell in
            guard self != nil else { return }
            stopTimer()
            cell.didEndDisplaying(fromComment: fromComment)
            sendAnalyticsToFirebase(cleepsCountry: cleepsCountry, isCleeps: isCleeps)
        }
    }
    
    func scrollMedia(to index: Int, animated: Bool = false){
        print("****debug PV scrollMedia to", index, feed?.account?.username, animated)
        currentMediaIndex = validateIndex(index)
        if currentMediaIndex == 0 && (feed?.post?.medias?.count ?? 1) == 1 && feedbarController != nil {
            removeFeedbar()
        }
        self.innerCollection.isPagingEnabled = false
        UIView.animate(withDuration: animated ? 0.2 : 0, animations: { [weak self] in
            guard let self = self else { return }
            self.innerCollection.scrollToItem(at: IndexPath(item: self.currentMediaIndex, section: 0), at: .centeredHorizontally, animated: false)
            }, completion: { [weak self] _ in
                self?.checkAutoplay()
            }
        )
        self.innerCollection.isPagingEnabled = true
        handleInvisibleLayer()
    }
    
    func onPause() {
        feedbarController?.pause()
    }
    
    func onPlay(){
        feedbarController?.play()
    }
    
    func validateIndex(_ index: Int) -> Int {
        var indexValidated = 0
        if index < feed?.post?.medias?.count ??  1 {
            indexValidated = index
        }
        return indexValidated
    }
    
    private func handleInvisibleLayer(){
        let isFirstIndex = currentMediaIndex == 0
        let isLastIndex = currentMediaIndex == ((feed?.post?.medias?.count ?? 0) - 1)
        invisibleViewLeft.isHidden = !isFirstIndex
        invisibleView.isHidden = !isLastIndex
    }
    
    private func addObserverVideoForFeedbar(media: Medias, cell: UICollectionViewCell) {
        print("***- addObserverVideoForFeedbar")
        guard let cell = cell as? TiktokPostMediaViewCell else { return }
        
        cell.singleVideoObserver = { [weak self] observer in
            guard let self = self else { return }
            guard let cellIndex = self.innerCollection.indexPath(for: cell)?.item, cellIndex == self.currentMediaIndex, !cell.isImage else { return }
            
            switch observer {
            case let .timeChange(time, totalDuration):
//                self.videoTiktokPlaying?()
                print("***- video jalan")
                let currentTime = Float(time.seconds)
                let totalTime = self.setTotalDurationMinus1SecondToPreventProgressViewResetToZeroBeforeFill100PercentOfTheView(duration: Float(floor(totalDuration.seconds)))
                
                //                print("***-+ \(self.currentMediaIndex) \(cellIndex) \(totalTime)")
                
                let progress = Float(currentTime / totalTime)
                DispatchQueue.main.async {
                    self.feedbarController?.setProgressCurrentBar(progress: progress)
                }
                
                if !self.isCleeps {
                    return
                }
                
                if Int(time.seconds) > self.tempWatchTime {
                    self.tempWatchTime = Int(time.seconds)
                    self.watchTime += 1
                    //print("@@@ Video change: current time \(self.tempWatchTime), watchTime \(self.watchTime)")
                    if self.watchTime == 3, self.productBgView.isHidden == false {
//                        self.closeProductCard()
                    }
                } else {
                    self.tempWatchTime = 0
                }
            case .hasEnded:
                print("***- video stop")
                let newIndex = self.currentMediaIndex + 1
                let indexValidated = self.validateIndex(newIndex)
                print("***- hasEnded # animate to \(indexValidated)")
                
                self.changeFeedbar(to: indexValidated)
                break
            }
        }
    }
    
    func clean(){
        self.removeFeedbar()
        self.weakParent = nil
        self.timer?.invalidate()
        self.timer = nil
        for i in 0...innerCollection.numberOfItems(inSection: 0){
            if let cell = innerCollection.cellForItem(at: IndexPath(item: i, section: 0)) as? TiktokPostMediaViewCell{
                cell.clean()
            }
        }
    }
}
