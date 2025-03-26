//
//  FilterDonationCategoryPresenter.swift
//  KipasKipas
//
//  Created by DENAZMI on 24/02/23.
//

import UIKit

protocol IFilterDonationCategoryPresenter {
    typealias CompletionResult<T> = Swift.Result<T, DataTransferError>
    
    func presentCategories(with result: CompletionResult<RemoteDonationCategory?>)
}

class FilterDonationCategoryPresenter: IFilterDonationCategoryPresenter {
	weak var controller: IFilterDonationCategoryViewController?
	
	init(controller: IFilterDonationCategoryViewController) {
		self.controller = controller
	}
    
    func presentCategories(with result: CompletionResult<RemoteDonationCategory?>) {
        switch result {
        case .success(let response):
            controller?.display(categories: response?.data ?? [])
        case .failure(let error):
            controller?.displayError(message: error.message)
        }
    }
}
