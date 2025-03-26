//
//  ExploreViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 06/03/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit
import KipasKipasShared

protocol IExploreViewController: AnyObject {
    func displayChannels(channels: [ChannelsItemContent])
    func displayExplorePosts(contents: [ExploreModel.Post], feeds: [Feed])
}

class ExploreViewController: UIViewController, NavigationAppearance {

    @IBOutlet weak var myChannelLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navigationBarContainerView: UIView!
    @IBOutlet weak var searchBar: UITextField!
    
    private var deletedIds: [String] = []
    
    lazy var refreshControll: UIRefreshControl = {
        let view = UIRefreshControl()
        view.tintColor = .primary
        view.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return view
    }()
    
    var interactor: IExploreInteractor!
    var router: IExploreRouter!
    var feeds: [Feed] = []
    var channels: [ChannelsItemContent] = []
    var explorePosts: [ExploreModel.Post] = [] {
        didSet {
            if explorePosts.isEmpty {
                interactor.page = 0
                interactor.totalPage = 0
                collectionView.reloadData()
            }
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        ExploreRouter.configure(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        interactor.fetchChannels()
        interactor.fetchExplorePosts()
        handleOnTap()
        handleNotificationCenter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(color: .white, tintColor: .contentGrey, shadowColor: .clear, backIndicator: .iconChevronLeft)
        navigationBarContainerView.isHidden = !AUTH.isLogin()
        overrideUserInterfaceStyle = .light
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func handleNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateExploreContent), name: .handleUpdateExploreContent, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeleteExploreContent), name: .init("exploreDeleteContent"), object: nil)
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.refreshControl = refreshControll
        collectionView.contentInset = UIEdgeInsets(top: !AUTH.isLogin() ? 0 : 68, left: 0, bottom: 0, right: 0)
        collectionView.registerCustomCell(ExploreItemCollectionViewCell.self)
        collectionView.registerReusableViewXib(ExploreHeaderCollectionReusableView.self,
                                               kind: UICollectionView.elementKindSectionHeader)
        setupPinterestLayout()
    }
    
    private func setupPinterestLayout() {
        let layout = DENCollectionViewLayout()
        layout.minimumColumnSpacing = 5.0
        layout.minimumInteritemSpacing = 5.0
        layout.columnCount = 3
        layout.headerHeight = 180
        collectionView.alwaysBounceVertical = true
        collectionView.collectionViewLayout = layout
    }
    
    private func handleOnTap() {
        myChannelLabel.onTap { [weak self] in
            guard let self = self else { return }
            self.router.navigateToChannelList(isFollowing: true, channels: self.channels)
        }
        
        searchBar.onTap { [weak self] in
            guard let self = self else { return }
            self.router.navigateToChannelSearch()
        }
    }
    
    @objc private func handleUpdateExploreContent() {
        explorePosts = []
        feeds = []
        collectionView.reloadData()
        interactor.fetchExplorePosts()
    }
    
    @objc private func handleDeleteExploreContent(_ notification: Notification) {
        if let id = notification.object as? String {
            deletedIds.append(id)
            
            explorePosts.removeAll(where: { $0.feedId == id })
            explorePosts.removeAll(where: { $0.id == id })
            feeds.removeAll(where: { $0.id == id })
            collectionView.reloadData()
        }
    }
    
    @objc private func handleRefresh() {
        interactor.page = 0
        interactor.totalPage = 0
        channels = []
        handleUpdateExploreContent()
        interactor.fetchChannels()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ExploreViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return explorePosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCustomCell(with: ExploreItemCollectionViewCell.self, indexPath: indexPath)
        let item = explorePosts[indexPath.item]
        //cell.itemImageView.loadImage(at: item.url)
        cell.itemImageView.loadImage(at: item.url, .w240, emptyImageName: "bg_tiktok")
        
        cell.contentIcon.image = item.type.icon
        return cell
    }
}

extension ExploreViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = feeds[indexPath.row]
        let feedId = item.id ?? ""
        router.navigateToDetailContent(
            by: feedId,
            currentPage: interactor.page,
            totalPage: interactor.totalPage,
            contents: feeds,
            account: item.account
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == explorePosts.count - 1 && interactor.page < interactor.totalPage {
            interactor.loadMoreExplorePosts()
        }
    }
}

extension ExploreViewController: DENCollectionViewDelegateLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader: return makeExploreHeaderView(indexPath: indexPath)
        default: assert(false, "Unexpected element kind")
        }
    }
    
    private func makeExploreHeaderView(indexPath: IndexPath) -> ExploreHeaderCollectionReusableView {
        let headerView = collectionView.dequeueReusableView(ExploreHeaderCollectionReusableView.self, kind: UICollectionView.elementKindSectionHeader, for: indexPath)
        let channelsWithLimit: [ChannelsItemContent] = Array(channels.prefix(4))
        headerView.channels = channelsWithLimit
        headerView.delegate = self
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = explorePosts[indexPath.item]
        let heightImage = Double(item.height) ?? 1028
        let widthImage = Double(item.width) ?? 1028
        let width = self.collectionView.frame.size.width
        let scaler = width / widthImage
        let percent = Double((10 - ((indexPath.row % 4) + 1))) / 10
        var height = heightImage * scaler
        if height > 500 {
            height = 500
        }
        
        height = (height * percent) + 100
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsFor section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
}

extension ExploreViewController: ExploreHeaderDelegate {
    func didClickRecomChannelWith(index: Int) {
        router.navigateToChannelContents(channel: channels[index])
    }
    
    func didClickSeeMoreChannel() {
        router.navigateToChannelList(isFollowing: false, channels: channels)
    }
    
    func showAuthPopUp() {
        router.showAuthPopUp()
    }
}

extension ExploreViewController: IExploreViewController {
    func displayChannels(channels: [ChannelsItemContent]) {
        self.channels = channels
        collectionView.reloadData()
        refreshControll.endRefreshing()
    }
    
    func displayExplorePosts(contents: [ExploreModel.Post], feeds: [Feed]) {
        // prevent show duplicate data from Backend from different Page
        var contents = contents
        var feeds = feeds
        
        contents.removeAll(where: { deletedIds.contains($0.id) })
        feeds.removeAll(where: {
            if let id = $0.post?.id {
                return deletedIds.contains(id)
            } else {
                return false
            }
        })
        
        contents.forEach { newContent in
            if(!explorePosts.contains(where: { $0.url == newContent.url })){
                explorePosts.append(newContent)
            }
        }
        
        //explorePosts.append(contentsOf: contents)
        interactor.prefetchImages(feeds)
        
        feeds.forEach { newFeed in
            if(!self.feeds.contains(where: { $0.id == newFeed.id })){
                self.feeds.append(newFeed)
            }
        }
        //self.feeds.append(contentsOf: feeds)
        
        collectionView.reloadData()
        refreshControll.endRefreshing()
    }
}

extension ExploreViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
