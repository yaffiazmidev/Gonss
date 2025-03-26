import UIKit
import KipasKipasDirectMessage
import SendbirdChatSDK
#warning("[BEKA] Remove this")
import KipasKipasNetworking

protocol IPaidDirectMessageRankRouter {
    func navigateToConversation(channel: GroupChannel, timestampStorage: TimestampStorage, targetMessageForScrolling: BaseMessage?, handleTapPatnerProfile: @escaping (String?) -> Void)
}

class PaidDirectMessageRankRouter: IPaidDirectMessageRankRouter {
    
    weak var controller: PaidDirectMessageRankViewController?
    let baseUrl: String
    let authToken: String
    
    private let serviceManager: DirectMessageCallServiceManager
    
    init(
        controller: PaidDirectMessageRankViewController,
        baseUrl: String,
        authToken: String,
        serviceManager: DirectMessageCallServiceManager
    ) {
        self.controller = controller
        self.baseUrl = baseUrl
        self.authToken = authToken
        self.serviceManager = serviceManager
    }
    
    func navigateToConversation(channel: GroupChannel, timestampStorage: TimestampStorage, targetMessageForScrolling: BaseMessage?, handleTapPatnerProfile: @escaping (String?) -> Void) {
        let vc = UIViewController()
        vc.view.backgroundColor = .red
        controller?.push(vc)
    }
}

extension PaidDirectMessageRankRouter {
    static func create(baseUrl: String, authToken: String, serviceManager: DirectMessageCallServiceManager, handleTapPatnerProfile: @escaping (String?) -> Void, handleTapHashtag: @escaping (String?) -> Void) -> PaidDirectMessageRankViewController {
        let controller = PaidDirectMessageRankViewController(handleTapPatnerProfile: handleTapPatnerProfile, handleTapHashtag: handleTapHashtag)
        let router = PaidDirectMessageRankRouter(controller: controller, baseUrl: baseUrl, authToken: authToken, serviceManager: serviceManager)
        let presenter = PaidDirectMessageRankPresenter(controller: controller)
        let network = DIContainer.shared.apiAUTHDTS(baseUrl: baseUrl, authToken: authToken)
        let interactor = PaidDirectMessageRankInteractor(presenter: presenter, network: network)
        controller.interactor = interactor
        controller.router = router
        return controller
    }
}
