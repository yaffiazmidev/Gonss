import UIKit
import KipasKipasDirectMessage
#warning("[BEKA] Remove this")
import KipasKipasNetworking

protocol IDiamondWithdrawalInteractor: AnyObject {
    func requestBalanceDetsil()
    func withdrawalDiamond(type:String,bankAccountId: String, amount: Int)
    func currenyConverter(value: Int)
}

class DiamondWithdrawalInteractor: IDiamondWithdrawalInteractor {
    
    private let presenter: IDiamondWithdrawalPresenter
    private let network: DataTransferService
    
    init(presenter: IDiamondWithdrawalPresenter, network: DataTransferService) {
        self.presenter = presenter
        self.network = network
    }
    
    func requestBalanceDetsil() {
        let endpoint: Endpoint<RemoteBalanceCurrency?> = Endpoint(
            path: "balance/currency/details",
            method: .get
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            self.presenter.presentBalanceDetail(with: result)
        }
    }
    
    func withdrawalDiamond(type:String, bankAccountId: String, amount: Int) {
        let endpoint: Endpoint<RemoteWithdrawalDiamond?> = Endpoint(
            path: "balance/currency/withdraw",
            method: .post,
            bodyParamaters: ["diamondType":type,"bankAccountId": bankAccountId, "amountDiamond": "\(amount)"]
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard self != nil else { return }
            
            self?.presenter.presentWithdrawal(with: result)
        }
    }
    
    func currenyConverter(value: Int) {
        let endpoint: Endpoint<RemoteCurrencyConverter?> = Endpoint(
            path: "balance/currency/conversion/diamond",
            method: .get,
            queryParameters: ["qty": value]
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard self != nil else { return }
            
            self?.presenter.presentConverter(with: result)
        }
    }
}
