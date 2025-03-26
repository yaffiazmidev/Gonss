import UIKit
import KipasKipasDirectMessage
#warning("[BEKA] Remove this")
import KipasKipasNetworking

protocol ICoinPurchaseHistoryPresenter {
    typealias CompletionHandler<T> = Swift.Result<T, DataTransferError>
    
    func presentPurchaseCoinHistory(with result: CompletionHandler<RemoteCurrencyHistory?>)
}

class CoinPurchaseHistoryPresenter: ICoinPurchaseHistoryPresenter {
    weak var controller: ICoinPurchaseHistoryViewController?
    
    init(controller: ICoinPurchaseHistoryViewController) {
        self.controller = controller
    }
    
    func presentPurchaseCoinHistory(with result: CompletionHandler<RemoteCurrencyHistory?>) {
        switch result {
        case .failure(let error):
            controller?.displayError(messages: error.localizedDescription)
        case .success(let response):
            controller?.displayPurchaseCoinHistory(contents: response?.data?.content ?? [])
        }
    }
}
