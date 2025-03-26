//
//  HotNewsViewController.swift
//  KKTUIPlayerApp
//
//  Created by DENAZMI on 24/09/23.
//

import UIKit
import TUIPlayerCore
import TUIPlayerShortVideo

public enum FeedType {
    case donation
    case hotNews
    case feed
}

extension FeedType {
    var viewCell: TUIPlayerShortVideoControl.Type {
        switch self {
        case .donation:
            return DonationViewCell.self
        case .hotNews:
            return HotNewsViewCell.self
        case .feed:
            return HotNewsViewCell.self
        }
    }
}

class HotNewsViewController: UIViewController {
    
    private lazy var mainView: HotNewsView = {
        let view = HotNewsView()
        view.tuiView.delegate = view
        view.delegate = self
        return view
    }()
    
    private var viewModel: IHotNewsViewModel
    private let feedType: FeedType
    private var feeds: [FeedItem] = []
    private var lastResolution = false
    private let LOG_ID = "** HotNewsView"
    private var isRefresh: Bool = false {
        didSet {
            mainView.kkRefreshControl.endRefreshing()
        }
    }
    
    init(viewModel: IHotNewsViewModel, feedType: FeedType) {
        self.viewModel = viewModel
        self.feedType = feedType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.setupTUIView(cell: feedType.viewCell)
        mainView.setResolution(isFast: true)
        viewModel.requestFeeds()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleWhenClickLikeOnHotNews(_:)), name: .handleWhenClickLikeOnHotNews, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainView.setupRefreshControl()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainView.tuiView.pause()
    }
    
    override func loadView() {
        view = mainView
    }
    
    private func setTUIVideos(with items: [FeedItem], isRrefresh: Bool = false) {
        if isRrefresh {
            mainView.tuiView.setShortVideoModels(items)
            mainView.tuiView.didScrollToCell(with: 0)
        } else {
            mainView.tuiView.appendShortVideoModels(items)
        }
    }
    
    @objc func handleWhenClickLikeOnHotNews(_ notification: Notification) {
        
        guard let feed = notification.object as? FeedItem else {
            return
        }
        
        guard let index = self.feeds.firstIndex(where: { $0.id == feed.id ?? "" }) else {
            return
        }
        
        feeds[index].likes = feed.likes
        feeds[index].isLike = feed.isLike
    }
}

extension HotNewsViewController: HotNewsViewDelegate {
    func pullToRefresh() {
        guard !isRefresh else { return }
        
        isRefresh = true
        viewModel.page = 0
        viewModel.requestFeeds()
    }
    
    func handleOnLicenceLoaded(_ result: Int32, reason: String) {
        guard result == 0 else { return }
        DispatchQueue.main.async {
            self.setTUIVideos(with: [])
        }
    }
    
    func handleSetTUIVideos() {
        setTUIVideos(with: [], isRrefresh: isRefresh)
    }
    
    func handleLoadMore() {
        print("\(LOG_ID) LOAD MORE PAGE")
        viewModel.page += 1
        viewModel.requestFeeds()
    }
}

extension HotNewsViewController: HotNewsViewModelDelegate {
    func displayErrorGetFeeds(with message: String) {
        isRefresh = false
        print(message)
    }
    
    func displayFeeds(with items: [FeedItem]) {
        if isRefresh {
            feeds = items
            mainView.tuiView.setShortVideoModels(items)
            mainView.tuiView.didScrollToCell(with: 0)
            isRefresh = false
        } else {
            feeds.append(contentsOf: items)
            mainView.tuiView.appendShortVideoModels(items)
        }
    }
}
