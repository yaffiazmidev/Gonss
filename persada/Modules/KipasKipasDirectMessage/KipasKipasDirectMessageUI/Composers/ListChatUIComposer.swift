import UIKit
import KipasKipasDirectMessage
import KipasKipasNetworking

public enum ListChatUIComposer {
    public static func composeListChatWith(
        userId: String,
        isPaidOnly: Bool,
        completion: @escaping (TXIMUser) -> Void
    ) -> ChatViewController {
        
        let controller = ChatViewController()
        let presenter = ChatPresenter(
            controller: controller
        )
         
        let interactor = ChatInteractor(
            isPaidOnly: isPaidOnly,
            presenter: presenter
        )
        controller.isPaidOnly = isPaidOnly
        controller.completion = completion
        controller.interactor = interactor
        
        return controller
    }
}
