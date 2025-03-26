import UIKit
import KipasKipasDirectMessage
#warning("[BEKA] Remove this")
import KipasKipasNetworking

protocol ICoinPurchaseHistoryInteractor: AnyObject {
    var requestPage: Int { get set }
    var totalPage: Int { get set }
    func requestCoinHistory()
}

class CoinPurchaseHistoryInteractor: ICoinPurchaseHistoryInteractor {
    
    private let presenter: ICoinPurchaseHistoryPresenter
    private let network: DataTransferService
    var requestPage: Int = 0
    var totalPage: Int = 0
    
    init(presenter: ICoinPurchaseHistoryPresenter, network: DataTransferService) {
        self.presenter = presenter
        self.network = network
    }
    
    func requestCoinHistory() {
        let endpoint: Endpoint<RemoteCurrencyHistory?> = Endpoint(
            path: "balance/currency/history", method: .get,
            queryParameters: [
                "currencyType": "COIN",
                "page": requestPage,
                "size": 10,
                "sort": "createAt,desc"
            ]
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            
            if case .success(let response) = result {
                self.totalPage = (response?.data?.totalPages ?? 0) - 1
            }
            
            self.presenter.presentPurchaseCoinHistory(with: result)
        }
    }
}
