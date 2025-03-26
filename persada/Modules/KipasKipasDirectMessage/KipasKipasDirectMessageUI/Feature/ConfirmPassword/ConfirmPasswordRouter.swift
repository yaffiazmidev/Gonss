import KipasKipasDirectMessage
#warning("[BEKA] Remove this")
import KipasKipasNetworking

protocol IConfirmPasswordRouter {
	// do someting...
}

class ConfirmPasswordRouter: IConfirmPasswordRouter {
    weak var controller: ConfirmPasswordViewController?
    
    init(controller: ConfirmPasswordViewController?) {
        self.controller = controller
    }
}

extension ConfirmPasswordRouter {
    static func create(baseUrl: String, authToken: String, completion: @escaping () -> Void) -> ConfirmPasswordViewController {
        let controller = ConfirmPasswordViewController()
        let router = ConfirmPasswordRouter(controller: controller)
        let presenter = ConfirmPasswordPresenter(controller: controller)
        let network: DataTransferService = DIContainer.shared.apiAUTHDTS(baseUrl: baseUrl, authToken: authToken)
        let interactor = ConfirmPasswordInteractor(presenter: presenter, network: network)
        controller.router = router
        controller.interactor = interactor
        controller.dismissAction = completion
        
        return controller
    }
}
