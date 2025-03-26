import UIKit
import KipasKipasDirectMessage
#warning("[BEKA] Remove this")
import KipasKipasNetworking

protocol ICoinPurchaseDetailInteractor: AnyObject {
    func requestHistoryDetail(id: String)
}

class CoinPurchaseDetailInteractor: ICoinPurchaseDetailInteractor {
    
    private let presenter: ICoinPurchaseDetailPresenter
    private let network: DataTransferService
    
    init(presenter: ICoinPurchaseDetailPresenter, network: DataTransferService) {
        self.presenter = presenter
        self.network = network
    }
    
    func requestHistoryDetail(id: String) {
        let endpoint: Endpoint<RemoteCurrencyHistoryDetail?> = Endpoint(
            path: "balance/currency/history/\(id)",
            method: .get
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            
            self.presenter.presentHistoryDetail(with: result)
        }
    }
}
