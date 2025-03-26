import UIKit
import KipasKipasNetworking
import CoreData
import FeedCleeps 
import KipasKipasShared
import KipasKipasDirectMessage
import KipasKipasDirectMessageUI
import KipasKipasDonationCart
import KipasKipasDonationCartUI
import TUIPlayerCore
// Create our own custom paging view and override the layout
// constraints. The default implementation positions the menu view
// above the page view controller, but since we're going to put the
// menu view inside the navigation bar we don't want to setup any
// layout constraints for the menu view.
class NavigationBarPagingView: PagingView {
    override func setupConstraints() {
        // Use our convenience extension to constrain the page view to all
        // of the edges of the super view.
        pageView.fillSuperview()
    }
}

// Create a custom paging view controller and override the view with
// our own custom subclass.
class NavigationBarPagingViewController: PagingViewController {
    enum position {
        case none
        case left
        case right
    }
    
    private(set) lazy var leftMaskLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor]
        gradientLayer.locations = [0.0, 0.2]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        return gradientLayer
    }()
    
    private(set) lazy var rightMaskLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
        gradientLayer.locations = [0.9, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        return gradientLayer
    }()
    
    private(set) lazy var pager = NavigationBarPagingView(
        options: options,
        collectionView: collectionView,
        pageView: pageViewController.view
    )

    var menuView: UIView {
        pager.collectionView
    }
    
    override func loadView() {
        view = pager
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let size = self.collectionView.bounds.size
        self.leftMaskLayer.frame = CGRect(x: 0, y: 0, width: size.width + 100, height: size.height)
        self.rightMaskLayer.frame = CGRect(x: -100, y: 0, width: size.width + 100, height: size.height)
    }
    
    public func maskUpdate(totalItemCount: Int, selectedIndex: Int) {
        if totalItemCount < 4 {
            self.addMask(.none)
        } else {
            if selectedIndex < 2 {
                self.addMask(.right)
            } else {
                self.addMask(.left)
            }
        }
    }
    
    private func addMask(_ position: position) {
        if position == .none {
            self.collectionView.layer.mask = nil
        } else if position == .left {
            self.collectionView.layer.mask = self.leftMaskLayer
        } else if position == .right {
            self.collectionView.layer.mask = self.rightMaskLayer
        }
    }
}

enum NewHomeTheme {
    case light
    case dark
    
    var color: (selected: UIColor, unselected: UIColor) {
        switch self {
        case .light:
            return (.contentGrey, .contentGrey)
        case .dark:
            return (.white, .whiteSmoke)
        }
    }
}

protocol NewHomeControllerDelegate {
    func didChangedTheme(with theme: NewHomeTheme)
}

class NewHomeController: UIViewController, AlertDisplayer, NavigationAppearance {
    
    var pagingViewController = NavigationBarPagingViewController()
    var controllerIndex = 1
    var uploadDelegate : UploadDelegate!
    var theme: NewHomeTheme = .dark
    private let preference = BaseFeedPreference.instance
    
    var isSelected = false
    var delegate: NewHomeControllerDelegate?
    
    private var isExpanded: Bool = false
    private var isImageFeedSelected: Bool = false
    private var selectedItem: HomeMenuItem?
    private var isExpandedStoryView: Bool = false
    
    private lazy var convManager: TXIMConversationManager = {
        let manager = TXIMConversationManager()
        return manager
    }()
    
    private lazy var titleControllers: [PagingItem] = [
        HomeMenuItem(index: 0, title: String.get(.donation)),
//        HomeMenuItem(index: 1, title: String.get(.following)),
        HomeMenuItem(
            icon: .iconDropdownCollapsed,
            index: 1,
            title: String.get(.following),
            isExpanded: isExpandedStoryView,
            onTapDropdownMenu: { [weak self] isExpanded, rect in
                self?.handleTapFollowingDropdown(isExpanded: isExpanded)
            }
        ),
        HomeMenuItem(
            icon: .iconDropdownCollapsed,
            index: 2,
            title: String.get(.hotRoom),
            isExpanded: isExpanded,
            onTapDropdownMenu: { [weak self] isExpanded, rect in
                self?.dropdownMenu(isExpanded: isExpanded, rect: rect)
            }
        ),
//        HomeMenuIconItem(
//            url: "https://koanba-storage-prod.oss-cn-hongkong.aliyuncs.com/assets_public/mobile/ios/portal_news/entry_point.png",
//            index: 2,
//            size: CGSizeMake(16, 16)
//        ),
        HomeMenuItem(index: 3, title: String.get(.feed))
    ]
   
    var unreadMessageCount: Int = 0 {
        didSet {
            if unreadMessageCount > 0 {
                if unreadMessageCount > 99 {
                    dmButton.showBadge(text: "99+")
                } else {
                    dmButton.showBadge(text: String(unreadMessageCount))
                }
            } else {
                dmButton.hideBadge()
            }
        }
    }
    
    private lazy var dropdown: KKDropDownMenuViewController =  {
        let boy = NSMutableAttributedString(
            string: "Milenial  ",
            attributes: [
                .font: UIFont.roboto(.regular, size: 18),
                .foregroundColor: UIColor.black
            ]
        )
        boy.append(.init(
            string: "♂",
            attributes: [
                .font: UIFont.systemFont(ofSize: 24)
            ]
        ))
        
        let girl = NSMutableAttributedString(
            string: "Milenial  ",
            attributes: [
                .font: UIFont.roboto(.regular, size: 18),
                .foregroundColor: UIColor.black
            ]
        )
        girl.append(.init(
            string: "♀",
            attributes: [
                .font: UIFont.systemFont(ofSize: 24),
            ]
        ))
        
        let dropdown = KKDropDownMenuViewController(
            menus: [
                .init(string: "Gen Z", attributes: [
                    .font: UIFont.roboto(.regular, size: 18),
                    .foregroundColor: UIColor.black
                ]),
                boy,
                girl,
                .init(string: "Anak-anak", attributes: [
                    .font: UIFont.roboto(.regular, size: 18),
                    .foregroundColor: UIColor.black
                ])
            ],
            frames: pagingViewController.menuView.frame,
            widthDimension: pagingViewController.options.estimatedItemWidth
        )
        
        dropdown.onSelectItem = { [weak self] in
//            self?.dropdownMenu(isExpanded: false, rect: .zero)
            
            let vc = CustomPopUpViewController(
                title: "Fitur sedang dalam proses pengembangan.",
                description: "Kami sedang menyempurnakan fitur ini, bersiaplah untuk pengalaman terbaik.",
                iconImage: UIImage(named: "img_in_progress"),
                iconHeight: 99
            )
            vc.delegate = self
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            self?.present(vc, animated: false)
        }
        return dropdown
    }()
    
    private lazy var exploreButton: UIButton = {
        let button: UIButton = UIButton(type: .custom)
        let image = UIImage(named: .get(.iconSearchNavigation))?.withRenderingMode(.alwaysTemplate)
        let imageFlipped = image!.flipHorizontally()?.withRenderingMode(.alwaysTemplate)
        button.setImage(imageFlipped, for: .normal)
        button.tintColor = .white
        button.layer.masksToBounds = false
        button.addTarget(self, action: #selector(handleShowExplore), for: .touchUpInside)
        return button
    }()
   
    private lazy var dmButton: BadgeButton = {
        let button = BadgeButton()
        let image = UIImage(named: "ic_dm_white")
        button.setImage(image!, for: .normal)
        button.layer.masksToBounds = false
        button.addTarget(self, action: #selector(handleShowDM), for: .touchUpInside)
        return button
    }()
    
    private lazy var coinIcon: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "ic_coin_gold")
        imgView.contentMode = .scaleAspectFit
        imgView.isUserInteractionEnabled = true
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    private lazy var totalCoin: UILabel = {
        let totalCoin = UILabel()
        totalCoin.text = "0"
        totalCoin.textColor = .white
        totalCoin.font = .roboto(.regular, size: 10)
        totalCoin.isUserInteractionEnabled = true
        return totalCoin
    }()
    
    private lazy var totalCoinContainerStackView: UIStackView = {
        let containerStackView = UIStackView()
        containerStackView.isHidden = true
        containerStackView.axis = .vertical
        containerStackView.alignment = .center
        containerStackView.isUserInteractionEnabled = true
        containerStackView.backgroundColor = .black.withAlphaComponent(0.5)
        containerStackView.isLayoutMarginsRelativeArrangement = true
        containerStackView.layoutMargins = .init(top: 8, left: 6, bottom: 8, right: 6)
        containerStackView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let contentStackView = UIStackView()
        contentStackView.axis = .horizontal
        contentStackView.alignment = .center
        contentStackView.spacing = 4
        contentStackView.isUserInteractionEnabled = true
        contentStackView.backgroundColor = .clear
        
        let coinText = UILabel()
        coinText.text = "Koin"
        coinText.textColor = .white
        coinText.font = .roboto(.regular, size: 10)
        coinText.isUserInteractionEnabled = true
        contentStackView.addArrangedSubview(coinText)
        
        contentStackView.addArrangedSubview(coinIcon)
        contentStackView.addArrangedSubview(totalCoin)
        
        containerStackView.addArrangedSubview(contentStackView)
        return containerStackView
    }()
    
    private lazy var shortcutLiveContainerStackView: UIStackView = {
        let containerStackView = UIStackView()
        containerStackView.axis = .vertical
        containerStackView.alignment = .center
        containerStackView.isUserInteractionEnabled = true
        containerStackView.backgroundColor = .white
        containerStackView.isLayoutMarginsRelativeArrangement = true
        containerStackView.layoutMargins = .init(top: 4, left: 6, bottom: 4, right: 4)
        containerStackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.isHidden = false
        
        let contentStackView = UIStackView()
        contentStackView.axis = .horizontal
        contentStackView.alignment = .center
        contentStackView.spacing = 4
        contentStackView.isUserInteractionEnabled = true
        contentStackView.backgroundColor = .clear
        
        let iconLive = UIImageView()
        iconLive.image = UIImage(named: "ic_live_white")?.withTintColor(.primary, renderingMode: .alwaysOriginal)
        iconLive.frame = .init(x: 0, y: 0, width: 20, height: 10)
        iconLive.contentMode = .scaleAspectFit
        iconLive.isUserInteractionEnabled = true
        contentStackView.addArrangedSubview(iconLive)
        
        let liveLabel = UILabel()
        liveLabel.text = "LIVE"
        liveLabel.textColor = .primary
        liveLabel.font = .roboto(.bold, size: 12)
        liveLabel.isUserInteractionEnabled = true
        contentStackView.addArrangedSubview(liveLabel)
        
        let iconRightArrow = UIImageView()
        iconRightArrow.image = UIImage(named: "ic_chevron_right_white")?.withTintColor(.primary, renderingMode: .alwaysOriginal)
        iconRightArrow.frame = .init(x: 0, y: 0, width: 5, height: 7)
        iconRightArrow.contentMode = .scaleAspectFit
        iconRightArrow.isUserInteractionEnabled = true
        contentStackView.addArrangedSubview(iconRightArrow)
        
        containerStackView.addArrangedSubview(contentStackView)
        containerStackView.alpha = 0
        containerStackView.setShadowRadius = 3
        containerStackView.setShadowOpacity = 0.2
        containerStackView.shadowColor = .black
        containerStackView.shadowOffset = .init(width: 0, height: 0)
        return containerStackView
    }()
    
    lazy var shortcutStoryView: ShortcutStoryView? = {
        let view = ShortcutStoryView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.isHidden = true
        return view
    }()
    
    lazy var donationCartCountingView: DonationCartCountingView = {
        let view = DonationCartCountingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var kipasKipasViewHasAnchored = false
    lazy var kipasKipasView: UIImageView = {
        let view = UIImageView(image: UIImage(named: .get(.iconTaglineKipasKipas)))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.isHidden = true
        return view
    }()

    let emptyController = UIViewController()
//    var donationVC = FeedFactory.createFeedDonationController()
//    var homeFVC = FeedFactory.createFeedController(isHome: true)

//    var following = FeedFactory.createFollowingCleepsController(isHome: true)
    let donationViewController =  HotNewsFactory.create(by: .donation, profileId: getIdUser())
    let followingViewController = HotNewsFactory.create(by: .following, profileId: getIdUser())
    let hotNewsViewController = HotNewsFactory.createHotRoom(by: .hotNews, profileId: getIdUser())
    
//    let feedTabController = FeedTabController()
    let imageFeedController = HotNewsFactory.create(by: .feed, profileId: getIdUser(), mediaType: .image)
    let videoFeedController = HotNewsFactory.create(by: .feed, profileId: getIdUser(), mediaType: .video)
//    let newsPortalController = NewsPortalTabController()
//    NewsPortalMenuRouter.create(showTitle: false)
    
    public var selectedViewController: UIViewController? {
        return viewControllerList[safe: controllerIndex]
    }

//    var cleepsIndo = FeedFactory.createFeedCleepsController(countryCode: .indo, isHome: true)

//    var cleepsIndo: UIViewController {
//        let users = ["bossgito", "pakgito", "erqyara", "yuya", "rifkibaru", "yasmine", "redpanda", "rony2"]
//        if users.contains(where: {$0 == getUsername()}) {
//            return HotNewsRouter.create(baseUrl: APIConstants.baseURL, authToken: getToken(), feedType: .hotNews)
//        }
//        return FeedFactory.createFeedCleepsController(countryCode: .indo, isHome: true)
//    }
//    var cleepsChina = FeedFactory.createFeedCleepsController(countryCode: .china, isHome: true)
    
    var viewControllerList: [UIViewController] = []
    
    private lazy var uploadProgress : UploadProgressView = {
        return UploadProgressViewFactory.create()
    }()
    
    private var isLoadMyCurrency = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestMyCoin()
        updateFollowingTab()
        selectCenterTabOneTime(forTabTitle: .get(.hotRoom))
//        self.setLastTab(cleepsIndo.presenter.identifier.rawValue)
        updateLastTab()
    }
    
    func selectCenterTabOneTime(forTabTitle title: String) {
        if !isSelected {
            if let index = indexForTitle(title) {
                pagingViewController.select(index: index)
                controllerIndex = index
                selectedItem = titleControllers[index] as? HomeMenuItem
                pagingViewController.maskUpdate(totalItemCount: titleControllers.count, selectedIndex: index)
            }
            isSelected = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.title = ""
        // dropdown.onSelectItem?()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.hideKeyboardWhenTappedAround()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.displayShadowToNavBar(status: false)
        navigationController?.setNavigationBarHidden(false, animated: true)
        setupNavigationBar(color: .clear, isTransparent: true)
        
        loadUnreadMessageCount()
    }
    
    func loadUnreadMessageCount() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.convManager.getTotalUnreadMessageCount { [weak self] count in
                self?.unreadMessageCount = Int(count)
            }
        }
    }
    
    var shortcutStoryViewWidthConstraint: NSLayoutConstraint! {
        didSet {
            shortcutStoryViewWidthConstraint.isActive = true
        }
    }
    
    var isExpandedShortcutStoryView: Bool = false {
        didSet {
            shortcutStoryView?.isExpanded = isExpandedShortcutStoryView
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UIView.animate(withDuration: 0.5) { [weak self] in
                    guard let self = self else { return }
                    self.shortcutStoryViewWidthConstraint.constant = self.shortcutStoryView!.isExpanded ? 300 : 24
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TXLiveBase.setLogLevel(.LOGLEVEL_NULL)
        UserManager.shared.accountId = getIdUser()
        UserManager.shared.accessToken = getToken()
        UserManager.shared.username = getUsername()

        showForceUpdatePopUp()
//        KKBrightnessManager.shared.configure()
        
//        donationVC.delegate = self
//        donationVC.topViewController = self
//        homeFVC.delegate = self
//        homeFVC.topViewController = self
//        following.delegate = self
//        cleepsIndo.delegate = self
//        cleepsIndo.topViewController = self
//        newsPortalController.delegate = self
//        cleepsChina.delegate = self
        
        viewControllerList = [
            donationViewController ,
//            donationVC,
//            following,
            followingViewController,
            hotNewsViewController,
//            newsPortalController,
//            feedTabController
            videoFeedController,
//            imageFeedController
//            homeFVC
//            cleepsChina
        ]

        //viewControllerList.insert(emptyController, at: 0)
//        viewControllerList.insert(trending, at: 0)
//        if let baseFeedController = viewControllerList[1] as? HomeFeedViewController {
//            baseFeedController.zoomDelegate = self
//        }
        
        pagingViewController = NavigationBarPagingViewController(viewControllers: viewControllerList)
        pagingViewController.register(HomeMenucell.self, for: HomeMenuItem.self)
        pagingViewController.register(HomeMenucell.self, for: HomeMenuIconItem.self)
        pagingViewController.borderOptions = .hidden
        pagingViewController.menuBackgroundColor = .clear
        pagingViewController.backgroundColor = .clear
        pagingViewController.menuHorizontalAlignment = .center
        pagingViewController.indicatorOptions = .visible(height: 0, zIndex: Int.max, spacing: .zero, insets: .init(horizontal: 8, vertical: 0))
        pagingViewController.collectionView.isScrollEnabled = false
        pagingViewController.delegate = self
        pagingViewController.dataSource = self
        pagingViewController.sizeDelegate = self
        pagingViewController.menuItemSpacing = 14
        updateTheme()
        
//        decideIsTiktokFromPreference()
        // Make sure you add the PagingViewController as a child view
        // controller and contrain it to the edges of the view.
        addChild(pagingViewController)
        view.addSubview(pagingViewController.view)
        pagingViewController.view.fillSuperview()
        pagingViewController.didMove(toParent: self)

        // Set the menu view as the title view on the navigation bar. This
        // will remove the menu view from the view hierachy and put it
        // into the navigation bar.
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: exploreButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: dmButton)
        navigationItem.titleView = pagingViewController.collectionView
        if let navigationBar = navigationController?.navigationBar {
            navigationItem.titleView?.frame = CGRect(origin: .zero, size: navigationBar.bounds.size)
        }
        setupUploadProgressView()
        addUploadProgressObserver()
        
        NotificationCenter.default.addObserver(self, selector: #selector(domainError(notification:)), name: .init("NSURLErrorDomain"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateIsFollowFromFolowingFolower(_:)), name: .updateIsFollowFromFolowingFolower, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateDonationCampaign), name: .updateDonationCampaign, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(disableScroll(_:)),
            name: ZoomableNotification.didZoom,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(enableScroll(_:)),
            name: ZoomableNotification.endZoom,
            object: nil
        )
        
        // Story
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(disableScroll(_:)),
            name: HotNewsStoryViewNotification.didShow,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(enableScroll(_:)),
            name:  HotNewsStoryViewNotification.didDismiss,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateFollowingTab),
            name: .updateFollowingTab,
            object: nil
        )

        pagingViewController.view.addSubview(totalCoinContainerStackView)
        pagingViewController.view.addSubview(shortcutLiveContainerStackView)
        if(shortcutStoryView != nil){
            pagingViewController.view.addSubview(shortcutStoryView!)
        }
        
        pagingViewController.view.addSubview(kipasKipasView)
        kipasKipasView.anchor(top: pagingViewController.view.safeAreaLayoutGuide.topAnchor, left: pagingViewController.view.leftAnchor, paddingTop: 7, paddingLeft: 16, width: 176, height: 46)
        
        shortcutStoryViewWidthConstraint = shortcutStoryView?.widthAnchor.constraint(equalToConstant: 24)

        if(shortcutStoryView != nil) {
            NSLayoutConstraint.activate([
                totalCoinContainerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 19),
                totalCoinContainerStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
                coinIcon.heightAnchor.constraint(equalToConstant: 12),
                coinIcon.widthAnchor.constraint(equalToConstant: 12),
                shortcutLiveContainerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 19),
                shortcutLiveContainerStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
                shortcutStoryView!.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height / 2 - 50),
                shortcutStoryView!.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                shortcutStoryView!.heightAnchor.constraint(equalToConstant: 86),
                shortcutStoryViewWidthConstraint
            ])
        }
        
        shortcutStoryView?.buttonCloseContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.isExpandedShortcutStoryView = self.shortcutStoryView!.isExpanded
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.totalCoinContainerStackView.setCornerRadius = self.totalCoinContainerStackView.frame.height / 2
//            self.totalCoinContainerStackView.isHidden = !AUTH.isLogin()
            
            self.shortcutLiveContainerStackView.setCornerRadius = self.shortcutLiveContainerStackView.frame.height / 2
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.shortcutLiveContainerStackView.transform = CGAffineTransform(
                translationX: self.shortcutLiveContainerStackView.frame.width, y: 0
            )
            self.shortcutLiveContainerStackView.alpha = 0
            UIView.animate(withDuration: 0.8) {
                self.shortcutLiveContainerStackView.transform = .identity
                self.shortcutLiveContainerStackView.alpha = 1
            }
        }
        
        totalCoinContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            let vc = CoinPurchaseRouter.create(baseUrl: APIConstants.baseURL, authToken: getToken() ?? "")
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
//        totalCoinContainerStackView.isHidden = !AUTH.isLogin()
        
        shortcutLiveContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.handleOnTapShortcutLive()
        }
        
        donationViewController.handleLoadMyCurrency = { [weak self] in
            guard let self = self else { return }
            self.requestMyCoin()
        }
        
        hotNewsViewController.handleLoadMyCurrency = { [weak self] in
            guard let self = self else { return }
            self.requestMyCoin()
        }
        
//        feedTabController.delegate = self
        imageFeedController.handleLoadMyCurrency = { [weak self] in
            guard let self = self else { return }
            self.requestMyCoin()
        }
        
        videoFeedController.handleLoadMyCurrency = { [weak self] in
            guard let self = self else { return }
            self.requestMyCoin()
        }
        
        imageFeedController.handleGetFeedForStories = { [weak self] feeds in
            guard let self = self else { return }
            self.didLoadStories(feed: feeds)
        }
        
        videoFeedController.handleGetFeedForStories = { [weak self] feeds in
            guard let self = self else { return }
            self.didLoadStories(feed: feeds)
        }
        
        setupDonationCart()
    }
    
    @objc private func updateDonationCampaign() {
        donationViewController.updateDonationCampaign()
    }
    
    private func handleOnTapShortcutLive() {
        let isLogin = getToken() != nil
        
        guard isLogin else {
            showLogin?()
            return
        }
        
        showLiveStreamingList?(nil)
    }
    
    private func requestMyCoin() {
        
        guard AUTH.isLogin() else { return }
        guard !isLoadMyCurrency else { return }
        
        isLoadMyCurrency = true
        
        struct Root: Codable {
            var data: RemoteBalanceCurrencyDetail?
            var code: String?
            var message: String?
        }
        
        struct RootData: Codable {
            
            var id: String?
            var coinAmount: Int?
            var diamondAmount: Int?
        }
        
        let endpoint: Endpoint<Root?> = Endpoint(
            path: "balance/currency/details",
            method: .get,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"]
        )
        
        DIContainer.shared.apiDataTransferService.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoadMyCurrency = false
            
            switch result {
            case .failure(let error):
                print("Error: Failed to get my coin - \(error.message)")
            case .success(let response):
                self.totalCoin.text = "\(response?.data?.coinAmount ?? 0)"
//                self.totalCoinContainerStackView.isHidden = !AUTH.isLogin()
                KKCache.common.save(integer: response?.data?.coinAmount ?? 0, key: .coin)
                KKCache.common.save(integer: response?.data?.diamondAmount ?? 0, key: .diamond)
                KKCache.common.save(integer: response?.data?.liveDiamondAmount ?? 0, key: .liveDiamondAmount)
            }
        }
    }

    @objc func handleUpdateIsFollowFromFolowingFolower(_ notification: NSNotification) {
//        if let accountId = notification.userInfo?["accountId"] as? String,
//           let isFollow = notification.userInfo?["isFollow"] as? Bool,
//           let name = notification.userInfo?["name"] as? String,
//           let photo = notification.userInfo?["photo"] as? String
//        {
//            print("accountId \(accountId) isFollow \(isFollow)")
//            donationVC.updateFeedAccountIsFollow(feedId: "", accountId: accountId, isFollow: isFollow, name: name, photo: photo)
//            homeFVC.updateFeedAccountIsFollow(feedId: "", accountId: accountId, isFollow: isFollow, name: name, photo: photo)
//            cleepsIndo.updateFeedAccountIsFollow(feedId: "", accountId: accountId, isFollow: isFollow, name: name, photo: photo)
////            cleepsChina.updateFeedAccountIsFollow(feedId: "", accountId: accountId, isFollow: isFollow, name: name, photo: photo)
//        }
    }
    
    private func showForceUpdatePopUp() {
        let timeStamp =   UserDefaults.standard.value(forKey: "UpdateVersion")
          let nowTimeStamp = Int(Date().timeIntervalSince1970)
          
          if let oldTime = timeStamp as? Int , (nowTimeStamp - oldTime < 60 * 60 * 24) {
               return
          }
           
        struct Root: Codable {
            var data: versionInfoData?
            var code: String?
            var message: String?
        }
        let bodyParamaters: [String: Any] = ["platform": "IOS"]
        let endpoint: Endpoint<Root?> = Endpoint(
            path: "versionInfo",
            method: .get,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"] ,
            queryParameters: bodyParamaters
        )
        
        DIContainer.shared.apiDataTransferService.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
              
            switch result {
            case .failure(let error):
                print("Error: Failed to get my coin - \(error.message)")
            case .success(let response):
                guard let data = response?.data else { return }
                  judgeVersion(data:data)
            }
        }
         
    }
    
    func setupUploadProgressView() {
        view.addSubview(uploadProgress)
        uploadProgress.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, paddingTop: 100, paddingLeft: 10, width: 56, height: 56)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func decideIsTiktokFromPreference(){
        if preference.lastIndex > 2 {
            setupNavbarForTab()
        }
    }
    
    func setupNavbarForTab() {
        pagingViewController.indicatorColor = .white
        pagingViewController.textColor = .whiteSmoke
        pagingViewController.selectedTextColor = .white
    }
    
    @objc func handleShowExplore() {
        showExplore?()
        (viewControllerList[safe: controllerIndex] as? IHotNewsViewController)?.pauseIfNeeded()
    }
    
    private func dropdownMenu(isExpanded: Bool, rect: HomeMenuItem.Rect) {
        self.isExpanded = isExpanded
        
        if isExpanded {
            dropdown.frames = rect.frame
            dropdown.center = pagingViewController.menuView.convert(rect.center, to: view)
            add(dropdown)
        } else {
            dropdown.removeFromParentView()
//            pagingViewController.reloadData()
        }
    }
    
    private func handleTapFollowingDropdown(isExpanded: Bool) {
        isExpandedStoryView = isExpanded
        shortcutLiveContainerStackView.isHidden = isExpandedStoryView
        
        if isExpanded {
            followingViewController.expandStoryListView()
        } else {
            followingViewController.collapseStoryListView()
        }
    }
    
    @objc func handleShowDM() {
        let isLogin = getToken() != nil
        
        guard isLogin else {
            showLogin?()
            return
        }
        
        showDirectMessage?()
    }
    
    @objc func domainError(notification: NSNotification) {
//        if let failDoamin = notification.object as? String {
//            if APIConstants.checkDomain(failDomain: failDoamin) {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//                    self.presentAlert(title: "Terjadi kesalahan", message: "Mulai ulang aplikasi untuk memperbaiki masalah koneksi", buttonTitle: "Tutup aplikasi")
//                }
//            }
//        }
    }
}

extension NewHomeController: PagingViewControllerDataSource, PagingViewControllerDelegate, PagingViewControllerSizeDelegate {
    func pagingViewController(_: PagingViewController, widthForPagingItem pagingItem: PagingItem, isSelected: Bool) -> CGFloat {
        if let item = pagingItem as? HomeMenuItem {
            let width = UILabel.textSize(font: .roboto(.bold, size: 18), text: item.title).width
            let iconWidth: CGFloat = item.icon == nil ? 0 : 16
            let total = width + iconWidth
            return total
        } else if let _ = pagingItem as? HomeMenuIconItem {
            return 24 + 12
        } else {
            return 0
        }
    }
    
    func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
        return titleControllers[index]
    }
    

    func pagingViewController(_: PagingViewController, viewControllerAt index: Int) -> UIViewController {
        return viewControllerList[index]
    }

    func numberOfViewControllers(in pagingViewController: PagingViewController) -> Int {
        return titleControllers.count
    }
    
    func pagingViewController(_ pagingViewController: PagingViewController, didScrollToItem pagingItem: PagingItem, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
        movePaging(pagingItem)
        selectPageItem(item: pagingItem)
        
        if let item = pagingItem as? HomeMenuItem {
            self.pagingViewController.maskUpdate(totalItemCount: titleControllers.count, selectedIndex: item.index)
        }
    }
    
    func pagingViewController(_: PagingViewController, willScrollToItem pagingItem: PagingItem, startingViewController: UIViewController, destinationViewController: UIViewController) {
        tabBarController?.tabBar.isUserInteractionEnabled = false
    }
    
    func pagingViewController(_ pagingViewController: PagingViewController, didSelectItem pagingItem: PagingItem) {
        if let item = pagingItem as? HomeMenuItem {
            if isExpanded && item.title != "HotRoom" {
                dropdownMenu(isExpanded: false, rect: .zero)
            }
            
            if item == selectedItem && item.title == "Feed" {
                switchFeedType()
            }
        }
        
        if let _ = pagingItem as? HomeMenuIconItem {
            if isExpanded {
                dropdownMenu(isExpanded: false, rect: .zero)
            }
        }
        selectPageItem(item: pagingItem)
    }
    
    private func selectPageItem(item: PagingItem) {
        shortcutStoryView?.isHidden = true
        if item.isEqual(to: titleControllers[0]) {
            controllerIndex = 0
            shortcutLiveContainerStackView.isHidden = isExpandedStoryView
//            handleTapFollowingDropdown(isExpanded: isExpandedStoryView)
//            if let vc = viewControllerList[0] as? HotNewsViewController {
//                self.setLastTab("DONATION")
//                vc.pause()
//            }
        } else if item.isEqual(to: titleControllers[1]) {
            //shortcutStoryView.isHidden = false
            controllerIndex = 1
            shortcutLiveContainerStackView.isHidden = isExpandedStoryView
//            handleTapFollowingDropdown(isExpanded: !isExpandedStoryView)
        } else if item.isEqual(to: titleControllers[2]) {
            //shortcutStoryView.isHidden = false
            controllerIndex = 2
            shortcutLiveContainerStackView.isHidden = isExpandedStoryView
        } else if item.isEqual(to: titleControllers[3]) {
            //shortcutStoryView.isHidden = false
            controllerIndex = 3
        }
        
        if let item = item as? HomeMenuItem {
            selectedItem = item
            if let index = indexForTitle(item.title) {
                controllerIndex = index
            }
            
            let imageFeed = item.title == "Feed" && isImageFeedSelected
            let theme: NewHomeTheme = imageFeed ? .light : .dark
            changeTheme(theme)
            TiktokCache.instance.isDark = theme == .dark
            kipasKipasView.isHidden = !imageFeed
        }
        
        updateLastTab()
        preference.lastIndex = controllerIndex
        updateDonationCartVisibility()
        tabBarController?.tabBar.isUserInteractionEnabled = true
    }
    
    func movePaging(_ pagingItem: PagingItem) {
        if AUTH.isLogin() {
            setupNavbarForTab()
        }
    }
    
    func switchFeedType() {
        isImageFeedSelected.toggle()
        
        viewControllerList.removeLast()
        viewControllerList.append(isImageFeedSelected ? imageFeedController : videoFeedController)
        pagingViewController.reloadData()
    }
}

extension NewHomeController: BaseFeedZoomDelegate {
    func zoom(started: Bool) {
        swipeGesture(enable: !started)
//        controllerIndex = 0
    }

    func swipeGesture(enable: Bool){
        for view in pagingViewController.view.subviews {
            if let subView = view as? UIScrollView {
                subView.isScrollEnabled = enable
            }
        }
    }
    
    private func updateLastTab() {
        var identifier = ["DONATION", "FOLLOWING", "HOTNEWS", "FEED"]
        if !AUTH.isLogin() {
            identifier.remove(at: 1)
        }
        setLastTab(identifier[controllerIndex])
    }
    
    private func setLastTab(_ identifierRawValue: String){
        UserDefaults.standard.set(identifierRawValue, forKey: "lastOpenedFeedCleepsView")
    }
}

extension NewHomeController: UploadDelegate {
    func addUploadProgressObserver() {
        uploadProgress.actionFinishUpload = { [weak self] in
            guard self != nil else { return }
            NotificationCenter.default.post(name: .notificationUpdateProfile, object: nil, userInfo: nil)
            NotificationCenter.default.post(name: .updateMyLatestFeed, object: nil, userInfo: nil)
        }
    }
    
    func onUploadCallBack(param: PostFeedParam) {
        uploadProgress.uploadPost(param: param) { [weak self] in
//            self?.homeFVC.uploadPostContent = true
            self?.uploadProgress.isHidden = false
        }
    }
}

extension NewHomeController: FeedCleepsViewControllerDelegate {
    
    func updateUserFollowStatus(feedId: String, accountId: String, isFollow: Bool, name: String, photo: String) {
        print("feedId \(feedId) accountId \(accountId) isFollow \(isFollow)")
//        donationVC.updateFeedAccountIsFollow(feedId: feedId, accountId: accountId, isFollow: isFollow, name: name, photo: photo)
//        homeFVC.updateFeedAccountIsFollow(feedId: feedId, accountId: accountId, isFollow: isFollow, name: name, photo: photo)
//        cleepsIndo.updateFeedAccountIsFollow(feedId: feedId, accountId: accountId, isFollow: isFollow, name: name, photo: photo)
////        cleepsChina.updateFeedAccountIsFollow(feedId: feedId, accountId: accountId, isFollow: isFollow, name: name, photo: photo)
    }
}

//extension NewHomeController: NewsPortalTabControllerDelegate {
//    func onMoveLeft() {
//        pagingViewController.select(index: 1, animated: true)
//    }
//    
//    func onMoveRight() {
//        pagingViewController.select(index: 3, animated: true)
//    }
//}

extension UIImage {
    func flipHorizontally() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        context.translateBy(x: self.size.width/2, y: self.size.height/2)
        context.scaleBy(x: -1.0, y: 1.0)
        context.translateBy(x: -self.size.width/2, y: -self.size.height/2)
        
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

private extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension NewHomeController: ShortcutStoryViewDelegate {
    
    func didSelectedMyStory(with item: FeedItem?) {
        let vc = CustomPopUpViewController(
            title: "Fitur sedang dalam proses pengembangan.",
            description: "Kami sedang menyempurnakan fitur ini, bersiaplah untuk pengalaman terbaik.",
            iconImage: UIImage(named: "img_in_progress"),
            iconHeight: 99
        )
        vc.delegate = self
        present(vc, animated: false)
    }
    
    func didSelectedStory(with item: FeedItem) {
        if(shortcutStoryView?.feeds.count ?? 0 > 0){
            if let index = shortcutStoryView?.feeds.firstIndex(where: { $0.id == item.id }) {
                presentStories(feedItems: shortcutStoryView?.feeds ?? [], selectedIndex: index)
            }
        }
    }
    
    func presentStories(feedItems: [FeedItem], selectedIndex: Int) {
        guard feedItems.count > 0 else { return }
        guard controllerIndex != 0 else { return }
        (viewControllerList[controllerIndex] as? IHotNewsViewController)?.pauseIfNeeded()
//        controllerIndex == 1 ? hotNewsViewController.pauseIfNeeded() : feedTabController.videoFeedController.pauseIfNeeded()
        let stories = toStories(feedItems: feedItems)
        let vc = StoryPreviewController(stories: stories, handPickedStoryIndex: selectedIndex)
        vc.modalPresentationStyle = .overFullScreen
        vc.handleDismiss = { [weak self] in
            guard let self = self else { return }
            (self.viewControllerList[self.controllerIndex] as? IHotNewsViewController)?.resumeIfNeeded()
//            self.feedTabController.videoFeedController.resumeIfNeeded()
//            self.controllerIndex == 1 ? self.hotNewsViewController.resumeIfNeeded() : self.feedTabController.videoFeedController.resumeIfNeeded()
        }
        self.present(vc, animated: false)
    }

    
    func toStories(feedItems: [FeedItem]) -> [StoriesItem] {
        var stories = [StoriesItem]()
        feedItems.forEach { feedItem in
            
            var typeMedia = "image"
            var urlMedia = feedItem.post?.medias?.first?.thumbnail?.medium ?? ""
            var durationMedia = 4.0
            
            if feedItem.videoUrl.hasSuffix(".mp4") || feedItem.videoUrl.hasSuffix(".m3u8")  {
                typeMedia = "video"
                urlMedia = feedItem.videoUrl
                durationMedia = Double(feedItem.duration) ?? durationMedia
            }
            
            let mediaStory = MediasStory(  id: "",
                                            url: urlMedia,
                                            type: typeMedia,
                                            thumbnail: nil,
                                            metadata: Metadata(width: "576", height: "1024", size: "100", duration: durationMedia),
                                            hlsUrl: "",
                                            isHlsReady: false)

            let storyItem = StoryItem(id: "", medias: [mediaStory], products: [], createAt: feedItem.createAt)
            
            let account = feedItem.account.map({ user in
                Profile(id: user.id, photo: user.photo, username: user.username)
            })
            var storyItems = StoriesItem(id: "", stories: [storyItem], account: account, isBadgeActive: false)
            
            stories.append(storyItems)
        }
        
        return stories
    }
    
    func indexForTitle(_ title: String) -> Int? {
        for i in 0..<titleControllers.count {
            let item = titleControllers[i]
            if let item = item as? HomeMenuItem, item.title == title {
                return i
            }
        }
        
        return nil
    }

}

// MARK: - Scroll Handler for Zoom/Following Story
private extension NewHomeController {
    /// make sure to disable scrolling before begin zooming/following story expanded
    @objc private func disableScroll(_ notification: NSNotification?) {
        guard let notification = notification else { return }
        
        if notification.name == ZoomableNotification.didZoom {
            if let view = notification.userInfo?["view"] as? ZoomableView,
               view.isDescendant(of: self.view) {
                self.view.setScrollPaging(enable: false)
            }
            return
        }
        
        if notification.name == HotNewsStoryViewNotification.didShow {
            if let view = notification.userInfo?["view"] as? HotNewsStoryView,
               view.isDescendant(of: self.view) {
                self.view.setScrollPaging(enable: false, except: view)
                self.shortcutLiveContainerStackView.isHidden = true
                self.isExpandedStoryView = true
//                self.pagingViewController.reloadData()
//                self.pagingViewController.maskUpdate(totalItemCount: titleControllers.count, selectedIndex: selectedItem?.index ?? 2)
            }
            return
        }
    }

    /// make sure to enable scrolling after stop zooming/following story collapsed
    @objc private func enableScroll(_ notification: NSNotification?) {
        guard let notification = notification else { return }
        
        if notification.name == ZoomableNotification.endZoom {
            if let view = notification.userInfo?["view"] as? ZoomableView,
               view.isDescendant(of: self.view) {
                self.view.setScrollPaging(enable: true)
            }
            return
        }
        
        if notification.name == HotNewsStoryViewNotification.didDismiss {
            if let view = notification.userInfo?["view"] as? HotNewsStoryView,
               view.isDescendant(of: self.view) {
                self.view.setScrollPaging(enable: true, except: view)
                self.shortcutLiveContainerStackView.isHidden = false
                self.isExpandedStoryView = false
                self.pagingViewController.reloadData()
//                self.pagingViewController.maskUpdate(totalItemCount: titleControllers.count, selectedIndex: selectedItem?.index ?? 2)
            }
            return
        }
    }
}

//MARK: Donation Cart
private extension NewHomeController {
    func setupDonationCart() {
        let size: CGFloat = 40

        pagingViewController.view.addSubview(donationCartCountingView)
        donationCartCountingView.anchor(top: shortcutLiveContainerStackView.bottomAnchor, right: view.rightAnchor, paddingTop: 9, paddingRight: 8, width: size, height: size)
        donationCartCountingView.layer.cornerRadius = size / 2
        loadDonationCartData()

        donationCartCountingView.onTap {
            showDonationCart?()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(updateDonationCartData), name: DonationCartManagerNotification.updated, object: nil)
    }

    @objc private func updateDonationCartData() {
        loadDonationCartData()
    }

    func loadDonationCartData() {
        donationCartCountingView.updateCount(with: DonationCartManager.instance.data.count)
        updateDonationCartVisibility()
    }

    func updateDonationCartVisibility() {
        if controllerIndex != 0 {
            donationCartCountingView.isHidden = true
            return
        }

        donationCartCountingView.updateVisibility()
    }
}

// MARK: Following Logic
extension NewHomeController {
    @objc private func updateFollowingTab() {
        if AUTH.isLogin() {
            guard !viewControllerList.contains(where: {$0 == followingViewController }) else { return }
            titleControllers.insert(HomeMenuItem(index: 1, title: String.get(.following)), at: 1)
            viewControllerList.insert(followingViewController, at: 1)
            pagingViewController.reloadData()
            pagingViewController.maskUpdate(totalItemCount: titleControllers.count, selectedIndex: selectedItem?.index ?? 2)
            
            if let index = indexForTitle(selectedItem?.title ?? "") {
                controllerIndex = index
            }
            
            return
        }
        
        
        guard viewControllerList.contains(where: {$0 == followingViewController }) else { return }
        titleControllers.remove(at: 1)
        viewControllerList.remove(at: 1)
        pagingViewController.reloadData()
        pagingViewController.maskUpdate(totalItemCount: titleControllers.count, selectedIndex: selectedItem?.index ?? 1)
        
        if let index = indexForTitle(selectedItem?.title ?? "") {
            controllerIndex = index
        }
    }
}

// MARK: - Feed Tab Delegate
//extension NewHomeController: FeedTabControllerDelegate {
extension NewHomeController {
    
    func didLoadStories(feed items: [FeedCleeps.FeedItem]) {
        shortcutStoryView?.feeds = items
    }
}

//    MARK: - updateVersion

extension NewHomeController{
    public func judgeVersion( data:versionInfoData)  {
        var type = updateType.none
        let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        var currentVersions = currentVersion.split(separator: ".").compactMap { Int($0) }
        guard var minVersion = data.minVersion, var newVersion = data.newVersion else { return }
           
        var newVersions = newVersion.split(separator: ".").compactMap { Int($0) }
        var minVersions = minVersion.split(separator: ".").compactMap { Int($0) }
        for i in 0..<3{
            currentVersions.append(0)
            newVersions.append(0)
            minVersions.append(0)
        }
         
        if newVersions[0] > currentVersions[0] ||
           (newVersions[0] == currentVersions[0] && newVersions[1] > currentVersions[1]) ||
           (newVersions[0] == currentVersions[0] && newVersions[1] == currentVersions[1] && newVersions[2] > currentVersions[2]) {
             type = updateType.option
        }else{
            return
        }
        
        if minVersions[0] > currentVersions[0] ||
           (minVersions[0] == currentVersions[0] && minVersions[1] > currentVersions[1]) ||
           (minVersions[0] == currentVersions[0] && minVersions[1] == currentVersions[1] && minVersions[2] > currentVersions[2]) {
             type = updateType.force
        }
          
//        let view = UpdateView.init(data: data,type: type.rawValue)
//        appWindow?.addSubview(view)
//        view.anchors.edges.pin()
     }
}

// MARK: - Theme
private extension NewHomeController {
    func changeTheme(_ newTheme: NewHomeTheme) {
        guard newTheme != theme else { return }
        
        theme = newTheme
        delegate?.didChangedTheme(with: newTheme)
        updateTheme()
    }
    
    func updateTheme() {
        pagingViewController.indicatorColor = theme.color.selected
        pagingViewController.textColor = theme.color.unselected
        pagingViewController.selectedTextColor = theme.color.selected
        pagingViewController.pager.tintColor = theme.color.selected
        
        if let index = titleControllers.firstIndex(where: {($0 as? HomeMenuItem)?.index == 2}) {
            titleControllers[index] = HomeMenuItem(
                themeColor: theme.color.selected,
                icon: .iconDropdownCollapsed,
                index: 2,
                title: String.get(.hotRoom),
                isExpanded: isExpanded,
                onTapDropdownMenu: { [weak self] isExpanded, rect in
                    self?.dropdownMenu(isExpanded: isExpanded, rect: rect)
                }
            )
        }
        
        pagingViewController.reloadMenu()
        
        if let image = UIImage(named: "ic_dm_white")?.withTintColor(theme.color.selected) {
            dmButton.setImage(image, for: .normal)
        }
        
        if let image =  UIImage(named: .get(.iconSearchNavigation))?.withTintColor(theme.color.selected), let flipped = image.flipHorizontally() {
            exploreButton.setImage(flipped, for: .normal)
        }
    }
}

fileprivate extension UIView {
    func selfCenterYTo(_ anchor: NSLayoutYAxisAnchor) {
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: anchor).isActive = true
    }
}

extension NewHomeController: CustomPopUpViewControllerDelegate {
    func didSelectOK() {
        NotificationCenter.default.post(name: .shouldResumePlayer, object: nil)
    }
}
