import UIKit
import KipasKipasDirectMessage
#warning("[BEKA] Remove this")
import KipasKipasNetworking

protocol ICoinPurchaseDetailPresenter {
    typealias CompletionHandler<T> = Swift.Result<T, DataTransferError>
    
    func presentHistoryDetail(with result: CompletionHandler<RemoteCurrencyHistoryDetail?>)
}

class CoinPurchaseDetailPresenter: ICoinPurchaseDetailPresenter {
	weak var controller: ICoinPurchaseDetailViewController?
	
	init(controller: ICoinPurchaseDetailViewController) {
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
