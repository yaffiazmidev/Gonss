//
//  OrderSalesTabAllPresenter.swift
//  KipasKipas
//
//  Created by NOOR on 21/01/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import Foundation

protocol OrderSalesTabAllPresentationLogic {
	func presentResponse(_ response: OrderSalesTabAllModel.Response)
}

final class OrderSalesTabAllPresenter: Presentable {
	private weak var viewController: OrderSalesTabAllDisplayLogic?
	
	init(_ viewController: OrderSalesTabAllDisplayLogic?) {
		self.viewController = viewController
	}
}


// MARK: - OrderSalesTabAllPresentationLogic
extension OrderSalesTabAllPresenter: OrderSalesTabAllPresentationLogic {
	
	func presentResponse(_ response: OrderSalesTabAllModel.Response) {
		
		switch response {
			
		case .orderSales(let result):
			presentOrderSalesTabAll(result)
		case .pickUp(let result):
			self.presentPickUp(result)
		}
	}
}


// MARK: - Private Zone
private extension OrderSalesTabAllPresenter {
	
	func presentOrderSalesTabAll(_ result: StatusOrderResult) {
		
		guard let data = result.data?.content else { return }
		
		let validData: [OrderCellViewModel] = data.compactMap { OrderCellViewModel(value: $0)}
        
        let sortData = validData.sorted(by: {
            Date(milliseconds: Int64($0.modifyAt)).toString(format: "yyyy-MM-dd'T'HH:mm:ssZ") > Date(milliseconds: Int64($1.modifyAt)).toString(format: "yyyy-MM-dd'T'HH:mm:ssZ")
        })
		
		viewController?.displayViewModel(.orderSales(viewModel: sortData, lastPage: result.data?.totalPages ?? 0))
	}
	
	func presentPickUp(_ result: RequestPickUpResponse) {
		viewController?.displayViewModel(.pickUp(viewModel: result))
	}
}
