import UIKit
import KipasKipasDirectMessage
#warning("[BEKA] Remove this")
import KipasKipasNetworking

protocol IDiamondWithdrawalHistoryInteractor: AnyObject {
    var requestPage: Int { get set }
    var totalPage: Int { get set }
    
    func requestWithdrawalDiamondHistory()
}

class DiamondWithdrawalHistoryInteractor: IDiamondWithdrawalHistoryInteractor {
    
    private let presenter: IDiamondWithdrawalHistoryPresenter
    private let network: DataTransferService
    var requestPage: Int = 0
    var totalPage: Int = 0
    
    init(presenter: IDiamondWithdrawalHistoryPresenter, network: DataTransferService) {
        self.presenter = presenter
        self.network = network
    }
    
    func requestWithdrawalDiamondHistory() {
        let endpoint: Endpoint<RemoteCurrencyHistory?> = Endpoint(
            path: "balance/currency/history", method: .get,
            queryParameters: [
                "currencyType": "DIAMOND",
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
            
            self.presenter.presentWithdrawalDiamondHistory(with: result)
        }
    }
}
