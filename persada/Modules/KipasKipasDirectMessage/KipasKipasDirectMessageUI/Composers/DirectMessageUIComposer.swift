import UIKit
import KipasKipasDirectMessage
import KipasKipasNetworking

public enum DirectMessageUIComposer {
    public static func composeDirectMessageWith(
        userId: String,
        userSig: String,
        authToken:String,
        childPages: [DirectMessageChildPage],
        onTapNewChat: @escaping () -> Void,
        onTapFoldList:@escaping (Bool) -> Void
    ) -> UIViewController {
        let controller = DirectMessageContainerViewController(
            userId: userId,
            userSig: userSig,
            childPages: childPages
        )
        
        let network: DataTransferService = DIContainer.shared.apiAUTHDTS(baseUrl: APIConstants.shared.baseUrl, authToken: authToken)
        
        let interactor = DirectMessageContainerInteractor()
        
        interactor.delegate = controller
        interactor.network =  network
        interactor.authToken = authToken
        
        controller.interactor = interactor
        controller.onTapNewChat = onTapNewChat
        controller.onTapFoldList = onTapFoldList
        return controller
    }
}
