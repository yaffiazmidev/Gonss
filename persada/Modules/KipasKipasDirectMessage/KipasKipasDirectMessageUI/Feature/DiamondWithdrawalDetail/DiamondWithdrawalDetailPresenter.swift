import UIKit
import KipasKipasDirectMessage

#warning("[BEKA] Remove this")
import KipasKipasNetworking

protocol IDiamondWithdrawalDetailPresenter {
    typealias CompletionHandler<T> = Swift.Result<T, DataTransferError>
    
    func presentHistoryDetail(with result: CompletionHandler<RemoteCurrencyHistoryDetail?>)
}

class DiamondWithdrawalDetailPresenter: IDiamondWithdrawalDetailPresenter {
	weak var controller: IDiamondWithdrawalDetailViewController?
	
	init(controller: IDiamondWithdrawalDetailViewController) {
		self.controller = controller
	}
    
    func presentHistoryDetail(with result: CompletionHandler<RemoteCurrencyHistoryDetail?>) {
        switch result {
        case .failure(let error):
            controller?.displayError(message: error.message ?? "")
        case .success(let response):
            controller?.displayHistoryDetail(data: response?.data)
        }
    }
}
