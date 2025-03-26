import UIKit
import TUICore
import Combine
import KipasKipasLiveStream
import KipasKipasLiveStreamiOS
import KipasKipasTRTC
import KipasKipasNetworking

// MARK: SceneDelegate + LiveStreamingAnchor
extension SceneDelegate {
    func makeLiveStreamingAnchorViewController() -> AnchorViewController {
        let anchorLiveRoom = AnchorLiveRoomManager()
        let controller = AnchorLiveUIComposer.composeAnchorUI(
            liveRoom: anchorLiveRoom, 
            profileLoader: makeProfileLoader,
            createRoomLoader: makeLiveStreamCreationLoader,
            validationLoader: makeLiveStreamValidationLoader,
            dismissalLoader: makeLiveStreamingRoomDismissalLoader,
            audienceListLoader: makeMemberListLoader, 
            topSeatsLoader: makeLiveTopSeatsLoader,
            classicGiftLoader: makeListGiftLoader,
            coinBalanceLoader: makeCoinBalanceLoader,
            onAudienceClicked: showAudienceListViewController,
            onDailyRankingClicked: showDailyRankViewController,
            dismiss: {
                print("[BEKA] dismissed")
                #warning("[BEKA] implement this on integration with KipasKipas")
            }
        )
        anchorLiveRoom.delegate = controller
        
        return controller
    }
    
    private func showAudienceListViewController(groupId: String, ownerId: String,giftAction:@escaping ()->Void,faqAction:@escaping ()->Void) {
        let controller = AudienceListUIComposer.composeAudienceListUIWith(
            loader: makeMemberListLoader(request:),
            classicGiftLoader: makeListGiftLoader,
            coinBalanceLoader: makeCoinBalanceLoader,
            groupId: groupId,
            ownerId: ownerId, 
            audienceShowTips: false,
            selection: { _ in },
            giftAction: giftAction,
            faqAction: faqAction
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
    
    private func makeCoinBalanceLoader() -> LiveCoinBalanceLoader {
        let url = LiveStreamEndpoint.coinBalance.url(baseURL: baseURL)
        
        return authenticatedHTTPClient
            .getPublisher(request: url)
            .dispatchOnMainQueue()
            .tryMap(Mapper<Root<LiveCoinBalance>>.map)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
//    private func makeMemberListLoader(request: LiveStreamAudienceListRequest) -> ListAudienceLoader {
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
    
    private func makeLiveStreamCreationLoader(roomId: String, roomName: String) -> LiveCreateLoader {
        let request = LiveStreamEndpoint.create(roomId: roomId, roomName: roomName).url(baseURL: baseURL)
        return authenticatedHTTPClient
            .getPublisher(request: request)
            .tryMap(Mapper<Root<LiveStreamCreation>>.map)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    
    private func makeLiveStreamValidationLoader() -> LiveValidationLoader {
        let request = LiveStreamEndpoint.validation.url(baseURL: baseURL)
        return authenticatedHTTPClient
            .getPublisher(request: request)
            .tryMap(Mapper<Root<LiveStreamValidation>>.map)
            .mapError({ error in
                let errorCode = MapperError.map(error).code
                switch errorCode {
                case "4110": return .insufficientFollowers
                default: return .general
                }
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makeLiveStreamingRoomDismissalLoader(_ summary: LiveRoomSummaryRequest) -> LiveSummaryLoader {
        let request = LiveStreamEndpoint.dismissRoom(summary).url(baseURL: baseURL)
        return authenticatedHTTPClient
            .getPublisher(request: request)
            .tryMap(Mapper<Root<LiveStreamSummary>>.map)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
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
                    .flatMap { [weak self] profile -> AnyPublisher<Root<LiveUserProfile>, Error> in
                        guard let self = self else {
                            return Empty(completeImmediately: true)
                                .eraseToAnyPublisher()
                        }
                        return self.imLoginLoader(profile: profile)
                    }
                    .subscribe(on: scheduler)
            }
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
