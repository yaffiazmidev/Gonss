import UIKit
import KipasKipasDirectMessage
import KipasKipasPaymentInAppPurchase
import KipasKipasNetworking 

protocol IBalanceMianInteractor: AnyObject {
    func requestBalanceDetsil()
    func requestBalanceGrade() 
}

class BalanceMianInteractor: IBalanceMianInteractor {
    
    private let presenter: IBalanceMianPresenter
    private let network: DataTransferService
    
    
    init(presenter: IBalanceMianPresenter, network: DataTransferService) {
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
//            self.presenter.presentBalanceDetail(with: result) 
            
            switch result {
            case .failure(let error):
                print("Error: Failed to get my coin - \(error.message ?? "")") 
            case .success(let response):
                self.presenter.presentBalanceDetail(with: result)
            }
        }
    }
    
    func requestBalanceGrade() {
        let endpoint: Endpoint<RemoteBalancePoints?> = Endpoint(
            path: "balance/currency/consumption-points",
            method: .get
        )
        
        network.request(with: endpoint) { [weak self] result in
             guard let self = self else { return }
            self.presenter.presentBalanceGrade(with: result)
        }
    }
    
     
       
}
