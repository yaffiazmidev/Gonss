import UIKit
import KipasKipasDirectMessage
#warning("[BEKA] Remove this")
import KipasKipasNetworking

protocol IDiamondWithdrawalHistoryPresenter {
    typealias CompletionHandler<T> = Swift.Result<T, DataTransferError>
    
    func presentWithdrawalDiamondHistory(with result: CompletionHandler<RemoteCurrencyHistory?>)
}

class DiamondWithdrawalHistoryPresenter: IDiamondWithdrawalHistoryPresenter {
	weak var controller: IDiamondWithdrawalHistoryViewController?
	
	init(controller: IDiamondWithdrawalHistoryViewController) {
		self.controller = controller
	}
    
    func presentWithdrawalDiamondHistory(with result: CompletionHandler<RemoteCurrencyHistory?>) {
        switch result {
        case .failure(let error):
            controller?.displayError(messages: error.localizedDescription)
        case .success(let response):
            controller?.displayWithdrawalDiamondHistory(contents: response?.data?.content ?? [])
        }
    }
}
