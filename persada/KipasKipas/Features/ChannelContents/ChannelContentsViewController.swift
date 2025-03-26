//
//  ChannelContentsViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 07/09/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit
import RxSwift

protocol IChannelContentsViewController: AnyObject {
    func displayContents(feeds: [Feed])
    func displayChannelDetail(channel: ChannelDetailData?)
    func displayUnfollowStatus(isSuccess: Bool)
    func displayFollowStatus(isSuccess: Bool)
}

class ChannelContentsViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var followButton: PrimaryButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var router: IChannelContentsRouter!
    var interactor: IChannelContentsInteractor!
    
    private lazy var refreshControl = UIRefreshControl()
    
    private var deletedIds: [String] = []
    private var feeds: [Feed] = []
    private var channel: ChannelDetailData? {
        didSet {
            let isFollow = channel?.isFollow ?? false
            followButton.backgroundColor = isFollow ? .gainsboro : .primary
            followButton.setTitleColor(isFollow ? .contentGrey : .white, for: .normal)
            followButton.setTitle(isFollow ? "Following" : "Follow", for: .normal)
            descriptionLabel.text = channel?.description ?? ""
        }
    }
    private let disposeBag = DisposeBag()
    var handleUnfollowChannel: ((String) -> Void)?
    var isFollow = false
    
    init(channelId: String, channel: ChannelDetailData? = nil) {
        super.init(nibName: nil, bundle: nil)
        ChannelContentsRouter.configure(self)
        interactor.channelId = channel?.id ?? ""
        isFollow = channel?.isFollow ?? false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        followButton.setup(color: .clear, font: .Roboto(.medium, size: 10), activityColor: .white)
        setupCollectionView()
        interactor.fetchContents()
        interactor.fetchChannelDetail()
        enableNavigationBackGesture()
        configureNotificationObservers()
        
        followButton.rx.tap.debounce(.milliseconds(500), scheduler: MainScheduler.instance).bind {
            if self.isFollow == true {
                self.interactor.unfollowChannel()
            } else {
                self.interactor.followChannel()
            }
        }.disposed(by: disposeBag)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if !isFollow {
            handleUnfollowChannel?(interactor.channelId)
        }
    }
    
    private func enableNavigationBackGesture() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCollectionView() {
        refreshControl.tintColor = .primary
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.refreshControl = refreshControl
        collectionView.registerCustomCell(ChannelContentsCollectionViewCell.self)
//        collectionView.register(UINib(nibName: "ChannelContentsHeaderCollectionReusableView", bundle: nil),
//                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
//                                withReuseIdentifier: "ChannelContentsHeaderCollectionReusableView")
        
        setupPinterestLayout()
    }
    
    private func configureNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeleteExploreContent), name: .init("exploreDeleteContent"), object: nil)
    }
    
    @objc private func handleDeleteExploreContent(_ notification: Notification) {
        if let id = notification.object as? String {
            deletedIds.append(id)
            
            feeds.removeAll(where: { $0.post?.id == id })
            collectionView.emptyView(isEmpty: self.feeds.isEmpty, title: "Post tidak tersedia")
            collectionView.reloadData()
        }
    }
    
    @objc private func pullToRefresh() {
        interactor.page = 0
        interactor.totalPage = 0
        feeds = []
        channel = nil
        collectionView.reloadData()
        
        interactor.fetchContents()
        interactor.fetchChannelDetail()
    }
    
    private func setupPinterestLayout() {
        let layout = DENCollectionViewLayout()
        layout.minimumColumnSpacing = 5.0
        layout.minimumInteritemSpacing = 5.0
        layout.columnCount = 3
//        layout.headerHeight = 110
        collectionView.alwaysBounceVertical = true
        collectionView.collectionViewLayout = layout
    }
    @IBAction func didClickFollowButton(_ sender: Any) {
        followButton.setTitle("", for: .normal)
        followButton.showLoading()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ChannelContentsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feeds.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCustomCell(with: ChannelContentsCollectionViewCell.self, indexPath: indexPath)
        
        let post = feeds[indexPath.item].post
        let media = post?.medias?.first
        let containingProduct = post?.product != nil
        let isMultiple = post?.medias?.count ?? 0 > 1
        let isVideo = media?.type == "video"
        let type: PostMediaType = containingProduct ? .product : isMultiple ? .multiple : isVideo ? .video : .image
        
        //cell.itemImageView.loadImage(at: media?.thumbnail?.small ?? "")
        cell.itemImageView.loadImage(at: media?.thumbnail?.small ?? "", .w240, emptyImageName: "bg_tiktok")
        cell.contentIcon.image = type.icon
        return cell
    }
}

extension ChannelContentsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        var vc = FeedFactory.createFeedChannelContentsController(feed: feeds, showBottomCommentSectionView: true, channelId: interactor.channelId)
//
//        if !feeds.isEmpty {
//            let feedsFrom = Array(feeds.suffix(from: indexPath.item))
//            vc = FeedFactory.createFeedChannelContentsController(feed: feedsFrom, showBottomCommentSectionView: true, channelId: interactor.channelId)
//        }
//        
//        vc.bindNavigationBar("", true, icon: .get(.arrowLeftWhite))
//        vc.hidesBottomBarWhenPushed = true
//        navigationController?.displayShadowToNavBar(status: false)
//        navigationController?.pushViewController(vc, animated: false)
        
        let item = feeds[indexPath.row]
        let feedId = item.id ?? ""
        router.navigateToDetailContent(
            by: feedId,
            channelId: interactor.channelId, 
            currentPage: interactor.page,
            totalPage: interactor.totalPage,
            contents: feeds,
            account: item.account
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == feeds.count - 1 && !interactor.isLastPage {
            interactor.loadMoreContents()
        }
    }
}

extension ChannelContentsViewController: DENCollectionViewDelegateLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = feeds[indexPath.item]
        let media = item.post?.medias?.first
        let metadata = media?.metadata
        let heightImage = Double(metadata?.height ?? "") ?? 1028
        let widthImage = Double(metadata?.width ?? "") ?? 1028
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
        return UIEdgeInsets(horizontal: 16, vertical: 0)
    }
}

extension ChannelContentsViewController: IChannelContentsViewController {
    func displayContents(feeds: [Feed]) {
        interactor.prefetchImages(feeds)
        
        var feeds = feeds
        
        feeds.removeAll(where: {
            if let id = $0.post?.id {
                return deletedIds.contains(id)
            } else {
                return false
            }
        })
        
        self.feeds = interactor.page == 0 ? feeds : self.feeds + feeds
        collectionView.emptyView(isEmpty: self.feeds.isEmpty, title: "Post tidak tersedia")
        collectionView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func displayChannelDetail(channel: ChannelDetailData?) {
        self.channel = channel
        isFollow = channel?.isFollow ?? false
        refreshControl.endRefreshing()
    }
    
    func displayUnfollowStatus(isSuccess: Bool) {
        followButton.hideLoading()
        followButton.setTitle(!isSuccess ? "Following" : "Follow", for: .normal)
        if isSuccess {
            isFollow = false
        }
        
        followButton.backgroundColor = isFollow ? .gainsboro : .primary
        followButton.setTitleColor(isFollow ? .contentGrey : .white, for: .normal)
    }
    func displayFollowStatus(isSuccess: Bool) {
        followButton.hideLoading()
        followButton.setTitle(isSuccess ? "Following" : "Follow", for: .normal)
        
        if isSuccess {
            isFollow = true
        }
        
        followButton.backgroundColor = isFollow ? .gainsboro : .primary
        followButton.setTitleColor(isFollow ? .contentGrey : .white, for: .normal)
    }
}

//extension ChannelContentsViewController {
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        switch kind {
//        case UICollectionView.elementKindSectionHeader:
//            guard let headerView = collectionView.dequeueReusableSupplementaryView(
//                ofKind: UICollectionView.elementKindSectionHeader,
//                withReuseIdentifier: "ChannelContentsHeaderCollectionReusableView",
//                for: indexPath) as? ChannelContentsHeaderCollectionReusableView
//            else {
//                return UICollectionReusableView()
//            }
//            headerView.followButton.isHidden = channel == nil
//            headerView.channelDescriptionLabel.text = channel?.description ?? ""
//            headerView.setupFollowingButtonStatus(isFollow: channel?.isFollow ?? false)
//            headerView.followButton.onTap { [weak self] in
//                guard let self = self else { return }
//
//                if self.isFollow == true {
//                    self.interactor.unfollowChannel()
//                } else {
//                    self.interactor.followChannel()
//                }
//                headerView.setupFollowingButtonStatus(isFollow: self.isFollow)
//            }
//            return headerView
//        default:
//            assert(false, "Unexpected element kind")
//        }
//    }
//}
