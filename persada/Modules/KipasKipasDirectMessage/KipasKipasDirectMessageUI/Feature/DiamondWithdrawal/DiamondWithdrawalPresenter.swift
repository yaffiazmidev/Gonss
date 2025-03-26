import UIKit
import KipasKipasDirectMessage
#warning("[BEKA] Remove this")
import KipasKipasNetworking

protocol IDiamondWithdrawalPresenter {
    typealias CompletioHandler<T> = Swift.Result<T, DataTransferError>
    func presentBalanceDetail(with result: CompletioHandler<RemoteBalanceCurrency?>)
    func presentConverter(with result: CompletioHandler<RemoteCurrencyConverter?>)
    func presentWithdrawal(with result: CompletioHandler<RemoteWithdrawalDiamond?>)
}

class DiamondWithdrawalPresenter: IDiamondWithdrawalPresenter {
	weak var controller: IDiamondWithdrawalViewController?
	
	init(controller: IDiamondWithdrawalViewController) {
		self.controller = controller
	}
    
    func presentBalanceDetail(with result: CompletioHandler<RemoteBalanceCurrency?>) {
        switch result {
        case .failure(let error):
            controller?.displayErrorBalanceDetail(message: error.message ?? "")
//            controller?.displayError(message: error.message ?? error.localizedDescription)
        case .success(let response):
            guard let balance = response?.data else { return }
            controller?.displayBalanceDetail(data: balance )
        }
    }
    
    func presentConverter(with result: CompletioHandler<RemoteCurrencyConverter?>) {
        switch result {
        case .failure(let error):
            print(error.localizedDescription)
        case .success(let response):
            guard let unitPrice = response?.data.unitPrice, let totalPrice = response?.data.totalPrice else { return }
            controller?.displayConverter(unitPrice: unitPrice, totalPrice: totalPrice)
        }
    }
    
    func presentWithdrawal(with result: CompletioHandler<RemoteWithdrawalDiamond?>) {
        switch result {
        case .failure(let error):
            controller?.displayErrorWithdrawal(message: .get(.withdrawalLimitPerDay))
        case .success(let response):
            guard let item = response?.data else { return }
            controller?.displayWithdrawal(value: item)
        }
    }
}
