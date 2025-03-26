//
//  HashtagViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 19/08/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import FeedCleeps

protocol IHashtagViewController: AnyObject {
    func displayHashtags(hashtags: [HashtagItem], feeds: [Feed])
}

class HashtagViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var interactor: IHashtagInteractor!
    var router: IHashtagRouter!
    var presenter: HashtagPresenter!
    
    var isFromProfile: Bool = false
    var hashtags: [HashtagItem] = []
    private var feeds: [Feed] = []
    
    private lazy var refreshControl = UIRefreshControl()
    
    private var deletedIds: [String] = []
    
    private let identifier: TiktokType
    private var hashtag = ""
    private let selectedFeedId: String
    
    var handleUpdateSelectedFeed: ((Feed) -> Void)?
    
    init(hashtag: String, selectedFeedId: String = "") {
        identifier = .hashtag(tag: hashtag)
        self.selectedFeedId = selectedFeedId
        super.init(nibName: nil, bundle: nil)
        HashtagRouter.configure(self)
        interactor.hashtag = hashtag.lowercased()
        self.hashtag = hashtag
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.identifier = identifier
        setupViews()
        setupCollectionView()
        interactor.fetchHashtags()
        configureNotificationObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let index = feeds.firstIndex(where: { $0.id == selectedFeedId }) {
            handleUpdateSelectedFeed?(feeds[index])
        }
    }
    
    private func setupViews() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        bindNavigationBar("#\(interactor.hashtag ?? "")", icon: .get(.arrowleft))
        view.backgroundColor = .white
    }
    
    private func setupCollectionView() {
        refreshControl.tintColor = .primary
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        
        collectionView.refreshControl = refreshControl
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.registerCustomCell(HashtagCollectionViewCell.self)
        setupPinterestLayout()
    }
    
    @objc private func pullToRefresh() {
        interactor.page = 0
        interactor.totalPage = 0
        hashtags = []
        collectionView.reloadData()
        
        interactor.fetchHashtags()
    }
    
    private func configureNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeleteExploreContent), name: .init("exploreDeleteContent"), object: nil)
    }
    
    @objc private func handleDeleteExploreContent(_ notification: Notification) {
        if let id = notification.object as? String {
            deletedIds.append(id)
    
            hashtags.removeAll(where: { $0.id == id })
            collectionView.emptyView(isEmpty: self.hashtags.isEmpty, title: "Post tidak tersedia")
            collectionView.reloadData()
        }
    }
    
    private func setupPinterestLayout() {
        let layout = DENCollectionViewLayout()
        layout.minimumColumnSpacing = 5.0
        layout.minimumInteritemSpacing = 5.0
        layout.columnCount = 3
        collectionView.alwaysBounceVertical = true
        collectionView.collectionViewLayout = layout
    }
}

extension HashtagViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hashtags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCustomCell(with: HashtagCollectionViewCell.self, indexPath: indexPath)
        let item = hashtags[indexPath.item]
        cell.itemImageView.loadImage(at: item.thumbnailUrl ?? "")
        cell.contentIcon.image = item.type.icon
        return cell
    }
}

extension HashtagViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = FeedFactory.createHashtagController(
            hashtag: hashtag,
            requestedPage: interactor.page + 1,
            totalPage: interactor.totalPage,
            feed: [],
            type: identifier,
            showBottomCommentSectionView: true,
            onClickLike: { [weak self] feed in
                guard let self = self else {
                    return
                }
                self.feeds[indexPath.row] = feed
                self.collectionView.reloadItems(
                    at: [IndexPath(
                        row: indexPath.row,
                        section: 0
                    )]
                )
            },
            onClickComment: { [weak self] index, count in
                guard let self = self else { return }
                self.feeds[indexPath.row].comments = count
                self.collectionView.reloadItems(at: [IndexPath(row: indexPath.row, section: 0)])
            },
            isProfile: isFromProfile
        )

        feeds.forEach { kipasFeed in
            let feed = FeedItemMapper.map(feed: kipasFeed)
            vc.setupItems(feed: feed)
        }
        vc.bindNavigationBar("", true, icon: .get(.arrowLeftWhite))
        vc.hidesBottomBarWhenPushed = true
        vc.showFromStartIndex(startIndex: indexPath.row)
        navigationController?.displayShadowToNavBar(status: false)
        navigationController?.pushViewController(vc, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == hashtags.count - 1 && interactor.page < interactor.totalPage {
            interactor.page += 1
            interactor.fetchHashtags()
        }
    }
}

extension HashtagViewController: DENCollectionViewDelegateLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = hashtags[indexPath.item]
        let heightImage = item.thumbnailHeight ?? 1028
        let widthImage = item.thumbnailWidth ?? 1028
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
        return UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
    }
}

extension HashtagViewController: IHashtagViewController {
    
    func displayHashtags(hashtags: [HashtagItem], feeds: [Feed]) {
        interactor.prefetchImages(feeds)
        
        var feeds = feeds
        feeds.removeAll(where: {
            if let id = $0.post?.id {
                return deletedIds.contains(id)
            } else {
                return false
            }
        })
        
        DispatchQueue.main.async {
            self.loadingIndicator.stopAnimating()
            guard !hashtags.isEmpty, !feeds.isEmpty else {
                self.collectionView.emptyView(isEmpty: true, title: "Post tidak tersedia")
                return
            }
            
            self.collectionView.emptyView(isEmpty: false)
            self.hashtags.append(contentsOf: hashtags)
            self.feeds.append(contentsOf: feeds)
            self.collectionView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
}
