import UIKit
import Combine
import SendbirdChatSDK
import KipasKipasNetworking
import KipasKipasDirectMessage
import KipasKipasDirectMessageUI

// MARK: Loaders
extension SceneDelegate {
    private func makeDirectMessageRegisterLoader(_ param: DirectMessageRegisterParam) -> DirectMessageRegisterLoader {
        let request = DirectMessageEndpoint.register(param).url(baseURL: baseURL)
        
        return authenticatedHTTPClient
            .getPublisher(request: request)
            .tryMap(Mapper<EmptyData>.map)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
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
extension SceneDelegate {
    func makeDirectMessageViewController() -> UIViewController {
        let authData = tokenStore.retrieve()
        let userData = loggedInUserStore.retrieve()
        
        let controller = DirectMessageUIComposer.composeDirectMessageWith(
            userId: userData?.accountId ?? "",
            token: authData?.accessToken ?? "",
            registerLoader: makeDirectMessageRegisterLoader,
            childPages: [
                .init(controller: makeChatViewController(isPaidOnly: false), title: "Semua"),
                .init(controller: makeChatViewController(isPaidOnly: true), title: "Berbayar")
            ],
            onTapNewChat: showNewChatListViewController
        )
        return controller
    }
    
    private func makeChatViewController(isPaidOnly: Bool) -> UIViewController {
        let userData = loggedInUserStore.retrieve()
        
        let controller = ListChatUIComposer.composeListChatWith(
            userId: userData?.accountId ?? "",
            isPaidOnly: isPaidOnly,
            createGroupChannelLoader: makeDirectMessageRegisterLoader,
            completion: navigateToConversationViewController
        )
        return controller
    }
    
    private func makeConversationViewController(channel: GroupChannel, isPaidMessage: Bool) -> UIViewController {
        let authData = tokenStore.retrieve()
        
        let loaders = ConversationUIComposer.Loaders(
            paidChatPriceLoader: makePaidChatPriceLoader,
            paidSessionBalanceLoader: makePaidSessionBalanceLoader,
            chatSessionLoader: makeChatSessionLoader,
            sendChatLoader: makeSendChatLoader, 
            confirmationSetDiamondLoader: makeConfirmationSetDiamondLoader,
            notificationLoader: makeOneSignalChatNotificationLoader,
            chatProfileLoader: makeChatProfileLoader,
            allowCallLoader: makeAllowCallLoader
        )
        
        let events = ConversationUIComposer.Events(
            onTapProfile: {
            print("[BEKA] on tap profile", $0)
        }, onTapHashtag: {
            print("[BEKA] on tap hashtag", $0)
        }, onTapCamera: { _ in }
        )
        
        let controller = ConversationUIComposer.composeConversationWith(
            channel: channel,
            callService: serviceManager,
            toBeDeletedDependencies: .init(
                baseURL: baseURL.absoluteString,
                token: authData?.accessToken ?? ""
            ),
            parameters: .init(
                oneSignalAppId: oneSignalAppId,
                isPaidMessage: isPaidMessage,
                lastMessage: channel.lastMessage
            ),
            loaders: loaders,
            events: events
        )
        
        return controller
    }
    
    private func makeNewChatListViewController() -> UIViewController {
        let userData = loggedInUserStore.retrieve()
        let controller = NewChatUIComposer.composeNewChatWith(
            userId: userData?.accountId ?? "",
            createGroupChannelLoader: makeDirectMessageRegisterLoader,
            listFollowingLoader: makeListFollowingLoader,
            searchUserLoader: makeSearchAccountByUsernameLoader,
            completion: navigateToConversationViewController
        )
        return controller
    }
}

// MARK: Routing
private extension SceneDelegate {
    func showNewChatListViewController() {
        let destination = makeNewChatListViewController()
        destination.modalPresentationStyle = .overFullScreen
        presentOnce(destination)
    }
    
    func navigateToConversationViewController(with result: Swift.Result<GroupChannel, Error>) {
        switch result {
        case let .success(channel):
            #warning("[BEKA] get back to this later")
            let isPaidMessage = channel.getCachedMetaData()["is_paid_chat"] == "true"
            let destination = makeConversationViewController(channel: channel, isPaidMessage: isPaidMessage)
            destination.hidesBottomBarWhenPushed = true
            
            pushOnce(destination)
            
        case .failure:
            self.window?.topViewController?.showToast(with: "Channel tidak ditemukan, silahkan coba lagi...")
        }
    }
}
