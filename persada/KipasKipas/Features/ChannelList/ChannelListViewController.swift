//
//  ChannelListViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 09/03/22.
//

import UIKit
import FeedCleeps

protocol IChannelListViewController: AnyObject {
    func displayChannels(contents: [ChannelsItemContent])
}

class ChannelListViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var refreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        view.tintColor = .primary
        view.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return view
    }()
    
    var interactor: IChannelListInteractor!
    var router: IChannelListRouter!
    private var firstLoad = true
    private var channels: [ChannelsItemContent] = []
        
	override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        fetchData()
        handleNotificationCenter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overrideUserInterfaceStyle = .light
        setupNavigationBar()
    }
    
    init(channels: [ChannelsItemContent], isFollowing: Bool) {
        super.init(nibName: nil, bundle: nil)
        ChannelListRouter.configure(self)
        bindNavigationBar(isFollowing ? "My Channel" : "Semua Channel")
//        self.channels = channels
        interactor.isFollowing = isFollowing
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func handleNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name: NSNotification.Name("handleUpdateChannelList"), object: nil)
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.layer.shadowColor   = UIColor.black.cgColor
        navigationController?.navigationBar.layer.shadowOpacity = 0.2
        navigationController?.navigationBar.layer.shadowOffset  = CGSize.zero
        navigationController?.navigationBar.layer.shadowRadius  = 2
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.refreshControl = refreshControl
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        collectionView.registerXibCell(ChannelListCollectionViewCell.self)
    }
    
    @objc private func handleRefresh() {
        refreshControl.beginRefreshing()
        interactor.page = 0
        interactor.fetchChannels()
    }
    
    private func fetchData() {
        interactor.page = channels.isEmpty ? 0 : 1
        interactor.fetchChannels()
    }
    
    private func showAuthPopUp() {
        router.showAuthPopUp()
    }
}

extension ChannelListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return channels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ChannelListCollectionViewCell.self, for: indexPath)
        cell.setupView(channel: channels[indexPath.item])
        return cell
    }
}

extension ChannelListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let channel = channels[indexPath.item]
        guard AUTH.isLogin() else {
            showAuthPopUp()
            return
        }
        let channelData = ChannelDetailData(code: channel.code, name: channel.name, id: channel.id, createAt: 0, photo: channel.photo, description: channel.description, isFollow: channel.isFollow)
        
        let vc = ChannelContentsViewController(channelId: channel.id, channel: channelData)
        vc.bindNavigationBar(channel.name)
        vc.hidesBottomBarWhenPushed = true
        vc.navigationController?.displayShadowToNavBar(status: true)
        vc.handleUnfollowChannel = { [weak self] channelId in
            guard let self = self else { return }
            guard self.interactor.isFollowing else { return }
            guard let index = self.channels.lazy.firstIndex(where: { $0.id == channelId }) else { return }
            self.channels.remove(at: index)
            DispatchQueue.main.async {
                self.collectionView.performBatchUpdates {
                    self.collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                }
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == channels.count - 1 && interactor.page < interactor.totalPages {
            interactor.loadMoreChannels()
        }
    }
}

extension ChannelListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2 - 8, height: 44)
    }
}

extension ChannelListViewController: IChannelListViewController {
    func displayChannels(contents: [ChannelsItemContent]) {
        refreshControl.endRefreshing()
        channels = interactor.page == 0 ? contents : channels + contents
        collectionView.emptyView(isEmpty: channels.count <= 0,
                                 title: .get(interactor.isFollowing ? .emptyMyChannels : .emptyChannels))
        collectionView.reloadData()
    }
}
