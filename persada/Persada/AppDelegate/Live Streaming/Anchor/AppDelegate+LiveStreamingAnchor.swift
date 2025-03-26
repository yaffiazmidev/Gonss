import UIKit
import TUICore
import Combine
import KipasKipasLiveStream
import KipasKipasLiveStreamiOS
import KipasKipasTRTC
import KipasKipasNetworking
import KipasKipasNetworkingUtils
import KipasKipasCall

// MARK: SceneDelegate + LiveStreamingAnchor
var showLiveStreamAnchor: (() -> Void)?

extension AppDelegate {
    private func makeCoinBalanceLoader() -> LiveCoinBalanceLoader {
        let url = LiveStreamEndpoint.coinBalance.url(baseURL: baseURL)
        
        return authenticatedHTTPClient
            .getPublisher(request: url)
            .dispatchOnMainQueue()
            .tryMap(Mapper<Root<LiveCoinBalance>>.map)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
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
    
    private func goToHomeViewController() {
        TUICallStateViewModel.shared.isLiving = false
        dismiss(until: NewHomeController.self)
    }
    
    private func makeLiveStreamCreationLoader(roomId: String, roomName: String) -> LiveCreateLoader {
        let request = LiveStreamEndpoint.create(roomId: roomId, roomName: roomName).url(baseURL: baseURL)
        return authenticatedHTTPClient
            .getPublisher(request: request)
            .tryMap(Mapper<Root<LiveStreamCreation>>.map)
            .subscribe(on: scheduler)
            .handleEvents(receiveOutput: { output in
                if output.code == "1000" {
                    TUICallStateViewModel.shared.isLiving = true
                }
            })
            .eraseToAnyPublisher()
    }
    
    private func makeLiveStreamingRoomDismissalLoader(_ summary: LiveRoomSummaryRequest) -> LiveSummaryLoader {
        TUICallStateViewModel.shared.isLiving = false
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
            self.window?.topViewController?.dismiss(animated: true)
        }
    }
}

// MARK: Shared
extension AppDelegate {
    func makeLiveStreamingAnchorViewController() -> UIViewController {
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
            onDailyRankingClicked: { [weak self] in
                self?.showDailyRankViewController(isAnchor: true, selectNavLeft: $0, sendGiftAction: $1)
            },
            dismiss: goToHomeViewController
        )
        anchorLiveRoom.delegate = controller
        return controller
    }
    
    func makeLiveStreamValidationLoader() -> LiveValidationLoader {
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
}
