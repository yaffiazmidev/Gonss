import UIKit
import Combine
import KipasKipasShared
import KipasKipasNetworking
import KipasKipasNetworkingUtils
import KipasKipasLiveStream
import KipasKipasLiveStreamiOS
import KipasKipasDirectMessageUI
import TUICore
import ImSDK_Plus

var showLiveStreamingList: ((String?) -> Void)?

final class NavigationControllerPanable: UINavigationController, PanModalPresentable {
    
    override init(rootViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        viewControllers = [rootViewController]
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        let vc = super.popViewController(animated: animated)
        panModalSetNeedsLayoutUpdate()
        return vc
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        panModalSetNeedsLayoutUpdate()
    }
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var longFormHeight: PanModalHeight {
        return shortFormHeight
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(420)
    }
    
    var allowsExtendedPanScrolling: Bool {
        return true
    }
}

extension AppDelegate {
      
    func configureLiveStreamingAudienceFeature() {
        KipasKipas.showLiveStreamingList = showLiveStreamingListViewController
    }
    
    func showLiveStreamingListViewController(roomId: String?) {
        let liveStreamingList = makeLiveStreamingListViewController(roomId: roomId)
        liveStreamingList.hidesBottomBarWhenPushed = true
        pushOnce(liveStreamingList)
    }
    
    func makeLiveStreamingListViewController(roomId: String?) -> UIViewController {
        let presentationAdapter = ListActiveLiveStreamPresentationAdapter(
            profileLoader: makeProfileLoader,
            loader: makeListActiveLiveStreamLoader
        )
        let controller = LiveStreamingListViewController()
        
        controller.loadActiveLiveStreams = presentationAdapter.load
        
        let viewAdapter = ListActiveLiveStreamViewAdapter(
            roomId: roomId, 
            controller: controller,
            profileLoader: makeProfileLoader,
            seatProfileLoader:makeSeatProfileLoader, 
            audienceListLoader: makeMemberListLoader,
            topSeatsLoader: makeLiveTopSeatsLoader,
            followLoader: makeFollowLoader,
            unfollowLoader: makeUnfollowLoader, 
            onClickShare: navShareController,
            listGiftLoader: makeListGiftLoader,
            coinBalanceLoader: makeCoinBalanceLoader,
            onClickAudience: showAudienceListViewController,
            onDailyRankClicked: { [weak self] in
                self?.showDailyRankViewController(isAnchor: false,selectNavLeft:$0,sendGiftAction: $1)
            },
            onUserImageClicked: navigateToProfileViewController,
            onKicked: showOnKickedPopUp, 
            onTapTopUpCoin: navigateToCoinAppPurchase
        )
        presentationAdapter.presenter = ListActiveLiveStreamPresenter(view: viewAdapter)
        
        return controller
    }
    
    private func makeCoinBalanceLoader() -> LiveCoinBalanceLoader {
        let url = LiveStreamEndpoint.coinBalance.url(baseURL: baseURL)
        
        return authenticatedHTTPClient
            .getPublisher(request: url)
            .dispatchOnMainQueue()
            .tryMap(Mapper<Root<LiveCoinBalance>>.map)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makeLiveTopSeatsLoader(with roomId: String) -> LiveTopSeatLoader {
        let url = LiveStreamEndpoint.topSeat(roomId: roomId).url(baseURL: baseURL)
        
        return authenticatedHTTPClient
            .getPublisher(request: url)
            .dispatchOnMainQueue()
            .tryMap(Mapper<Root<[LiveTopSeat]>>.map)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makeListGiftLoader() -> ListGiftLoader {
        let url = LiveStreamEndpoint.gifts.url(baseURL: baseURL)
        
        return authenticatedHTTPClient
            .getPublisher(request: url)
            .dispatchOnMainQueue()
            .tryMap(Mapper<Root<[LiveGift]>>.map)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func navigateToCoinAppPurchase() {
        let store = tokenStore.retrieve()
        let destination = OldCoinPurchaseRouter.create(
            baseUrl: baseURL.absoluteString,
            authToken: store?.accessToken ?? ""
        )
        let container = CoinPurchaseContainerViewController(controller: destination)
        container.overrideUserInterfaceStyle = .dark
        
        pushOnce(container, animated: true)
    }
    
    private func showAudienceListViewController(groupId: String, ownerId: String,giftAction:  @escaping ()->Void ,faqAction:  @escaping ()->Void ) {
        let controller = AudienceListUIComposer.composeAudienceListUIWith(
            loader: makeMemberListLoader(request:),
            classicGiftLoader: makeListGiftLoader,
            coinBalanceLoader: makeCoinBalanceLoader,
            groupId: groupId,
            ownerId: ownerId,
            audienceShowTips: true,
            selection: { [weak self] userId in
                self?.window?.topViewController?.dismiss(animated: true) { [weak self] in
                    self?.navigateToProfileViewController(userId: userId)
                }
            },
            giftAction:giftAction,
            faqAction:faqAction 
        )
        let destination = NavigationControllerPanable(rootViewController: controller)
        window?.topViewController?.presentPanModal(destination)
    }
    
    func navigateToProfileViewController(userId: String) {
        let destination = ProfileRouter.create(userId: userId)
        destination.bindNavigationBar(
            icon: "ic_chevron_left_outline_black",
            customSize: .init(width: 20, height: 14),
            contentHorizontalAlignment: .fill,
            contentVerticalAlignment: .fill
        )
        destination.hidesBottomBarWhenPushed = true
        pushOnce(destination)
    }
    
    private func makeFollowLoader(userId: String) -> FollowLoader {
        let url = LiveStreamProfileEndpoint.follow(userId).url(baseURL: baseURL)
        
        return authenticatedHTTPClient
            .getPublisher(request: url)
            .delay(for: 2, scheduler: scheduler)
            .dispatchOnMainQueue()
            .tryMap(Mapper<EmptyData>.map)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makeUnfollowLoader(userId: String) -> FollowLoader {
        let url = LiveStreamProfileEndpoint.unfollow(userId).url(baseURL: baseURL)
        
        return authenticatedHTTPClient
            .getPublisher(request: url)
            .delay(for: 1, scheduler: scheduler)
            .dispatchOnMainQueue()
            .tryMap(Mapper<EmptyData>.map)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makeMemberListLoader(request: LiveStreamAudienceListRequest) -> ListAudienceLoader {
        let url = LiveStreamEndpoint.topViewers(roomId: request.roomId).url(baseURL: baseURL)
        
        return authenticatedHTTPClient
            .getPublisher(request: url)
            .dispatchOnMainQueue()
            .tryMap(Mapper<Root<[LiveStreamAudience]>>.map)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    
//    private func OLDmakeMemberListLoader(request: LiveStreamAudienceListRequest) -> ListAudienceLoader {
//        return imManager
//            .getAudienceList(groupId: request.roomId, page: request.page)
//            .tryMap({ members in
//                return members
//                    .sorted(by: { $0.joinTime < $1.joinTime })
//                    .compactMap { .init(
//                    userId: $0.userID,
//                    username: $0.nickName ?? "",
//                    avatarURL: $0.faceURL ?? ""
//                )}
//                .filter { $0.userId != request.ownerId }
//            })
//            .subscribe(on: scheduler)
//            .eraseToAnyPublisher()
//    }
    
    private func makeListActiveLiveStreamLoader() -> ListLiveRoomLoader {
        let url = LiveStreamEndpoint.activeLiveStreamList.url(baseURL: baseURL)
        return authenticatedHTTPClient
            .getPublisher(request: url)
            .delay(for: 1, scheduler: scheduler)
            .tryMap(Mapper<Root<LiveRoomActive>>.map)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func showOnKickedPopUp() {
        let destination = CustomPopUpViewController(
            title: "Kamu Menonton Live dari Perangkat Lain!",
            description: "Saat kamu menonton Live dari  perangkat lain dengan akun yang sama, maka perangkat ini akan otomatis keluar dari Live",
            iconImage: .illustrationDoubleLogin,
            iconHeight: 120,
            okBtnTitle: "OKE",
            isHideIcon: false
        )
        destination.modalPresentationStyle = .overCurrentContext
        
        destination.handleTapOKButton = { [weak self] in
            self?.window?.topNavigationController?.popViewController(animated: true)
        }
        
        presentOnce(destination, animated: true)
    }
    
    func navShareController(_ info:[String:String]){
        let text = info["message"]! + "  " + info["assetUrl"]!
        let item = CustomShareItem(id: info["id"], message: text, type:.live , assetUrl:  "", accountId: info["accountId"] ?? "", name:info["name"] ?? "", price:nil,username: info["username"])
        let vc = KKShareController(mainView: KKShareView(), item: item)
       
        self.presentOnce(vc, animated: true)
        
    }
    
    func navReportController(){
//        showFeedReport?(.init(
//            targetReportedId: "item.id" ?? "",
//            accountId: "item.accountId",
//            username: "item.username",
//            kind: .LIVE_STREAMING ,
//            delegate: self
//        ))
    }
    
    
    private func makeProfileLoader() -> LiveProfileLoader {
        let storedUser = loggedInUserStore.retrieve()
        
        struct UserIDNotFound: Error {}
        
        guard let userId = storedUser?.accountId else {
            return Fail(error: UserIDNotFound()).eraseToAnyPublisher()
        }
        let request = LiveStreamProfileEndpoint.profileByUserId(userId).url(baseURL: baseURL)
        return authenticatedHTTPClient
            .getPublisher(request: request)
            .tryMap(Mapper<Root<LiveUserProfile>>.map)
            .flatMap { profile in
                return self.makeTUILoginLoader(profile: profile)
                    .catch { [weak self] error in
                        let value = Just(profile)
                            .setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                        
                        guard let error = error as? TUILogin.LoginError else {
                            return value
                        }
                        
                        if error == .appDisabled {
                            self?.showToastLiveUnderMaintenance()
                        }
                        
                        return value
                    }
            }
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makeTUILoginLoader(profile: Root<LiveUserProfile>) -> LiveProfileLoader {
        return  TUILogin
            .loginPublisher(userId: profile.data.id ?? "")
            .tryMap { _ in profile }
            .flatMap { profile in
                return self.imLoginLoader(profile: profile)
            }
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makeSeatProfileLoader(_ seatId:String) -> LiveProfileLoader {
        let url = LiveStreamProfileEndpoint.profileByUserId(seatId).url(baseURL: baseURL)
         return authenticatedHTTPClient
            .getPublisher(request: url) 
            .tryMap(Mapper<Root<LiveUserProfile>>.map)
             .subscribe(on: scheduler)
              .eraseToAnyPublisher()
    }
    
    private func imLoginLoader(profile: Root<LiveUserProfile>) -> LiveProfileLoader {
        let info = V2TIMUserFullInfo()
        info.nickName = profile.data.name
        info.faceURL = profile.data.photo
        
        return imManager
            .setSelfInfoPublisher(info)
            .map { _ in profile }
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func showToastLiveUnderMaintenance() {
        window?.topViewController?.showToast(
            with: "Fitur ini sedang dalam maintenance",
            backgroundColor: .brightRed,
            verticalSpace: 100
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.window?.topNavigationController?.popViewController(animated: true)
        }
    }
}
