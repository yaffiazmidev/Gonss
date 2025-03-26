import UIKit
import KipasKipasDirectMessage
import KipasKipasShared
import KipasKipasNetworking

public enum ConversationUIComposer {
    
    public struct ToBeDeletedDependencies {
        public let baseURL: String
        public let token: String
        
        public init(baseURL: String, token: String) {
            self.baseURL = baseURL
            self.token = token
        }
    }
    
    public struct Loaders {
        let paidChatPriceLoader: (String) -> PaidChatPriceLoader
        let paidSessionBalanceLoader: (String) -> PaidSessionBalanceLoader
        let chatSessionLoader: (ChatChannelParam, ChatParam) -> ChatSessionLoader
        let confirmationSetDiamondLoader: (ChatParam) -> ConfirmationSetDiamondLoader
        let notificationLoader: (ChatPushNotificationParam) -> OneSignalChatNotificationLoader
        let chatProfileLoader: (String) -> ChatProfileLoader
        let allowCallLoader: (AllowCallParam) -> AllowCallLoader

        public init(
            paidChatPriceLoader: @escaping (String) -> PaidChatPriceLoader,
            paidSessionBalanceLoader: @escaping (String) -> PaidSessionBalanceLoader,
            chatSessionLoader: @escaping (ChatChannelParam, ChatParam) -> ChatSessionLoader,
            confirmationSetDiamondLoader: @escaping (ChatParam) -> ConfirmationSetDiamondLoader,
            notificationLoader: @escaping (ChatPushNotificationParam) -> OneSignalChatNotificationLoader,
            chatProfileLoader: @escaping (String) -> ChatProfileLoader,
            allowCallLoader: @escaping (AllowCallParam) -> AllowCallLoader
        ) {
            self.paidChatPriceLoader = paidChatPriceLoader
            self.paidSessionBalanceLoader = paidSessionBalanceLoader
            self.chatSessionLoader = chatSessionLoader
            self.confirmationSetDiamondLoader = confirmationSetDiamondLoader
            self.notificationLoader = notificationLoader
            self.chatProfileLoader = chatProfileLoader
            self.allowCallLoader = allowCallLoader
        }
    }
    
    public struct Events {
        let onTapProfile: (String?) -> Void
        let onTapHashtag: (String?) -> Void
        let onTapCamera: (@escaping (KKMediaItem) -> Void) -> Void
        let onTapNewChat: ([TXIMMessage]) -> Void
        
        public init(
            onTapProfile: @escaping (String?) -> Void,
            onTapHashtag: @escaping (String?) -> Void,
            onTapCamera: @escaping (@escaping (KKMediaItem) -> Void) -> Void,
            onTapNewChat: @escaping ([TXIMMessage]) -> Void
        ) {
            self.onTapProfile = onTapProfile
            self.onTapHashtag = onTapHashtag
            self.onTapCamera = onTapCamera
            self.onTapNewChat = onTapNewChat
        }
    }
    
    public static func composeConversationWith(
        authToken: String,
        user: TXIMUser,
        callService: DirectMessageCallServiceManager,
        toBeDeletedDependencies: ToBeDeletedDependencies,
        oneSignalAppId: String,
        loaders: Loaders,
        events: Events,
        messages: [TXIMMessage]
    ) -> ConversationViewController {
        
        let paidChatPriceAdapter = PaidChatPriceInteractorAdapter(
            loader: loaders.paidChatPriceLoader
        )
        let paidSessionBalanceAdapter = PaidSessionBalanceInteractorAdapter(
            loader: loaders.paidSessionBalanceLoader
        )
        let chatSessionAdapter = ChatSessionInteractorAdapter(
            loader: loaders.chatSessionLoader
        )
        let confirmationSetDiamondAdapter = ConfirmationSetDiamondInteractorAdapter(
            loader: loaders.confirmationSetDiamondLoader
        )
        let notificationAdapter = OneSignalNotificationInteractorAdapter(
            oneSignalAppId: oneSignalAppId,
            loader: loaders.notificationLoader
        )
        let chatProfileAdapter = ChatProfileInteractorAdapter(loader: loaders.chatProfileLoader)
        let allowCallAdapter = AllowCallInteractorAdapter(
            loader: loaders.allowCallLoader
        )

        let controller = ConversationViewController(
            handleTapPatnerProfile: events.onTapProfile,
            handleTapHashtag: events.onTapHashtag,
            showCameraPhotoVideo: events.onTapCamera,
            handleTapForward: events.onTapNewChat
        )
        
        let network: DataTransferService = DIContainer.shared.apiAUTHDTS(baseUrl: APIConstants.shared.baseUrl, authToken: authToken)
        
        let interactor = ConversationInteractor(
            paidChatPriceAdapter: paidChatPriceAdapter,
            paidSessionBalanceAdapter: paidSessionBalanceAdapter,
            chatSessionAdapter: chatSessionAdapter,
            confirmationSetDiamondAdapter: confirmationSetDiamondAdapter,
            notificationAdapter: notificationAdapter,
            chatProfileAdapter: chatProfileAdapter,
            allowCallAdapter: allowCallAdapter,
            serviceManager: callService,
            userID: user.userID,
            name: user.nickName,
            avatar: user.faceURL,
            isVerified: user.isVerified,
            forwardMessages: messages)
        
        controller.router = ConversationRouter(
            controller: controller,
            baseUrl: toBeDeletedDependencies.baseURL,
            authToken: toBeDeletedDependencies.token
        )
        controller.interactor = interactor
        interactor.delegate = controller
        interactor.network = network
        
        return controller
    }
}
