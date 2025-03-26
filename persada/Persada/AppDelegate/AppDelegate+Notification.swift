import UIKit
import FeedCleeps
import KipasKipasDonationTransactionDetailiOS
import KipasKipasDirectMessageUI
import KipasKipasNetworking
import KipasKipasNetworkingUtils
import KipasKipasShared
import KipasKipasNotification
import KipasKipasNotificationiOS
import SendbirdChatSDK
import KipasKipasDirectMessage
import KipasKipasDonationTransactionDetail
import KipasKipasStory
import KipasKipasStoryiOS

var notificationViewController: ((_ accountId: String) -> UIViewController)?
var showViewingListStory: ((String, [StorySectionViewModel]) -> ())?
var presentSingleFeedById: ((String) -> Void)?
var showFeedExplore: ((HotNewsFeedExploreParam) -> Void)?
var showProfile: ((String) -> Void)?

extension AppDelegate {
    
    func configureNotificationFeature() {
        KipasKipas.showFeedExplore = presentFeedExplore(by:)
        KipasKipas.presentSingleFeedById = presentSingleFeed(by:)
        KipasKipas.notificationViewController = makeNotifOnlyViewController
        KipasKipas.showViewingListStory = { [weak self] (id, stories) in
            self?.showStoryViewListViewController(
                selectedId: id,
                viewModels: stories
            )
        }
        KipasKipas.showProfile = showProfile
    }
    
    public func makeNotificationController(_ accountId: String) -> (notif: UIViewController, transaction: UIViewController) {
        let followerLoader: NotificationFollowersLoader = RemoteNotificationFollowersLoader(
            url: baseURL,
            client: authenticatedHTTPClient
        )
        let activitiesLoader: NotificationActivitiesLoader = RemoteNotificationActivitiesLoader(
            url: baseURL,
            client: authenticatedHTTPClient
        )
        let systemLoader: NotificationSystemLoader = RemoteNotificationSystemLoader(
            url: baseURL,
            client: authenticatedHTTPClient
        )
        let transactionLoader: NotificationTransactionLoader = RemoteNotificationTransactionLoader(
            url: baseURL,
            client: authenticatedHTTPClient
        )
        let suggestionLoader: NotificationSuggestionAccountLoader = RemoteNotificationSuggestionAccountLoader(
            url: baseURL,
            client: authenticatedHTTPClient
        )
        let followLoader: NotificationFollowUserLoader = RemoteNotificationFollowUserLoader(
            url: baseURL,
            client: authenticatedHTTPClient
        )
        let isReadChecker: NotificationActivitiesIsReadCheck = RemoteNotificationActivitiesIsReadCheck(
            url: baseURL,
            client: authenticatedHTTPClient
        )
        let activitiesDetailLoader: NotificationActivitiesDetailLoader = RemoteNotificationActivitiesDetailLoader(
            url: baseURL,
            client: authenticatedHTTPClient
        )
        let preferencesLoader: KipasKipasNotification.NotificationPreferencesLoader = KipasKipasNotification.RemoteNotificationPreferencesLoader(
            url: baseURL,
            client: authenticatedHTTPClient
        )
        let preferencesUpdater: KipasKipasNotification.NotificationPreferencesUpdater = KipasKipasNotification.RemoteNotificationPreferencesUpdater(
            url: baseURL,
            client: authenticatedHTTPClient
        )
        let transactionDetailLoader: NotificationTransactionDetailLoader = RemoteNotificationTransactionDetailLoader(
            url: baseURL,
            client: authenticatedHTTPClient
        )
        
        let donationOrderLoader: DonationTransactionDetailOrderLoader = RemoteDonationTransactionDetailOrderLoader(
            baseURL: baseURL,
            client: authenticatedHTTPClient
        )
        
        let donationGroupLoader: DonationTransactionDetailGroupLoader = RemoteDonationTransactionDetailGroupLoader(
            baseURL: baseURL,
            client: authenticatedHTTPClient
        )
        
        let isReadSystemChecker: NotificationSystemIsReadCheck = RemoteNotificationSystemIsReadCheck(
            url: baseURL,
            client: authenticatedHTTPClient
        )
        
        let notificationUnreadLoader: NotificationUnreadLoader = RemoteNotificationUnreadLoader(
            baseURL: baseURL,
            client: authenticatedHTTPClient
        )
        
        let notificationReadUpdater: NotificationReadUpdater = RemoteNotificationReadUpdater(
            baseURL: baseURL,
            client: authenticatedHTTPClient
        )
        
        let notificationLotteryLoader: NotificationLotteryLoader = RemoteNotificationLotteryLoader(
            baseURL: baseURL,
            client: authenticatedHTTPClient
        )
        
        let vc = KipasKipasNotificationiOS.NotificationRouter.create(
            followersLoader: MainQueueDispatchDecorator(decoratee: followerLoader),
            systemNotifLoader: MainQueueDispatchDecorator(decoratee: systemLoader),
            transactionLoader: MainQueueDispatchDecorator(decoratee: transactionLoader),
            suggestionAccountLoader: MainQueueDispatchDecorator(decoratee: suggestionLoader),
            activitiesLoader: MainQueueDispatchDecorator(decoratee: activitiesLoader),
            followUserLoader: MainQueueDispatchDecorator(decoratee: followLoader), 
            storyListLoader: StoryListInteractorAdapter(loader: makeListStoryLoader),
            isReadChecker: MainQueueDispatchDecorator(decoratee: isReadChecker),
            activitiesDetailLoader: MainQueueDispatchDecorator(decoratee: activitiesDetailLoader),
            preferencesLoader: MainQueueDispatchDecorator(decoratee: preferencesLoader),
            preferencesUpdater: MainQueueDispatchDecorator(decoratee: preferencesUpdater),
            transactionDetailLoader: MainQueueDispatchDecorator(decoratee: transactionDetailLoader),
            donationOrderLoader: MainQueueDispatchDecorator(decoratee: donationOrderLoader),
            donationGroupLoader: MainQueueDispatchDecorator(decoratee: donationGroupLoader), 
            isReadSystemChecker: MainQueueDispatchDecorator(decoratee: isReadSystemChecker),
            unreadsLoader: MainQueueDispatchDecorator(decoratee: notificationUnreadLoader), 
            readUpdater: MainQueueDispatchDecorator(decoratee: notificationReadUpdater), 
            lotteryLoader: MainQueueDispatchDecorator(decoratee: notificationLotteryLoader),
            handleShowConversation: {
                [weak self] patnerId in
                guard let self = self else { return }
                self.navigateToDM(userID: patnerId)
            },
            handleShowUserProfile: { [weak self] userId in
                guard let self = self else { return }
                self.navigateToProfileViewController(userId: userId)
            },
            
            handleShowFeed: { [weak self] feedId in
                guard let self = self else { return }
                self.presentSingleFeed(by: feedId)
            },
            handleShowSingleFeed: { [weak self] feedId in
                guard let self = self else { return }
                self.presentSingleFeed(by: feedId)
            },
            handleShowLive: { [weak self] roomId in
                guard let self = self else { return }
                showLiveStreamingListViewController(roomId: roomId)
            }, 
            handleShowLottery: { [weak self] id in
                guard let self = self else { return }
                self.handleOpenLottery(by: id)
            },
            handleShowCurrencyDetail: { [weak self] currency in
                guard let self = self else { return }
                
                let historyDetail = RemoteCurrencyHistoryDetailData(
                    invoiceNumber: currency.noInvoice,
                    accountNumber: currency.bankAccount,
                    storeName: currency.storeName.isEmpty ? "" : currency.storeName,
                    totalAmount: currency.totalWithdraw,
                    id: nil,
                    conversionPerUnit: currency.price,
                    bankFee: currency.bankFee,
                    recipient: "-",
                    accountName: nil,
                    createAt: currency.modifyAt,
                    qty: currency.qty,
                    currencyType: currency.currencyType,
                    bankName: currency.bankName,
                    userName: nil
                )
                
                if currency.currencyType.uppercased() == "DIAMOND" {
                    self.presentDiamondWithdrawalDetail(status: currency.status, detailData: historyDetail)
                } else {
                    self.presentCoinPurchaseDetail(status: currency.status, detailData: historyDetail)
                }
                
            },
            handleShowWithdrawlDetail: { [weak self] item in
                guard let self = self else { return }
                var withdrawl = Withdrawl(
                    id: item.id,
                    status: item.status,
                    nominal: item.nominal,
                    bankFee: item.bankFee,
                    total: item.total,
                    bankAccount: item.bankAccount,
                    referenceNo: item.referenceNo,
                    bankAccountName: item.bankAccountName,
                    bankName: item.bankName
                )
                self.presentWithdrawl(item: withdrawl)
            }, handleShowDonationGroupOrder: { [weak self] item in
                guard let self = self else { return }
                self.presentDonationGroup(item: item)
            }, storyHandler: NotificationRouter.StoryHandler(
                presentMyStory: { [weak self] (item, data, otherStories) in
                    
                    let selectedId = item.id ?? ""
                    let myStories = data.myStories().toViewModels(.me)
                    
                    if !myStories.isEmpty {
                        let friendStories = otherStories.toViewModels(.friends)
                        let stories = myStories + friendStories
                        self?.showStoryViewListViewController(
                            selectedId: selectedId,
                            viewModels: stories
                        )
                    } else {
                        self?.showAddStoryFromLibrary()
                    }
                },
                presentStoryLive: {
                    // Do present story live
                },
                presentOtherStory: { [weak self] (item, data, otherStories) in
                    let selectedId = item.id ?? ""
                    let myStories = data.myStories().toViewModels(.me)
                    let friendStories = otherStories.toViewModels(.friends)
                    let stories = myStories + friendStories
                    self?.showStoryViewListViewController(
                        selectedId: selectedId,
                        viewModels: stories
                    )
                },
                addStory: { [weak self] in
                    self?.showAddStoryFromLibrary()
                },
                retryUploadStory: { [weak self] in
                    self?.retryStoryUpload()
                },
                uploadProgress: { [weak self] in
                    self?.storyUploadProgress()
                }, onUpload: { [weak self] in
                    self?.storyOnUpload()
                }, onError: { [weak self] in
                    self?.storyOnError()
                }
            )
        )

        vc.notif.loggedUserId = accountId
        
        return vc
    }
    
    private func handleOpenLottery(by id: String) {
        let token = getToken() ?? ""
        let vc = KKDefaultWebViewController(url: "https://lottery.kipas-dev.com/#/notification?lotteryId=\(id)&Authorization=\(token)")
        vc.setupNavigationBar(backIndicator: .iconChevronLeft)
        pushOnce(vc)
    }
    
    private func makeNotifOnlyViewController(_ accountId: String) -> UIViewController {
        return makeNotificationController(accountId).notif
    }
    
    private func makeTransactionController() -> UIViewController {
        return makeNotificationController("").transaction
    }
    
    func presentDonationGroup(item: DonationTransactionDetailGroupItem?) {
        guard let item = item else { return }
        var donations = item.donations.compactMap({
            DonationGroupItem(
                postDonationID: $0.postDonationID,
                title: $0.title,
                urlPhoto: $0.urlPhoto,
                amount: $0.amount
            )
        })
        
        
        let controller = DonationTransactionGroupController(
            items: DonationTransactionDetailGroupItem(
                donations: donations,
                totalAmount: item.totalAmount
            )
        )
        
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        presentOnce(controller)
    }
    
    func presentWithdrawl(item: Withdrawl) {
        let vc = DetailTransactionGopayController(withdraw: item)
        vc.bindNavigationBar(.get(.penarikanDana))
        pushOnce(vc, animated: false)
    }
    
    func presentDiamondWithdrawalDetail(status: String, detailData: RemoteCurrencyHistoryDetailData) {
        let vc = DiamondWithdrawalDetailRouter.create(
            baseUrl: APIConstants.baseURL,
            authToken: getToken() ?? "",
            status: status.lowercased() == "completed" ? .complete : .process,
            type: .withdrawal,
            id: "",
            historyDetail: detailData
        )

        vc.bindNavigationBar("", false)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .overFullScreen
        presentOnce(nav)
    }
    
    func presentCoinPurchaseDetail(status: String, detailData: RemoteCurrencyHistoryDetailData) {
        
        var purchaseStatus: CoinPurchaseStatus {
            switch status.uppercased() {
            case "COMPLETE", "PURCHASED":
                return .complete
            case "PROCESS":
                return .process
            case "CANCELLED", "CANCELED":
                return .cancelled
            default:
                return .process
            }
        }
        
        let vc = CoinPurchaseDetailRouter.create(
            baseUrl: APIConstants.baseURL,
            authToken: getToken(),
            purchaseStatus: purchaseStatus,
            purchaseType: .topup,
            id: "",
            historyDetail: detailData,
            isPresent: true
        )
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .overFullScreen
        presentOnce(nav)
    }
    
    func presentFeedExplore(by param: HotNewsFeedExploreParam) {
        let vc = HotNewsFactory.create(
            by: .explore,
            profileId: getIdUser(),
            page: param.currentPage,
            selectedFeedId: param.id,
            alreadyLoadFeeds: param.contents
        )
        vc.hidesBottomBarWhenPushed = true
        vc.configureDismissablePresentation(tintColor: .white)
        
        let navigationController = UINavigationController(rootViewController: vc)
        presentWithSlideAnimation(navigationController)
    }
    
    
    
    func presentSingleFeed(by id: String) {
//        let vc = HotNewsFactory.createSingleFeed(selectedFeedId: id)
        let vc = HotNewsFactory.createHotRoomSingFeed(selectedFeedId: id, isFromPushFeed: true)
        vc.bindNavigationBar("")
        vc.hidesBottomBarWhenPushed = true
        vc.configureDismissablePresentation(tintColor: .white)
        
        let navigationController = UINavigationController(rootViewController: vc)
        presentWithSlideAnimation(navigationController)
    }
    
    func navigateToDM(userID: String) {
        TXIMUserManger.shared.getUsersInfo([userID]) { [weak self] userList in
            guard let self = self else { return }
            guard let user = userList.first.map({
                TXIMUser(
                    userID: userID,
                    userName: $0.nickName,
                    faceURL: $0.faceURL,
                    isVerified: $0.isVerified
                )
            }) else { return }
            
            showIMConversation?(user)
        } failure: { _ in }
    }
    
    func navigateToTransaction() {
        let destination = makeTransactionController()
        dismiss(until: DonationDetailViewController.self, animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.pushOnce(destination)
        }
    }
    
    // MARK: Story
    private func makeStoryViewingListViewController(
        selectedId: String,
        viewModels: [StorySectionViewModel]
    ) -> UIViewController {
        let parameter = StoryViewingListUIComposer.Parameter(
            selectedId: selectedId,
            viewModels: viewModels
        )
        let callback = StoryViewingListUIComposer.Callback(
            showListViewers: showStoryViewersViewController,
            showShareSheet: { [weak self] viewModel, delete in
                let item = CustomShareItem(
                    id: viewModel.id,
                    message: "",
                    type: .story,
                    assetUrl: viewModel.media.url,
                    accountId: viewModel.account.id,
                    price: nil,
                    username: getUsername()
                )
                let vc = KKShareController(mainView: KKShareView(), item: item)
                vc.onDelete = { [weak self] in
                    self?.showDeleteAlertConfirmation(deleteStory: delete)
                }
                vc.didDisappear = {
                    NotificationCenter.default.post(name: StoryPlayView.shouldResumeWhenVisible, object: nil)
                    NotificationCenter.default.post(name: VideoPlayerView.shouldResumeWhenVisible, object: nil)
                }
                self?.presentOnce(vc, animated: true)
            },
            showCameraGallery: showAddStoryFromLibrary,
            showProfile: showProfile
        )
        let loader = StoryViewingListUIComposer.Loader(
            storySeenLoader: StorySeenLoader(publisher: makeStorySeenLoader),
            storyLikeLoader: StoryLikeLoader(publisher: makeStoryLikeLoader), 
            storyDeleteLoader: StoryDeleteLoader(publisher: makeStoryDeleteLoader)
        )
        let controller = StoryViewingListUIComposer.composeWith(
            parameter: parameter,
            callback: callback,
            loader: loader
        )
        
        return controller
    }
    
    private func showDeleteAlertConfirmation(deleteStory: @escaping EmptyClosure) {
        let deleteAction = UIAlertAction(title: "Hapus", style: .destructive) { [weak self] _ in
            self?.window?.topViewController?.forceDismiss(animated: true) {
                deleteStory()
            }
        }
        deleteAction.titleTextColor = .primary
        
        let cancelAction = UIAlertAction(title: "Batalkan", style: .cancel, handler: nil)
        cancelAction.titleTextColor = .grey
        
        window?.topViewController?.showAlertController(
            title: "Hapus Story ini?",
            titleFont: .roboto(.bold, size: 14),
            backgroundColor: .white,
            actions: [deleteAction, cancelAction]
        )
    }
    
    func showStoryViewListViewController(
        selectedId: String,
        viewModels: [StorySectionViewModel]
    ) {
        let destination = makeStoryViewingListViewController(
            selectedId: selectedId,
            viewModels: viewModels
        )
        destination.modalPresentationStyle = .fullScreen
        presentOnce(destination)
    }
    
    func showStoryViewersViewController(
        item: StoryItemViewModel,
        didDelete: @escaping () -> Void
    ) {
        let destination = makeStoryViewersViewController(
            item: item,
            didDelete: didDelete
        )
        
        let navigation = UINavigationController(rootViewController: destination)
        
        let configuration = PresentationUIConfiguration(
            cornerRadius: 16,
            corners: [
                .layerMaxXMinYCorner,
                .layerMinXMinYCorner
            ]
        )
        let size = PresentationSize(height: .custom(value: UIScreen.main.bounds.height * 0.7))
        
        presentWithCoverAnimation(
            configuration: configuration,
            size: size,
            navigation
        )
    }
    
    private func showProfile(id: String) {
        let destination = ProfileRouter.create(userId: id)
        destination.configureDismissablePresentation(tintColor: .night)

        let navigation = UINavigationController(rootViewController: destination)
        NotificationCenter.default.post(name: StoryPlayView.shouldPausedWhenNotVisible, object: nil)
        NotificationCenter.default.post(name: VideoPlayerView.shouldPausedWhenNotVisible, object: nil)

        presentWithSlideAnimation(navigation)
    }

    func makeStoryViewersLoader(_ request: StoryViewerRequest) -> API<StoryViewersResponse, AnyError> {
        return authenticatedHTTPClient.getPublisher(
            request: .url(baseURL)
                .path("/stories/list-viewers")
                .queries([
                    .init(name: "storyId", value: request.storyId),
                    .init(name: "page", value: String(request.page)),
                    .init(name: "size", value: String(request.size))
                ])
                .method(.GET)
                .build()
        )
        .tryMap(Mapper<StoryViewersResponse>.map)
        .mapError({ error in
            let mappedError = MapperError.map(error)
            return AnyError(
                code: mappedError.code,
                message: mappedError.message,
                data: mappedError.data
            )
        })
        .subscribe(on: scheduler)
        .eraseToAnyPublisher()
    }
    
    func makeStoryFollowLoader(_ userId: String) -> API<StoryEmptyData, AnyError> {
        return authenticatedHTTPClient.getPublisher(
            request: .url(baseURL)
                .path("/profile/\(userId)/follow")
                .method(.PATCH)
                .build()
        )
        .tryMap(Mapper<StoryEmptyData>.map)
        .mapError({ error in
            let mappedError = MapperError.map(error)
            return AnyError(
                code: mappedError.code,
                message: mappedError.message,
                data: mappedError.data
            )
        })
        .subscribe(on: scheduler)
        .eraseToAnyPublisher()
    }
    
    func makeStoryUnfollowLoader(_ userId: String) -> API<StoryEmptyData, AnyError> {
        return authenticatedHTTPClient.getPublisher(
            request: .url(baseURL)
                .path("/profile/\(userId)/unfollow")
                .method(.PATCH)
                .build()
        )
        .tryMap(Mapper<StoryEmptyData>.map)
        .mapError({ error in
            let mappedError = MapperError.map(error)
            return AnyError(
                code: mappedError.code,
                message: mappedError.message,
                data: mappedError.data
            )
        })
        .subscribe(on: scheduler)
        .eraseToAnyPublisher()
    }
    
    func makeStoryViewersViewController(
        item: StoryItemViewModel,
        didDelete: @escaping () -> Void
    ) -> UIViewController {
        let parameter = StoryViewersUIComposer.Parameter(storyId: item.id)
        let loader = StoryViewersUIComposer.Loader(
            viewersLoader: StoryViewersLoader(publisher: makeStoryViewersLoader),
            followLoader: StoryFollowLoader(publisher: makeStoryFollowLoader)
        )
        let callback = StoryViewersUIComposer.Callback(
            didDeleteStory: didDelete,
            showProfile: showProfile,
            sendMessage: navigateToDM
        )
        
        let controller = StoryViewersUIComposer.composeWith(
            parameter: parameter,
            loader: loader,
            callback: callback
        )
        return controller
    }
    
    private func makeStorySeenLoader(_ param: StorySeenRequest) -> API<StoryEmptyData, AnyError> {
        return authenticatedHTTPClient.getPublisher(
            request: .url(baseURL)
                .path("/stories/me/view")
                .method(.POST)
                .body(param)
                .build()
        )
        .tryMap(Mapper<StoryEmptyData>.map)
        .mapError({
            error in
            let mappedError = MapperError.map(error)
            return AnyError(
                code: mappedError.code,
                message: mappedError.message,
                data: mappedError.data
            )
        })
        .subscribe(on: scheduler)
        .eraseToAnyPublisher()
    }
    
    private func makeStoryDeleteLoader(_ param: StoryDeleteRequest) -> API<StoryEmptyData, AnyError> {
        return authenticatedHTTPClient.getPublisher(
            request: .url(baseURL)
                .path("/stories/\(param.id)/feeds/\(param.feedId)")
                .method(.DELETE)
                .build()
        )
        .tryMap(Mapper<StoryEmptyData>.map)
        .mapError({
            error in
            let mappedError = MapperError.map(error)
            return AnyError(
                code: mappedError.code,
                message: mappedError.message,
                data: mappedError.data
            )
        })
        .subscribe(on: scheduler)
        .eraseToAnyPublisher()
    }
    
    private func makeStoryLikeLoader(_ param: StoryLikeRequest) -> API<StoryEmptyData, AnyError> {
        return authenticatedHTTPClient.getPublisher(
            request: .url(baseURL)
                .path("/likes/story")
                .method(.POST)
                .queries([
                    .init(name: "storyId", value: param.storyId),
                    .init(name: "likeStatus", value: param.likeStatus.rawValue),
                ])
                .build()
        )
        .tryMap(Mapper<StoryEmptyData>.map)
        .mapError({
            error in
            let mappedError = MapperError.map(error)
            return AnyError(
                code: mappedError.code,
                message: mappedError.message,
                data: mappedError.data
            )
        })
        .subscribe(on: scheduler)
        .eraseToAnyPublisher()
    }
}

//extension AppDelegate: StoryViewersControllerDelegate {
//    func didMessage(with item: KipasKipasStory.StoryViewer) {
//        //
//    }
//    
//    func didFollow(with item: KipasKipasStory.StoryViewer) {
//        //
//    }
//    
//    func didOpenProfile(with item: KipasKipasStory.StoryViewer) {
//        navigateToProfileViewController(userId: item.id)
//    }
//}

extension MainQueueDispatchDecorator: NotificationFollowUserLoader where T == NotificationFollowUserLoader {
    public func load(request: NotificationFollowUserRequest, completion: @escaping (ResultFollowUser) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: NotificationActivitiesLoader where T == NotificationActivitiesLoader {
    public func load(request: NotificationActivitiesRequest, completion: @escaping (ResultActivities) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: NotificationFollowersLoader where T == NotificationFollowersLoader {
    public func load(request: NotificationFollowersRequest, completion: @escaping (ResultFollowers) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: NotificationTransactionLoader where T == NotificationTransactionLoader {
    public func load(request: NotificationTransactionRequest, completion: @escaping (NotificationTransactionLoader.ResultTransaction) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: NotificationSuggestionAccountLoader where T == NotificationSuggestionAccountLoader {
    public func load(request: NotificationSuggestionAccountRequest, completion: @escaping (ResultSuggestionAccount) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: NotificationActivitiesIsReadCheck where T == NotificationActivitiesIsReadCheck {
    public func check(request: KipasKipasNotification.NotificationActivitiesIsReadRequest, completion: @escaping (ResultActivitiesIsRead) -> Void) {
        decoratee.check(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: NotificationActivitiesDetailLoader where T == NotificationActivitiesDetailLoader {
    public func load(request: KipasKipasNotification.NotificationActivitiesDetailRequest, completion: @escaping (ResultActivitiesDetail) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: KipasKipasNotification.NotificationPreferencesLoader where T == KipasKipasNotification.NotificationPreferencesLoader {
    public func load(request: KipasKipasNotification.NotificationPreferencesRequest, completion: @escaping (ResultPreferences) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: KipasKipasNotification.NotificationPreferencesUpdater where T == KipasKipasNotification.NotificationPreferencesUpdater {
    public typealias Result = KipasKipasNotification.NotificationPreferencesUpdater.Result
    public func update(request: KipasKipasNotification.NotificationPreferencesUpdateRequest, completion: @escaping (Result) -> Void) {
        decoratee.update(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: NotificationTransactionDetailLoader where T == NotificationTransactionDetailLoader {
    public func load(request: NotificationTransactionDetailRequest, completion: @escaping (NotificationTransactionDetailLoader.ResultTransaction) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: NotificationSystemIsReadCheck where T == NotificationSystemIsReadCheck {
    public func check(request: NotificationSystemIsReadRequest, completion: @escaping (ResultSystemIsRead) -> Void) {
        decoratee.check(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: NotificationUnreadLoader where T == NotificationUnreadLoader {
    public func load(completion: @escaping (NotificationUnreadLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: NotificationReadUpdater where T == NotificationReadUpdater {
    public func update(_ request: NotificationReadRequest, completion: @escaping (NotificationReadUpdater.Result) -> Void) {
        decoratee.update(request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: NotificationLotteryLoader where T == NotificationLotteryLoader {
    public func load(request: NotificationLotteryRequest, completion: @escaping (NotificationLotteryLoader.Result) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
