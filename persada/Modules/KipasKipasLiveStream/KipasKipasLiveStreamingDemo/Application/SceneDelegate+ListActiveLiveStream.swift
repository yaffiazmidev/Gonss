import UIKit
import Combine
import KipasKipasShared
import KipasKipasNetworking
import KipasKipasLiveStream
import KipasKipasLiveStreamiOS
import TUICore
import ImSDK_Plus

class NavigationControllerPanable: UINavigationController, PanModalPresentable {

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
        return .contentHeight(320)
    }
    
    var allowsExtendedPanScrolling: Bool {
        return true
    }
}

extension SceneDelegate {
    func makeLiveStreamingListViewController() -> UIViewController {
        let presentationAdapter = ListActiveLiveStreamPresentationAdapter(
            profileLoader: makeProfileLoader,
            loader: makeListActiveLiveStreamLoader
        )
        let controller = LiveStreamingListViewController()
        
        controller.loadActiveLiveStreams = presentationAdapter.load
        
        let viewAdapter = ListActiveLiveStreamViewAdapter(
            controller: controller, 
            profileLoader: makeProfileLoader,
            seatProfileLoader: makeSeatProfileLoader, 
            audienceListLoader: makeMemberListLoader,
            topSeatsLoader: makeLiveTopSeatsLoader,
            followLoader: makeFollowLoader,
            unfollowLoader: makeUnfollowLoader,
            onClickShare: navShareController,
            listGiftLoader: makeListGiftLoader,
            coinBalanceLoader: makeCoinBalanceLoader,
            onClickAudience: showAudienceListViewController,
            onDailyRankClicked: showDailyRankViewController, 
            onUserImageClicked: { _ in },
            onKicked: showOnKickedPopUp, 
            onTapTopUpCoin: navigateToCoinPurchase
        )
        presentationAdapter.presenter = ListActiveLiveStreamPresenter(view: viewAdapter)
        
        return controller
    }
    
    private func showAudienceListViewController(groupId: String, ownerId: String,giftAction: @escaping ()->Void,faqAction: @escaping ()->Void) {
        let controller = AudienceListUIComposer.composeAudienceListUIWith(
            loader: makeMemberListLoader(request:),
            classicGiftLoader: makeListGiftLoader, 
            coinBalanceLoader: makeCoinBalanceLoader,
            groupId: groupId,
            ownerId: ownerId,
            audienceShowTips: false,
            selection: { _ in },
            giftAction:giftAction,
            faqAction:faqAction
        )
        let destination = NavigationControllerPanable(rootViewController: controller)
   
        window?.topViewController?.presentPanModal(destination)
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
    
//    private func makeMemberListLoader(request: LiveStreamAudienceListRequest) -> ListAudienceLoader {
//        return imManager
//            .getAudienceList(groupId: request.roomId, page: request.page)
//            .tryMap({ members in
//                return members
//                .sorted(by: { $0.joinTime < $1.joinTime })
//                .compactMap { .init(
//                    userId: $0.userID,
//                    username: $0.nickName ?? "",
//                    avatarURL: $0.faceURL ?? ""
//                )}
//                .filter { $0.userId != request.ownerId }
//            })
//            .subscribe(on: scheduler)
//            .eraseToAnyPublisher()
//    }
    
    private func makeLiveTopSeatsLoader(with roomId: String) -> LiveTopSeatLoader {
        let url = LiveStreamEndpoint.topSeat(roomId: roomId).url(baseURL: baseURL)
        
        return authenticatedHTTPClient
            .getPublisher(request: url)
            .dispatchOnMainQueue()
            .tryMap(Mapper<Root<[LiveTopSeat]>>.map)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
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
    
    private func makeListGiftLoader() -> ListGiftLoader {
        let url = LiveStreamEndpoint.gifts.url(baseURL: baseURL)
        
        return authenticatedHTTPClient
            .getPublisher(request: url)
            .dispatchOnMainQueue()
            .tryMap(Mapper<Root<[LiveGift]>>.map)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
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
        
        window?.topViewController?.present(destination, animated: true)
    }
    
    func navShareController(abc:[String:String]){ 
    }
    
    private func makeProfileLoader() -> LiveProfileLoader {
        let storedUser = loggedInUserStore.retrieve()
        
        struct UserIDNotFound: Error {}
        
        guard let userId = storedUser?.accountId else {
            return Fail(error: UserIDNotFound()).eraseToAnyPublisher()
        }
        
        let request = LiveStreamProfileEndpoint.profileByUserId(userId).url(baseURL: baseURL)
        return tuiLoginLoader(userId: userId)
            .flatMap { [authenticatedHTTPClient, scheduler] in
                return authenticatedHTTPClient
                    .getPublisher(request: request)
                    .tryMap(Mapper<Root<LiveUserProfile>>.map)
                    .flatMap { profile in
                        return self.imLoginLoader(profile: profile)
                    }
                    .subscribe(on: scheduler)
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
    
    private func tuiLoginLoader(userId: String) -> AnyPublisher<Void, Error> {
        return TUILogin
            .loginPublisher(userId: userId)
            .tryMap { _ in }
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
}
