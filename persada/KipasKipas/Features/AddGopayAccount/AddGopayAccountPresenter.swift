//
//  AddGopayAccountPresenter.swift
//  KipasKipas
//
//  Created by DENAZMI on 10/04/23.
//

import UIKit

protocol IAddGopayAccountPresenter {
    typealias CompletionResult<T> = Swift.Result<T, DataTransferError>
    
    func presentCheckGopayAccount(with result: CompletionResult<RemoteCheckGopayAccount?>)
}

class AddGopayAccountPresenter: IAddGopayAccountPresenter {
	weak var controller: IAddGopayAccountViewController?
	
	init(controller: IAddGopayAccountViewController) {
		self.controller = controller
	}
    
    func presentCheckGopayAccount(with result: CompletionResult<RemoteCheckGopayAccount?>) {
        switch result {
        case .success(let response):
            controller?.displayCheckGopay(account: response?.data)
        case .failure(let error):
            controller?.displayError(message: error.message, code: error.statusCode)
        }
    }
}
