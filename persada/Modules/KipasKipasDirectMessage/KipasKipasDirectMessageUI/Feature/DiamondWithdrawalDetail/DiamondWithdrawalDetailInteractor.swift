import UIKit
import KipasKipasDirectMessage
import KipasKipasShared

#warning("[BEKA] Remove this")
import KipasKipasNetworking

protocol IDiamondWithdrawalDetailInteractor: AnyObject {
    func requestHistoryDetail(id: String)
    func requestMyCurreny()
}

class DiamondWithdrawalDetailInteractor: IDiamondWithdrawalDetailInteractor {
    
    private let presenter: IDiamondWithdrawalDetailPresenter
    private let network: DataTransferService
    
    init(presenter: IDiamondWithdrawalDetailPresenter, network: DataTransferService) {
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
    
    func requestMyCurreny() {
        
        struct Root: Codable {
            var data: RemoteBalanceCurrencyDetail?
            var code: String?
            var message: String?
        }
        
        let endpoint: Endpoint<Root?> = Endpoint(
            path: "balance/currency/details",
            method: .get
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print("Error: Failed to get my coin - \(error.message ?? "")")
            case .success(let response):
                KKCache.common.save(integer: response?.data?.coinAmount ?? 0, key: .coin)
                KKCache.common.save(integer: response?.data?.diamondAmount ?? 0, key: .diamond)
                KKCache.common.save(integer: response?.data?.liveDiamondAmount ?? 0, key: .liveDiamondAmount)
            }
        }
    }
}
