//
//  ProfileFeedViewController.swift
//  KipasKipasFeed
//
//  Created by DENAZMI on 01/11/23.
//

import UIKit
import TUIPlayerCore
import TUIPlayerShortVideo
import KipasKipasShared

protocol IProfileFeedViewController: AnyObject {
    func displayErrorGetFeeds(with message: String)
    func displayFeeds(with items: [FeedItem])
}

public class ProfileFeedViewController: UIViewController {
    
    public lazy var mainView: ProfileFeedView = {
        let view = ProfileFeedView()
        view.tuiView.delegate = view
        view.delegate = self
        return view
    }()
    
    var interactor: IProfileFeedInteractor!
    var router: IProfileFeedRouter!
    
    private var isLoadingData: Bool = false
    private var feeds: [FeedItem] = []
    private let feedType: FeedType
    
    public var handleOnClickComment: ((FeedItem?) -> Void)?
    public var handleOnClickShare: ((FeedItem?) -> Void)?
    public var handleOnClickProfile: ((FeedItem?) -> Void)?
    public var handleOnClickNewsPortal: ((String) -> Void)?
    public var handleOnClickHashtag: ((FeedItem?, String) -> Void)?
    public var handleOnClickMention: ((String?, String?) -> Void)?
    public var handleOnClickDonationNow: ((FeedItem?) -> Void)?
    public var handleOnClickDonationFilterCategory: ((String?) -> Void)?
    public var handleShowLoginPopUp: (() -> Void)?
    public var handleOnClickShortcutStartPaidDM: ((FeedItem?) -> Void)?
    
    
    private var isRefresh: Bool = false {
        didSet {
            mainView.refreshControl.endRefreshing()
        }
    }
    
    public init(feedType: FeedType) {
        self.feedType = feedType
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.setupTUIView()
        mainView.setResolution(isFast: true)
        firstLoadFeeds()
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification, object: nil
        )
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(enterBackground),
            name: UIApplication.didEnterBackgroundNotification, object: nil
        )
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleTapActionOnProfileFeedCell(_:)),
            name: .handleTapActionOnProfileFeedCell, object: nil
        )
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleTapActionOnProfileFeedCell(_:)),
            name: .handleUpdateProfileFeed, object: nil
        )
    }
    
    func firstLoadFeeds() {
        feeds.removeAll()
        mainView.feeds.removeAll()
        mainView.tuiView.removeAllVideoModels()
        mainView.tuiView.startLoading()
        interactor.requestFeeds()
    }
    
    func configureScrollEdgeAppearance() {
        if #available(iOS 15, *) {
            guard let navigationBar = navigationController?.navigationBar else { return }
            
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground() // use `configureWithTransparentBackground` for transparent background
            appearance.backgroundColor = .clear
            appearance.shadowColor = .clear
            appearance.shadowImage = UIImage()
            
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
        }
        
        navigationController?.navigationBar.backgroundColor = .clear
    }
    
    @objc func enterBackground(){
        //print("*** refreshIfDataIsOld. enterBackground...")
        pause()
        setLastAppear()
    }
    
    @objc public func applicationDidBecomeActive() {
        refreshIfDataIsOld()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overrideUserInterfaceStyle = .dark
        configureScrollEdgeAppearance()
        mainView.isAppear = true
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainView.setupRefreshControl()
        mainView.isAppear = true
        resume()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainView.isAppear = false
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mainView.isAppear = false
        pause()
    }
    
    public override func loadView() {
        view = mainView
    }
    
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func showNetworkErrorDialog(title: String = "", onRetry: (() -> Void)? = nil, onCancel: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Network Error \(title)" , message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Retry", style: .default , handler:{ [weak self] (UIAlertAction) in
            guard self != nil else { return }
            onRetry?()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] (UIAlertAction) in
            guard self != nil else { return }
            onCancel?()
        }))
        self.present(alert, animated: true)
    }
    
    private func showDataEmptyDialog(onOK: (() -> Void)? = nil, onRetry: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Data Sudah Habis", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Retry", style: .default , handler:{ [weak self] (UIAlertAction) in
            guard self != nil else { return }
            onRetry?()
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default , handler:{ [weak self] (UIAlertAction) in
            guard self != nil else { return }
            onOK?()
        }))

        self.present(alert, animated: true)
    }
    
    @objc func handleUpdateProfileFeed(_ notification: Notification) {
        
        let feed = notification.object as? FeedItem
        handleOnClickComment?(feed)
    }
    
    @objc func handleWhenClickCommentOnProfileFeed(_ notification: Notification) {
        
        let feed = notification.object as? FeedItem
        handleOnClickComment?(feed)
    }
    
    @objc func handleWhenClickShareOnProfileFeed(_ notification: Notification) {
        
        let feed = notification.object as? FeedItem
        handleOnClickShare?(feed)
    }
    
    @objc func handleWhenClickProfileOnProfileFeed(_ notification: Notification) {
        
        let feed = notification.object as? FeedItem
        handleOnClickProfile?(feed)
    }
    
    @objc func handleTapActionOnProfileFeedCell(_ notification: Notification) {
        
        guard let action = notification.object as? ProfileFeedCellTapAction else {
            return
        }
        
        switch action {
        case .like(let feed):
            guard feed?.feedType == feedType else { return }
            interactor.updateLike(id: feed?.id ?? "", isLike: feed?.isLike ?? false)
        case .comment(let feed):
            guard feed?.feedType == feedType else { return }
            handleOnClickComment?(feed)
        case .share(let feed):
            guard feed?.feedType == feedType else { return }
            handleOnClickShare?(feed)
        case .profile(_):
            break
        case .playPause(let feed, let isPlay):
            guard feed?.feedType == feedType else { return }
            if isPlay == true {
                mainView.tuiView.resume()
            } else {
                mainView.tuiView.pause()
            }
        case .hashtag(let feed, let value):
            guard feed?.feedType == feedType else { return }
            handleOnClickHashtag?(feed, value)
            print("azmiiiiiiii", interactor.userId)
        case .mention(_, _):
            break
        case .shortcutStartPaidDM(let feed):
            guard feed?.feedType == feedType else { return }
            handleOnClickShortcutStartPaidDM?(feed)
        case .follow(_):
            break
        case .donationDetail(let feed):
            guard feed?.feedType == feedType else { return }
            handleOnClickDonationNow?(feed)
        }
    }
    
    public func resume() {
        mainView.tuiView.resume()
    }
    
    public func pause() {
        mainView.tuiView.pause()
    }
    
    public func pauseIfNeeded() {
        if mainView.tuiView.isPlaying {
            mainView.tuiView.pause()
        }
    }
    
    public func resumeIfNeeded() {
        if !mainView.tuiView.isPlaying {
            mainView.tuiView.resume()
        }
    }
}

extension ProfileFeedViewController: ProfileFeedViewDelegate {
    
    public func pullToRefresh() {
        isRefresh = true
        refreshing()
    }
    
    func refreshing(){
        mainView.hideState()
        mainView.showLoading()

        if isRefresh {
            feeds.removeAll()
            mainView.feeds.removeAll()
            mainView.tuiView.removeAllVideoModels()
            mainView.tuiView.startLoading()
            interactor.page = 0
            interactor.requestFeeds()
        }
    }
    
    func handleOnLicenceLoaded(_ result: Int32, reason: String) {
        guard result == 0 else { return }
        DispatchQueue.main.async {
            let empty: [TUIPlayerVideoModel] = []
            self.mainView.tuiView.setShortVideoModels(empty)
        }
    }
    
    func handleLoadMore() {
        if interactor.page < interactor.totalPages {
            isLoadingData = true
            interactor.page += 1
            interactor.requestFeeds()
        }
    }
}

extension ProfileFeedViewController: IProfileFeedViewController {
    
    func displayStateEmpty(label: String) {
        if mainView.tuiView.videos.count == 0 {
            mainView.tuiView.stopLoading()
            mainView.showStateEmpty(label: label)
        }
    }
    
    func displayErrorGetFeeds(with message: String) {
        mainView.hideLoading()
        
        isLoadingData = false
        if interactor.page == 0 {
            isRefresh = false
            displayStateEmpty(label: "Network Timeout")
        } else {
            var title = message
            print("*** showNetworkErrorDialog - C", message)
            if(message.lowercased().description.contains("token")){
                title = "(ERR:TKN)"
            } else if(message.description.contains("405")){
                title = "(ERR:405)"
            } else if(message.description.contains("9999") || message.description.contains("500")){
                title = "Time Out"
            }
            
            showNetworkErrorDialog(title: title, onRetry: handleLoadMore)
        }
        
    }
    
    func displayFeeds(with items: [FeedItem]) {
        isLoadingData = false
        
        mainView.hideState()
        mainView.hideLoading()
        
        if isRefresh {
            feeds = items
            mainView.feeds = feeds
            mainView.tuiView.setShortVideoModels(feeds)
            
            if items.isEmpty {
                mainView.tuiView.stopLoading()
                showDataEmptyDialog(onRetry: pullToRefresh)
            }
            isRefresh = false
        } else {
            if interactor.feeds.isEmpty {
                feeds.append(contentsOf: items)
                mainView.feeds.append(contentsOf: items)
                mainView.tuiView.appendShortVideoModels(items)
            } else {
                interactor.feeds = []
                feeds = items
                mainView.feeds = feeds
                mainView.tuiView.setShortVideoModels(feeds)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    guard let self = self else { return }
                    
                    if let index = self.feeds.firstIndex(where: { $0.id == self.interactor.selectedFeedId }) {
                        guard self.mainView.tuiView.tableView() != nil else { return }
                        if self.mainView.tuiView.videos.count >= index {
                            self.mainView.tuiView.didScrollToCell(with: index, animated: false)
                        }
                    }
                }
            }
        }
    }
    
    func refreshIfDataIsOld() {
        let lastOpenTimeStampString = Double(DataCache.instance.readString(forKey: "KEY_LAST_OPEN_ProfileFeed") ?? "0") ?? 0.0
        let currentTimeStamp = Date().timeIntervalSince1970
        let deviationLastOpen = currentTimeStamp - lastOpenTimeStampString
        var EXPIRED_TIME = 30 * 60
//        EXPIRED_TIME = 5
        if Int(deviationLastOpen) > EXPIRED_TIME {
            if mainView.tuiView.videos.count > 0 {
                isRefresh = true
                refreshing()
            }
        }
    }
    
    func setLastAppear() {
        let currentTimeStamp = Date().timeIntervalSince1970
        let currentTimeStampString = String(format: "%f", currentTimeStamp)
        DataCache.instance.write(string: currentTimeStampString, forKey: "KEY_LAST_OPEN_ProfileFeed")
    }
}
