import UIKit
import KipasKipasDirectMessage
#warning("[BEKA] Remove this")
import KipasKipasNetworking

protocol IConfirmPasswordPresenter {
    typealias CompletioHandler<T> = Swift.Result<T, DataTransferError>
        func presentPasswordConfirm(with result: CompletioHandler<RemoteConfirmPassword?>)
}

class ConfirmPasswordPresenter: IConfirmPasswordPresenter {
	weak var controller: IConfirmPasswordViewController?
	
	init(controller: IConfirmPasswordViewController) {
		self.controller = controller
	}
    
    func presentPasswordConfirm(with result: CompletioHandler<RemoteConfirmPassword?>) {
        switch result {
        case .failure(let error):
            let data = error.message ?? ""
            let decode = try? JSONDecoder().decode(RemoteDefaultError.self, from: data.data(using: .utf8)!)
            self.controller?.displayError(statusCode: decode?.code ?? "", message: decode?.message ?? "")
        case .success:
            self.controller?.displayConfirmation()
        }
    }
}
