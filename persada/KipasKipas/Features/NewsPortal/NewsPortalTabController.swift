import UIKit
import KipasKipasShared

protocol NewsPortalTabControllerDelegate {
    func onMoveLeft()
    func onMoveRight()
}

class NewsPortalTabController: UIViewController {
    
    var delegate: NewsPortalTabControllerDelegate?
    
    var pagingViewController = NavigationBarPagingViewController()
    var controllerIndex = 0
    
    var isSelected = false
    
    private lazy var titleControllers: [PagingItem] = []
    
    private lazy var leftButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "arrowLeftGrey")!)
        button.setBackgroundColor(.white, forState: .normal)
        button.clipsToBounds = true
        button.addShadow(shadowColor: .black, offSet: CGSize(width: 0, height: 5), opacity: 0.10, shadowRadius: 8, cornerRadius: 8, corners: .topRight, fillColor: .whiteSnow)
        button.layer.cornerRadius = 16
        button.layer.borderColor = UIColor.placeholder.cgColor
        button.layer.borderWidth = 1
        return button
    }()
    
    private lazy var rightButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "arrowRightGrey")!)
        button.setBackgroundColor(.white, forState: .normal)
        button.addShadow(shadowColor: .black, offSet: CGSize(width: 0, height: 5), opacity: 0.10, shadowRadius: 8, cornerRadius: 8, corners: .topRight, fillColor: .whiteSnow)
        button.clipsToBounds = true
        button.layer.cornerRadius = 16
        button.layer.borderColor = UIColor.placeholder.cgColor
        button.layer.borderWidth = 1
        return button
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "iconSearchBlue")!)
        button.setBackgroundColor(.white, forState: .normal)
        button.addShadow(shadowColor: .black, offSet: CGSize(width: 0, height: 5), opacity: 0.10, shadowRadius: 8, cornerRadius: 8, corners: .topRight, fillColor: .whiteSnow)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.layer.borderColor = UIColor.placeholder.cgColor
        button.layer.borderWidth = 1
        return button
    }()
    
    var viewControllerList: [UIViewController] = []
    let newsPortalMenuController = NewsPortalMenuRouter.create()
    var quickAccessItems: [NewsPortalItem] = []
    
    public var selectedViewController: UIViewController? {
        return viewControllerList[safe: controllerIndex]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupControllers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newsPortalMenuController.showTitle = false
        setupControllers()
        
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
        pagingViewController.collectionView.centerYTo(view.centerYAnchor)
        setupButton()
    }
    
    func setupButton() {
        view.addSubview(leftButton)
        view.addSubview(rightButton)
        view.addSubview(searchButton)
        
        leftButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingLeft: 20, paddingBottom: 20, width: 32, height: 32)
        rightButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 20, paddingRight: 20, width: 32, height: 32)
        
        searchButton.anchor(bottom: rightButton.topAnchor, right: view.rightAnchor, paddingBottom: 20, paddingRight: 20, width: 40, height: 40)
        
        leftButton.onTap(action: delegate?.onMoveLeft)
        rightButton.onTap(action: delegate?.onMoveRight)
        searchButton.onTap {
            let vc = NewsPortalMenuRouter.create()
            vc.onDismiss = { [weak self] in
                guard let self = self else { return }
                self.setupControllers()
            }
            
            self.present(vc, animated: true)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func setupNavbarForTab() {
        pagingViewController.indicatorColor = .white
        pagingViewController.textColor = .whiteSmoke
        pagingViewController.selectedTextColor = .white
    }
}

private extension NewsPortalTabController {
    private func setupControllers() {
//        var items: [NewsPortalItem] = []
//        let dataCache = KKCache.common.readData(key: .newsPortalQuickAccess)
//        if let dataCache = dataCache,
//           let cache = try? JSONDecoder().decode(NewsPortalData.self, from: dataCache) {
//            items = cache.content
//        } else {
//            let data = NewsPortalMenuData.create()
//            data.forEach { data in
//                if data.categoryId != "quickAccess" {
//                    data.data.forEach { item in
//                        if item.defaultQuickAccess {
//                            items.append(item)
//                        }
//                    }
//                }
//            }
//        }
//        
//        guard isChanged(newItems: items) else { return }
//        
//        quickAccessItems = items
//        titleControllers = []
//        viewControllerList = []
//        
//        for (index, item) in items.enumerated() {
//            if let url = URL(string: item.url) {
//                titleControllers.append(HomeMenuItem(index: index, title: "\(index + 1)"))
//                viewControllerList.append(NewsPortalWebViewController(url: url))
//            }
//        }
//        
//        let empty = titleControllers.isEmpty || viewControllerList.isEmpty
//        
//        leftButton.isHidden = empty
//        rightButton.isHidden = empty
//        searchButton.isHidden = empty
//        
//        if empty {
//            titleControllers.append(HomeMenuItem(index: 0, title: "Menu"))
//            viewControllerList.append(newsPortalMenuController)
//        }
//        
//        pagingViewController.reloadData()
    }
    
    private func isChanged(newItems: [NewsPortalItem]) -> Bool {
        if quickAccessItems.count != newItems.count {
            return true
        }
        
        var changed = false
        for item in newItems {
            if !quickAccessItems.contains(where: { $0.id == item.id }){
                changed = true
                break
            }
        }
        
        return changed
    }
}

extension NewsPortalTabController: PagingViewControllerDataSource, PagingViewControllerDelegate, PagingViewControllerSizeDelegate {
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
        movePaging(pagingItem)
    }
    
    func pagingViewController(_ pagingViewController: PagingViewController, didSelectItem pagingItem: PagingItem) {
    }
    
    func movePaging(_ pagingItem: PagingItem) {
    }
}

private extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
