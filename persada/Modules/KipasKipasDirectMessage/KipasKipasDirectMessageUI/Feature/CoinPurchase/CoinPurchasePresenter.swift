import UIKit
import KipasKipasDirectMessage
import KipasKipasPaymentInAppPurchase
#warning("[BEKA] Remove this")
import KipasKipasNetworking

protocol ICoinPurchasePresenter {
    typealias CompletionHandler<T> = Swift.Result<T, DataTransferError>
    typealias InAppPurchaseCompletion<T> = Swift.Result<T, Error>
    func presentBalanceDetail(with result:CompletionHandler<RemoteBalanceCurrency?>)
    func presentCoinProduct(with result: CompletionHandler<RemoteCoinPurchaseProduct?>)
    func presentCoinInApp(with result: InAppPurchaseCompletion<InAppPurchaseProductsResponse>)
    func presentCoinPurchaseTransaction(with result: InAppPurchaseCompletion<InAppPurchasePaymentTransaction>)
    func presentCoinPurchaseValidate(with result: InAppPurchaseCompletion<CoinInAppPurchaseValidateData>, transactionId: String)
    func presentUUID(with uuid: String?)
//    func presentCurrencyInfo(with result: CompletionHandler<RemoteCurrencyInfo?>)
}

class CoinPurchasePresenter: ICoinPurchasePresenter {
     
    
    weak var controller: ICoinPurchaseViewController?
    
    init(controller: ICoinPurchaseViewController) {
        self.controller = controller
    }
    
    func presentBalanceDetail(with result: CompletionHandler<RemoteBalanceCurrency?>) {
        switch result {
        case.failure(let error):
            controller?.displayError(message: error.message ?? error.localizedDescription)
        case .success(let response):
            guard let balance = response?.data else { return }
            controller?.displayBalanceDetail(data: balance )
        }
    }
    
    func presentCoinProduct(with result: CompletionHandler<RemoteCoinPurchaseProduct?>) {
        switch result {
        case.failure(let error):
            controller?.displayError(message: error.message ?? error.localizedDescription)
        case .success(let response):
            controller?.displayCoinProduct(data: response?.data ?? [])
        }
    }
    
    func presentCoinInApp(with result: InAppPurchaseCompletion<InAppPurchaseProductsResponse>) {
        switch result {
        case.failure(let error):
            controller?.displayError(message: error.localizedDescription)
        case .success(let response):
            controller?.displayCoinInApp(data: response.products)
        }
    }
    
    func presentCoinPurchaseTransaction(with result: InAppPurchaseCompletion<InAppPurchasePaymentTransaction>) {
        switch result {
        case.failure(let error):
            if (error as NSError).code == 2 {
                controller?.displayCoinPurchaseUserCancel()
                return
            }
            
            controller?.displayError(message: error.localizedDescription)
        case .success(let transaction):
            switch(transaction.transactionState) {
            case .purchased:
                controller?.displayCoinPurchaseTransaction(data: transaction)
                InAppPurchasePendingManager.instance.add(with: InAppPurchasePending(transactionId: transaction.transactionIdentifier ?? "", type: .coin))
                
            case .failed:
                controller?.displayError(message: transaction.error?.localizedDescription ?? "")
                
            default:
                break
            }
        }
    }
    
    func presentCoinPurchaseValidate(with result: InAppPurchaseCompletion<CoinInAppPurchaseValidateData>, transactionId: String) {
        switch result {
        case .failure(let error):
            if let error = error as? CoinInAppPurchaseValidateError {
                if error == .alreadyValidated {
                    InAppPurchasePendingManager.instance.remove(transaction: transactionId)
                }
            }
            controller?.displayError(message: error.localizedDescription)
        case .success(let data):
            InAppPurchasePendingManager.instance.remove(transaction: transactionId)
            controller?.displayCoinPurchaseValidate(data: data)
        }
    }
    
    func presentUUID(with uuid: String?) {
        guard let uuid = uuid else {
            controller?.displayError(message: "UUID not found")
            return
        }
        
        controller?.displayUUID(uuid: uuid)
    }
}
