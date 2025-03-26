//
//  DonationListPresenter.swift
//  KipasKipas
//
//  Created by DENAZMI on 05/02/23.
//

import UIKit

protocol IDonationListPresenter {
    typealias CompletionResult<T> = Swift.Result<T, DataTransferError>
	
    func presentDonation(with result: CompletionResult<RemoteDonation?>)
}

class DonationListPresenter: IDonationListPresenter {
	weak var controller: IDonationListViewController?
	
	init(controller: IDonationListViewController) {
		self.controller = controller
	}
    
    func presentDonation(with result: CompletionResult<RemoteDonation?>) {
        switch result {
        case .success(let response):
            controller?.display(donations: response?.data?.content ?? [])
        case .failure(let error):
            controller?.displayError(message: error.message)
        }
    }
}
