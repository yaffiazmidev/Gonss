//
//  DetailTransactionPresenter.swift
//  KipasKipas
//
//  Created by movan on 13/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

protocol DetailTransactionPresentationLogic {
	func presentResponse(_ response: DetailTransactionModel.Response)
}

final class DetailTransactionPresenter: Presentable {
	private weak var viewController: DetailTransactionDisplayLogic?
	
	init(_ viewController: DetailTransactionDisplayLogic?) {
		self.viewController = viewController
	}
}


// MARK: - DetailTransactionPresentationLogic
extension DetailTransactionPresenter: DetailTransactionPresentationLogic {
	
	func presentResponse(_ response: DetailTransactionModel.Response) {
		
		switch response {
			
		case .products(let result) :
			presentDetail(result)
		case .processOrder(let result):
			presentCompletePurchase(result)
		case .pickUp(let result):
			presentPickUp(result)
		case .barcode(let result):
			presentBarcode(result)
		case .trackingShipment(let result):
			presentShipment(result)
        case .productById(let result):
            presentProduct(result)
        case .completeOrder(let result):
            presentCompleteOrder(result)
		}
	}
}


// MARK: - Private Zone
private extension DetailTransactionPresenter {
	
	func presentDetail(_ result: TransactionProductResult) {
		
		guard let validData = result.data else { return }
		
		viewController?.displayViewModel(.detail(viewModel: validData))
	}
	
	func presentCompletePurchase(_ result: DefaultResponse) {
		viewController?.displayViewModel(.processOrder(viewModel: result))
	}

	func presentPickUp(_ result: RequestPickUpResponse) {
		viewController?.displayViewModel(.pickUp(viewModel: result))
	}
	
	func presentBarcode(_ result: Data) {
		viewController?.displayViewModel(.barcode(viewModel: result))
	}
	
	func presentShipment(_ result: TrackingShipmentResult) {
		viewController?.displayViewModel(.trackingShipment(viewModel: result))
	}
    
    func presentProduct(_ result: ProductDetailResult) {
        viewController?.displayViewModel(.productById(viewModel: result))
    }
    
    func presentCompleteOrder(_ result: DefaultResponse) {
        viewController?.displayViewModel(.completeOrder(viewModel: result))
    }
}
