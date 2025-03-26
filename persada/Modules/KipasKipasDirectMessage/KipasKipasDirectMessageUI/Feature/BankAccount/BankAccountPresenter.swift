import Foundation
import KipasKipasDirectMessage
#warning("[BEKA] Remove this")
import KipasKipasNetworking

protocol IBankAccountPresenter {
    typealias CompletioHandler<T> = Swift.Result<T, DataTransferError>
    func presentBank(with result: CompletioHandler<RemoteBankAccount?>)
}

class BankAccountPresenter: IBankAccountPresenter {
    weak var controller: BankAccountController?
    
    init(controller: BankAccountController) {
        self.controller = controller
    }

    func presentBank(with result: CompletioHandler<RemoteBankAccount?>) {
        switch result {
        case .failure(let error):
            print(error.localizedDescription)
        case .success(let response):
            guard let bank = response?.data?.bank, let gopay = response?.data?.gopay else {
                return
            }
            
            controller?.displayBankAccount(bank: bank, gopay: gopay)
        }
    }
}
