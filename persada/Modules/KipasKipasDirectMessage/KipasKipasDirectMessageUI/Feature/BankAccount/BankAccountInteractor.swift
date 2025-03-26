import Foundation
import KipasKipasDirectMessage

#warning("[BEKA] Remove this")
import KipasKipasNetworking

protocol IBankAccountInteractor: AnyObject {
    func getBank()
}

class BankAccountInteractor: IBankAccountInteractor {
    
    private let presenter: IBankAccountPresenter
    private let network: DataTransferService
    
    init(presenter: IBankAccountPresenter, network: DataTransferService) {
        self.presenter = presenter
        self.network = network
    }
    
    func getBank() {
        let endpoint: Endpoint<RemoteBankAccount?> = Endpoint(
            path: "bankaccounts/all",
            method: .get,
            headerParamaters: ["version": "V2"],
            queryParameters: ["version": "V2"]
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard self != nil else { return }
            
            self?.presenter.presentBank(with: result)
        }
    }
}

public struct BankAccountItem {
    public let bankId: String
    public let username: String
    public let nameBank: String
    public let noRekening: String
    public let withdrawalFee: Int
    
    public init(bankId: String, username: String, nameBank: String, noRekening: String, withdrawalFee: Int) {
        self.bankId = bankId
        self.username = username
        self.nameBank = nameBank
        self.noRekening = noRekening
        self.withdrawalFee = withdrawalFee
    }
}
