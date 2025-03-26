import UIKit
import Combine
import SendbirdChatSDK
import KipasKipasNetworking
import KipasKipasDirectMessage
import KipasKipasDirectMessageUI

var showDirectMessage: (() -> Void)?
var showIMConversation: ((TXIMUser) -> Void)?

// MARK: Loaders
extension AppDelegate {
    func configureDirectMessageFeature() {
        KipasKipas.showDirectMessage = navigateToDirectMessageViewController
        KipasKipas.showIMConversation = navigateToConversationController
    }
    
    private func makeListFollowingLoader(_ param: ListFollowingParam) -> ListFollowingLoader {
        let request = DirectMessageEndpoint.following(param).url(baseURL: baseURL)
        
        return authenticatedHTTPClient
            .getPublisher(request: request)
            .tryMap(Mapper<Root<DirectMessageFollowing>>.map)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makeSearchAccountByUsernameLoader(_ username: String) -> SearchAccountByUsernameLoader {
        let request = DirectMessageEndpoint.searchUser(username: username).url(baseURL: baseURL)
        
        return authenticatedHTTPClient
            .getPublisher(request: request)
            .tryMap(Mapper<Root<[RemoteSearchUserData]>>.map)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makePaidChatPriceLoader(_ userId: String) -> PaidChatPriceLoader {
        let request = DirectMessageEndpoint.paidChatPrice(userId: userId).url(baseURL: baseURL)
        
        return authenticatedHTTPClient
            .getPublisher(request: request)
            .tryMap(Mapper<Root<PaidChatPrice>>.map)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makePaidSessionBalanceLoader(_ channelId: String) -> PaidSessionBalanceLoader {
        let request = DirectMessageEndpoint.paidSessionBalance(channelURL: channelId).url(baseURL: baseURL)
        
        return authenticatedHTTPClient
            .getPublisher(request: request)
            .tryMap(Mapper<Root<PaidSessionBalance>>.map)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makeChatSessionLoader(channel: ChatChannelParam, chat: ChatParam) -> ChatSessionLoader {
        let request = DirectMessageEndpoint.paidChatToggle(channel: channel, chat: chat).url(baseURL: baseURL)
        
        return authenticatedHTTPClient
            .getPublisher(request: request)
            .tryMap(Mapper<ChatSession>.map)
            .mapError({ error in
                let mappedError = MapperError.map(error)
                return .general(.init(errorCode: mappedError.code))
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makeSendChatLoader(_ param: ChatParam) -> SendChatLoader {
        let request = DirectMessageEndpoint.sendChat(param).url(baseURL: baseURL)
        return authenticatedHTTPClient
            .getPublisher(request: request)
            .tryMap(Mapper<Root<ChatSession>>.map)
            .mapError({ error in
                let mappedError = MapperError.map(error)
                
                if let errorData = mappedError.data,
                   let errorResponse = try? JSONDecoder().decode(
                    Root<RemoteErrorConfirmSetDiamondData>.self,
                    from: errorData
                   )
                {
                    return .customWithObject(errorResponse.data)
                } else {
                    return .general(.init(errorCode: mappedError.code))
                }
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makeConfirmationSetDiamondLoader(_ param: ChatParam) -> ConfirmationSetDiamondLoader {
        let request = DirectMessageEndpoint.confirmSetDiamond(param).url(baseURL: baseURL)
        return authenticatedHTTPClient
            .getPublisher(request: request)
            .tryMap(Mapper<Root<RemoteSetDiamondData>>.map)
            .mapError({ error in
                let mappedError = MapperError.map(error)
                return .general(.init(errorCode: mappedError.code))
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makeOneSignalChatNotificationLoader(_ param: ChatPushNotificationParam) -> OneSignalChatNotificationLoader {
        let request = DirectMessageEndpoint.sendPushNotification(param: param, apiKey: oneSignalApiKey)
            .url(
                baseURL: oneSignalBaseURL
            )
        return httpClient
            .getPublisher(request: request)
            .tryMap(Mapper<OneSignalChatNotification>.map)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }

    private func makeChatProfileLoader(_ username: String) -> ChatProfileLoader {
        let request = DirectMessageEndpoint.profile(username: username).url(baseURL: baseURL)
        return authenticatedHTTPClient
            .getPublisher(request: request)
            .tryMap(Mapper<Root<ChatProfile>>.map)
            .mapError({ error in
                let mappedError = MapperError.map(error)
                return .general(.init(errorCode: mappedError.code))
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }

    private func makeAllowCallLoader(_ param: AllowCallParam) -> AllowCallLoader {
        let request = DirectMessageEndpoint.allowCall(param).url(baseURL: baseURL)

        return authenticatedHTTPClient
            .getPublisher(request: request)
            .tryMap(Mapper<Root<AllowCall>>.map)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
}

// MARK: View-Controllers Factory
extension AppDelegate {
    func makeDirectMessageViewController() -> UIViewController {
        let authData = tokenStore.retrieve()
        let userId = loggedInUserStore.retrieve()?.accountId ?? ""
        let userSig = TencentUserSig.genTestUserSig(userId)
        let authToken = getToken() ?? ""
        
        let controller = DirectMessageUIComposer.composeDirectMessageWith(
            userId: userId,
            userSig: userSig,
            authToken: authToken,
            childPages: [
                .init(controller: makeChatViewController(isPaidOnly: false), title: "Semua"),
                .init(controller: makeChatViewController(isPaidOnly: true), title: "Berbayar")
            ],
            onTapNewChat: showNewChatListViewController,
            onTapFoldList:navigateToFoldListController
        )
        return controller
    }
    
    private func makeChatViewController(isPaidOnly: Bool) -> ChatViewController {
        let userData = loggedInUserStore.retrieve() 
        let controller = ListChatUIComposer.composeListChatWith(
            userId: userData?.accountId ?? "",
            isPaidOnly: isPaidOnly) { [weak self] user in
                DispatchQueue.main.async {
                    self?.navigateToConversationController(user: user)
                }
            }
        return controller
    }
    
    private func makeConversationController(user: TXIMUser, messages: [TXIMMessage]) -> ConversationViewController {
        let authData = tokenStore.retrieve()
        
        let loaders = ConversationUIComposer.Loaders(
            paidChatPriceLoader: makePaidChatPriceLoader,
            paidSessionBalanceLoader: makePaidSessionBalanceLoader,
            chatSessionLoader: makeChatSessionLoader,
            confirmationSetDiamondLoader: makeConfirmationSetDiamondLoader,
            notificationLoader: makeOneSignalChatNotificationLoader,
            chatProfileLoader: makeChatProfileLoader,
            allowCallLoader: makeAllowCallLoader
        )
        
        let events = ConversationUIComposer.Events(onTapProfile: navigateToProfileViewControllerHiddenBottomBar, onTapHashtag: navigateToHashtag, onTapCamera: showCameraPhotoVideoViewController, onTapNewChat: { [weak self] messages in
            self?.showNewChatListViewController(with: messages) {
                NotificationCenter.default.post(name: .init("forwardMessages"), object: user.userID)
            }
        })
        
        let controller = ConversationUIComposer.composeConversationWith(
            authToken: getToken() ?? "",
            user: user,
            callService: serviceManager,
            toBeDeletedDependencies: .init(
                baseURL: baseURL.absoluteString,
                token: authData?.accessToken ?? ""
            ),
            oneSignalAppId: oneSignalAppId,
            loaders: loaders,
            events: events,
            messages: messages
        )
        
        return controller
    }
    
    private func makeNewChatListViewController(with messages: [TXIMMessage], completion:(() -> Void)? = nil) -> UIViewController {
        let userData = loggedInUserStore.retrieve()
        let controller = NewChatUIComposer.composeNewChatWith(
            userId: userData?.accountId ?? "",
            listFollowingLoader: makeListFollowingLoader,
            searchUserLoader: makeSearchAccountByUsernameLoader,
            completion: { [weak self] user in
                completion?()
                self?.navigateToForwardConversationController(user: user, messages: messages)
            }
        )
        return controller
    }
}

// MARK: Routing
private extension AppDelegate {
    func navigateToFoldListController(isPaid: Bool) {
        let userId = loggedInUserStore.retrieve()?.accountId ?? ""
        let userSig = TencentUserSig.genTestUserSig(userId)
        let authToken = getToken() ?? ""
        let destination = FoldListUIComposer.composeFoldListWith(isPaid: isPaid,
                                                                 userId: userId,
                                                                 authToken: authToken,
                                                                 userSig: userSig,
            completion: { [weak self] userId, userName, avatar, isVerify, isPaid in
                let user = TXIMUser(userID: userId, userName: userName, faceURL: avatar, isVerified: isVerify)
                self?.navigateToConversationController(user: user)
            }
        )
        
        destination.hidesBottomBarWhenPushed = true
        pushOnce(destination)
    }
    
    func showNewChatListViewController() {
        let destination = makeNewChatListViewController(with: [])
        destination.modalPresentationStyle = .overFullScreen
        destination.hidesBottomBarWhenPushed = true
        presentOnce(destination)
    }
    
    func showNewChatListViewController(with messages: [TXIMMessage], completion:@escaping () -> Void) {
        let destination = makeNewChatListViewController(with: messages, completion: completion)
        destination.modalPresentationStyle = .overFullScreen
        destination.hidesBottomBarWhenPushed = true
        presentOnce(destination)
    }
    
    func navigateToConversationController(user: TXIMUser) {
        navigateToForwardConversationController(user: user)
    }
    
    func navigateToForwardConversationController(user: TXIMUser, messages: [TXIMMessage] = []) {
        let destination = makeConversationController(user: user, messages: messages)
        destination.hidesBottomBarWhenPushed = true
        
        guard let top = window?.topViewController else {
            return
        }
        
        if let topVC = top as? ConversationViewController, topVC.userID == destination.userID {
            return
        }
        
        let navigationController = UINavigationController(rootViewController: destination)
        presentWithSlideAnimation(navigationController)
    }
    
    func navigateToDirectMessageViewController() {
        let destination = makeDirectMessageViewController()
        destination.hidesBottomBarWhenPushed = true
        destination.configureDismissablePresentation(backIcon: .iconArrowLeft)
        
        let navigationController = UINavigationController(rootViewController: destination)
        presentWithSlideAnimation(navigationController)
    }
    
    func navigateToProfileViewControllerHiddenBottomBar(userId: String?) {
        guard let userId else {
            return
        }
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
    
    func navigateToHashtag(value: String?) {
        let destination = HashtagViewController(hashtag: value ?? "")
        destination.handleUpdateSelectedFeed = { feed in
            NotificationCenter.default.post(
                name: Notification.Name("handleUpdateHotNewsCellLikesFromProfileFeed"),
                object: nil,
                userInfo: [
                    "postId": feed.post?.id ?? "",
                    "feedId": feed.id ?? "",
                    "accountId": feed.account?.id ?? "",
                    "likes": feed.likes ?? 0,
                    "isLike": feed.isLike ?? false,
                    "comments": feed.comments ?? 0
                ]
            )
        }
        destination.hidesBottomBarWhenPushed = true
        pushOnce(destination)
    }
}
