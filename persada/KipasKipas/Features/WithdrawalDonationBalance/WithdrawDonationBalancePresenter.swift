//
//  WithdrawDonationBalancePresenter.swift
//  KipasKipas
//
//  Created by DENAZMI on 21/02/23.
//

import UIKit

protocol IWithdrawDonationBalancePresenter {
    typealias CompletionResult<T> = Swift.Result<T, DataTransferError>
    
    func presentWithdrawalBank(with result: CompletionResult<RemoteDonationWithdrawBank?>)
    func presentWithdrawalGopay(with result: CompletionResult<RemoteDonationWithdrawGopay?>)
}

class WithdrawDonationBalancePresenter: IWithdrawDonationBalancePresenter {
	weak var controller: IWithdrawDonationBalanceViewController?
	
	init(controller: IWithdrawDonationBalanceViewController) {
		self.controller = controller
	}
    
    func presentWithdrawalBank(with result: CompletionResult<RemoteDonationWithdrawBank?>) {
        switch result {
        case .failure(let error):
            controller?.displayErrorWithdrawal(message: error.message)
        case .success(_):
            controller?.displaySuccessWithdrawalBank()
        }
    }
    
    func presentWithdrawalGopay(with result: CompletionResult<RemoteDonationWithdrawGopay?>) {
        switch result {
        case .failure(let error):
            controller?.displayErrorWithdrawal(message: error.message)
        case .success(let response):
            guard let payout = response?.data?.payouts?.first else {
                controller?.displayErrorWithdrawal(message: "Data not found..")
                return
            }
            
            controller?.displaySuccessWithdrawalGopay(payout: payout)
        }
    }
}
