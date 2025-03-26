import UIKit
import KipasKipasShared
import FeedCleeps
import KipasKipasShared

protocol FeedTabControllerDelegate {
    func didScroll(to index: Int)
    func didLoadCurrency()
    func didLoadStories(feed items: [FeedItem])
}

class FeedTabController: UIViewController {
    
    var pagingViewController = NavigationBarPagingViewController()
    var controllerIndex = 0
    var delegate: FeedTabControllerDelegate?
    
    private lazy var titleControllers: [PagingItem] = [
        HomeMenuItem(index: 0, title: String.get(.feed)),
        HomeMenuItem(index: 1, title: String.get(.feed))
    ]
    
    lazy var kipasKipasView: UIImageView = {
        let view = UIImageView(image: UIImage(named: .get(.iconTaglineKipasKipas)))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let imageFeedController = HotNewsFactory.create(by: .feed, profileId: getIdUser(), mediaType: .image)
    let videoFeedController = HotNewsFactory.create(by: .feed, profileId: getIdUser(), mediaType: .video)
    
    var viewControllerList: [UIViewController] = []
    
    var imageFeeds: [FeedItem] = []
    var videoFeeds: [FeedItem] = []
    
    public var selectedViewController: UIViewController? {
        return viewControllerList[safe: controllerIndex]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllerList = [
            videoFeedController,
            imageFeedController
        ]
        
        pagingViewController = NavigationBarPagingViewController(viewControllers: viewControllerList)
        pagingViewController.register(HomeMenucell.self, for: HomeMenuItem.self)
        pagingViewController.register(HomeMenucell.self, for: HomeMenuIconItem.self)
        pagingViewController.borderOptions = .hidden
        pagingViewController.menuBackgroundColor = .clear
        pagingViewController.indicatorColor = .white
        pagingViewController.textColor = .whiteSmoke
        pagingViewController.selectedTextColor = .white
        pagingViewController.backgroundColor = .clear
        pagingViewController.menuHorizontalAlignment = .center
        pagingViewController.collectionView.isScrollEnabled = false
        pagingViewController.delegate = self
        pagingViewController.dataSource = self
        pagingViewController.sizeDelegate = self
        pagingViewController.menuItemSpacing = 4
        
        addChild(pagingViewController)
        view.addSubview(pagingViewController.view)
        pagingViewController.view.fillSuperview()
        pagingViewController.didMove(toParent: self)

        view.addSubview(pagingViewController.collectionView)
        pagingViewController.collectionView.anchor(left: view.leftAnchor, right: view.rightAnchor)
        pagingViewController.collectionView.selfCenterYTo(view.centerYAnchor)
        
        pagingViewController.reloadData()
        
        imageFeedController.view.addSubview(kipasKipasView)
        kipasKipasView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: imageFeedController.view.leftAnchor, paddingTop: 7, paddingLeft: 16, width: 176, height: 46)
        
        imageFeedController.handleLoadMyCurrency = { [weak self] in
            self?.delegate?.didLoadCurrency()
        }
        
        videoFeedController.handleLoadMyCurrency = { [weak self] in
            self?.delegate?.didLoadCurrency()
        }
        
        imageFeedController.handleGetFeedForStories = { [weak self] feeds in
            guard let self = self else { return }
            self.imageFeeds = feeds
            self.delegate?.didLoadStories(feed: self.imageFeeds)
        }
        
        videoFeedController.handleGetFeedForStories = { [weak self] feeds in
            guard let self = self else { return }
            self.videoFeeds = feeds
            self.delegate?.didLoadStories(feed: self.videoFeeds)
        }
        
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
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}

extension FeedTabController: PagingViewControllerDataSource, PagingViewControllerDelegate, PagingViewControllerSizeDelegate {
    func pagingViewController(_: PagingViewController, widthForPagingItem pagingItem: PagingItem, isSelected: Bool) -> CGFloat {
        if let item = pagingItem as? HomeMenuItem {
            let width = UILabel.textSize(font: .roboto(.bold, size: 18), text: item.title).width
            let iconWidth: CGFloat = item.icon == nil ? 0 : 28
            
            return width + iconWidth
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
        selectPageItem(item: pagingItem)
    }
    
    func pagingViewController(_ pagingViewController: PagingViewController, didSelectItem pagingItem: PagingItem) {
        selectPageItem(item: pagingItem)
    }
    
    private func selectPageItem(item: PagingItem) {
        for i in 0..<titleControllers.count {
            if item.isEqual(to: titleControllers[i]) {
                controllerIndex = i
                if controllerIndex == 0 {
                    delegate?.didLoadStories(feed: imageFeeds)
                } else {
                    delegate?.didLoadStories(feed: videoFeeds)
                }
                break
            }
        }
        
        delegate?.didScroll(to: controllerIndex)
    }
}

// MARK: - Scroll Handler for Zoom
private extension FeedTabController {
    /// make sure to disable scrolling before begin zooming
    @objc private func disableScroll(_ notification: NSNotification?) {
        if let userInfo = notification?.userInfo,
           let view = userInfo["view"] as? ZoomableView,
           view.isDescendant(of: self.view) {
            self.view.setScrollPaging(enable: false)
        }
    }
    
    /// make sure to enable scrolling after stop zooming
    @objc private func enableScroll(_ notification: NSNotification?) {
        if let userInfo = notification?.userInfo,
           let view = userInfo["view"] as? ZoomableView,
           view.isDescendant(of: self.view) {
            self.view.setScrollPaging(enable: true)
        }
    }
}

private extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

fileprivate extension UIView {
    func selfCenterYTo(_ anchor: NSLayoutYAxisAnchor) {
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: anchor).isActive = true
    }
}
