import UIKit
import KipasKipasDirectMessage
import KipasKipasPaymentInAppPurchase
import KipasKipasNetworking

protocol IBalanceMianPresenter {
    typealias CompletionHandler<T> = Swift.Result<T, DataTransferError>
    func presentBalanceDetail(with result:CompletionHandler<RemoteBalanceCurrency?>)
    func presentBalanceGrade(with result:CompletionHandler<RemoteBalancePoints?>)
}

class BalanceMianPresenter: IBalanceMianPresenter {
     
    weak var controller: IBalanceMianViewController?
    
    var pointsData:RemoteBalancePointsData?
    
    init(controller: IBalanceMianViewController) {
        self.controller = controller
    }
    
    func presentBalanceDetail(with result: CompletionHandler<RemoteBalanceCurrency?>) {
        switch result {
        case .failure(let error):
               break
//            controller?.displayError(message: error.message ?? error.localizedDescription)
        case .success(let response):
            guard let balance = response?.data else { return }
            controller?.displayBalanceDetail(data: balance )
        }
    }
    
    func presentBalanceGrade(with result:CompletionHandler<RemoteBalancePoints?>){
        switch result {
        case.failure(let error):
            controller?.displayError(message: error.message ?? error.localizedDescription)
        case .success(let response):
            guard let data = response?.data else { return }
            controller?.displayBalanceGrade(data: data )
        }
    }
      
    
    
}
