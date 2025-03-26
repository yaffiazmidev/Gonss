import UIKit
import KipasKipasShared
import KipasKipasDirectMessage

public struct DirectMessageChildPage {
    public let controller: ChatViewController
    public let title: String
    
    public init(controller: ChatViewController, title: String) {
        self.controller = controller
        self.title = title
    }
}

public protocol IDirectMessageContainerViewController: AnyObject {
    func loadMoreConversations()
    func clearUnreadCount(_ conversation: TXIMConversation)
    func didPaidChatUnreadCountUpdated(count: Int32)
    func addUnreadMark(conversationId: String)
    func pinConversation(conversation: TXIMConversation)
    func foldConversation(conversation: TXIMConversation)
}

public final class DirectMessageContainerViewController: UIViewController, NavigationAppearance {
    
    private var selectedMenuIndex: Int = 0
    
    private lazy var timestampStorage = TimestampStorage()
    
    private lazy var tabView: KBMenuFixedTab = {
        let tabView = KBMenuFixedTab(
            size: .init(
                width: view.bounds.width,
                height: 45
            ),
            position: view.safeAreaTop,
            defaultSelectedTabIndex: 0
        )
        tabView.delegate = self
        tabView.addItems(childPages.map {
            .init(title: $0.title)
        })
        view.addSubview(tabView)
        return tabView
    }()
    
    private let newChatButton = KKBaseButton()
    
    private let childPages: [DirectMessageChildPage]
    private let pageViewController: KKPageViewController
    private let userId: String
    private let userSig: String
        
    var interactor: DirectMessageContainerInteractor!
    var onTapNewChat: (() -> Void)?
    var onTapFoldList: ((Bool) -> Void)?
    
    public init(
        userId: String,
        userSig: String,
        childPages: [DirectMessageChildPage]
    ) {
        self.userId = userId
        self.userSig = userSig
        self.childPages = childPages
        self.pageViewController = KKPageViewController(childControllers: childPages.map { $0.controller })
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        for childPage in self.childPages {
            childPage.controller.container = self
        }
        configureUI()
        
        interactor.getTotalUnreadMessageCount()
        interactor.loadMoreConversations()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overrideUserInterfaceStyle = .light
        tabBarController?.tabBar.isHidden = true
        
        setupNavigationBarWithLargeTitle(
            title: "Percakapan",
            tintColor: .black,
            shadowColor: .clear,
            prefersLargeTitles: true,
            largeFont: .systemFont(ofSize: 34, weight: .bold)
        )
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.title = ""
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loginIM(with: userId)
    }
    
    private func loginIM(with userId: String) {
        guard userId.count > 0 && userSig.count > 0 else {
            presentAlert(title: "Error", message: "User id not found..")
            return
        }
        
        TXIMUserManger.shared.login(userId, userSig: userSig) { [weak self] result in
            switch result {
            case .success(_):
                UserManager.shared.accountId = userId
            case .failure(let error):
                self?.presentAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
}

// MARK: UI
private extension DirectMessageContainerViewController {
    func configureUI() {
        configureNewChatButton()
        configurePageMenu()
        configurePageViewController()
    }
    
    func configurePageMenu() {
        view.addSubview(tabView)
    }
    
    func configurePageViewController() {
        pageViewController.eventDelegate = self
        pageViewController.view.backgroundColor = .white
        pageViewController.view.preservesSuperviewLayoutMargins = true
        pageViewController.isDoubleSided = true
        
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        view.addSubview(pageViewController.view)
        //Cancel paid chat
//        pageViewController.view.anchors.top.spacing(0, to: tabView.anchors.bottom)
        pageViewController.view.anchors.top.pin()
        pageViewController.view.anchors.leading.pin()
        pageViewController.view.anchors.bottom.pin()
        pageViewController.view.anchors.trailing.pin()
        
        pageViewController.scrollView?.isScrollEnabled = false
    }
    
    func configureNewChatButton() {
        newChatButton.setImage(UIImage(named: "iconCreateMessage"), for: .normal)
        newChatButton.tintColor = .azure
        newChatButton.contentHorizontalAlignment = .fill
        newChatButton.contentVerticalAlignment = .fill
        newChatButton.addTarget(self, action: #selector(didTapNewChat), for: .touchUpInside)
        
        newChatButton.anchors.width.equal(28)
        newChatButton.anchors.height.equal(28)
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: newChatButton)]
    }
    
    @objc func didTapNewChat() {
        onTapNewChat?()
    }
}

extension DirectMessageContainerViewController: KBTabViewDelegate {
    public func didSelectTabView(_ item: any KBTabViewItemable, at indexPath: IndexPath) {
        let index = indexPath.item
        let shouldForward =  indexPath.item > self.selectedMenuIndex
        self.pageViewController.scrollTo(index: index, direction: shouldForward ? .forward : .reverse)
        self.selectedMenuIndex = index
    }
    
    public func shouldSelectTabView(_ item: any KBTabViewItemable, at indexPath: IndexPath) -> Bool {
        return true
    }
}

extension DirectMessageContainerViewController: KKPageViewControllerEventDelegate {
    public func pageViewController(willMoveTo childController: UIViewController?, from previousController: UIViewController?) {}
    
    public func pageViewController(didMoveTo childController: UIViewController, currentIndex: Int, from previousController: UIViewController?) {
        tabView.selectItem(at: currentIndex)
    }
}

extension DirectMessageContainerViewController: DirectMessageContainerInteractorDelegate {
    public func lockConversationSuccess(isSucess: Bool, message: String) {
        KKDefaultLoading.shared.hide()
        self.dismiss(animated: true)
        if(!isSucess){
            presentAlert(title: "Error", message: message)
        }
    }
    
    public func directMessageInteractor(didTotalUnreadMessageCountChanged totalUnreadCount: UInt64) {
        let item = KBTabViewItem(title: childPages[0].title, badgeValue: String(totalUnreadCount))
        tabView.replaceItem(with: item, at: 0)
    }
    
    public func directMessageInteractor(didConversationUpdate conversations: [TXIMConversation]) {
        for childPage in self.childPages {
            childPage.controller.didConversationsUpdate(conversations)
        }
    }
    
    public func directMessageInteractor(didReceiveError error: Error) {
        presentAlert(title: "Error", message: error.localizedDescription)
    }
}

extension DirectMessageContainerViewController: IDirectMessageContainerViewController {
    public func loadMoreConversations() {
        interactor.loadMoreConversations()
    }
    
    public func clearUnreadCount(_ conversation: TXIMConversation) {
        interactor.clearUnreadCount(conversation)
    }
    
    public func didPaidChatUnreadCountUpdated(count: Int32) {
        let item = KBTabViewItem(title: childPages[1].title, badgeValue: String(count))
        tabView.replaceItem(with: item, at: 1)
    }
    
    public func didDeleteConversations( _ convIds:[String]) {
        interactor.deleteConversations(convIds)
    }
    
    public func addUnreadMark(conversationId: String) {
        interactor.addUnreadMark(conversationId: conversationId)
    }
    
    public func pinConversation(conversation: TXIMConversation) {
        interactor.pinConversation(conversation: conversation)
    }
    
    public func foldConversation(conversation: TXIMConversation) {
        interactor.foldConversation(conversation: conversation)
    }
    
    public func didMoreHandleConversation(conversation: TXIMConversation) {
//        interactor.pinConversation(conversation: conversation)
    }
    
    public func didNavToFoldList(isPaidOnly:Bool){ 
        onTapFoldList?(isPaidOnly)
    }
    
    
    public func didDefriend(with conversation: TXIMConversation, report:Bool ){
        interactor.defriend(with: conversation, report: report)
        KKDefaultLoading.shared.show(message: "Memblokir...")
    }
    
    public func didRemoveDefriend(conversation: TXIMConversation){
        interactor.removeDefriend(conversation: conversation)
        KKDefaultLoading.shared.show(message: "Membuka blokir...")
    }
    
    
}
