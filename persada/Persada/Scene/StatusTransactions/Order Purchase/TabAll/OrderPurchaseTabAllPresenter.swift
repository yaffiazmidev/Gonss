//
//  OrderPurchaseTabAllPresenter.swift
//  KipasKipas
//
//  Created by NOOR on 26/01/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import Foundation

protocol OrderPurchaseTabAllPresentationLogic {
	func presentResponse(_ response: OrderPurchaseTabAllModel.Response)
}

final class OrderPurchaseTabAllPresenter: Presentable {
	private weak var viewController: OrderPurchaseTabAllDisplayLogic?
	
	init(_ viewController: OrderPurchaseTabAllDisplayLogic?) {
		self.viewController = viewController
	}
}


// MARK: - OrderPurchaseTabAllPresentationLogic
extension OrderPurchaseTabAllPresenter: OrderPurchaseTabAllPresentationLogic {
	
	func presentResponse(_ response: OrderPurchaseTabAllModel.Response) {
		
		switch response {
			
		case .orderPurchase(let result):
			presentOrderPurchase(result)
        case .completeOrder(let result):
            presentCompleteOrder(result)
        }
	}
}


// MARK: - Private Zone
private extension OrderPurchaseTabAllPresenter {
	
	func presentOrderPurchase(_ result: StatusOrderResult) {
		
		guard let data =  result.data?.content else { return }
		let validData = data.compactMap { OrderCellViewModel(value: $0) }
		
		viewController?.displayViewModel(.orderPurchase(viewModel: validData, lastPage: result.data?.totalPages ?? 0))
	}
    
    func presentCompleteOrder(_ result: DefaultResponse) {
        viewController?.displayViewModel(.completeOrder(viewModel: result))
    }
}
