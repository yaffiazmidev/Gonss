import UIKit
import KipasKipasDirectMessage
import KipasKipasNetworking

public enum FoldListUIComposer {
    public static func composeFoldListWith(
        isPaid:Bool,
        userId: String,
        authToken:String,
        userSig: String,
        completion:@escaping (String, String, String, Bool, Bool) -> Void
    ) -> UIViewController {
        let controller = FoldListController(
            userId: userId,
            userSig: userSig,
            completion: completion
        )
         
        let network: DataTransferService = DIContainer.shared.apiAUTHDTS(baseUrl: APIConstants.shared.baseUrl, authToken: authToken)
        let interactor = FoldListInteractor(isPaidOnly: isPaid)
        interactor.delegate = controller
        interactor.network =  network
        interactor.authToken = authToken
        controller.interactor = interactor
        
         
        return controller
    }
}
