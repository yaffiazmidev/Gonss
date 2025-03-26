import UIKit
import KipasKipasDirectMessage
#warning("[BEKA] Remove this")
import KipasKipasNetworking

protocol IConfirmPasswordInteractor: AnyObject {
    func verify(with password: String)
}

class ConfirmPasswordInteractor: IConfirmPasswordInteractor {
    
    private let presenter: IConfirmPasswordPresenter
    private let network: DataTransferService
    
    init(presenter: IConfirmPasswordPresenter, network: DataTransferService) {
        self.presenter = presenter
        self.network = network
    }
    
    func verify(with password: String) {
        let endpoint: Endpoint<RemoteConfirmPassword?> = Endpoint(
            path: "balance/verify",
            method: .post,
            queryParameters: ["password": password]
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard self != nil else { return }
            
            self?.presenter.presentPasswordConfirm(with: result)
        }
    }
}
