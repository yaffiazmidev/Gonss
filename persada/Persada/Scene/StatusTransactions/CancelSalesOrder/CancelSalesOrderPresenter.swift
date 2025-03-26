//
//  CancelSalesOrderPresenter.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 03/02/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import Foundation

protocol CancelSalesOrderPresentationLogic {
	func presentResponse(_ response: CancelSalesOrderModel.Response)
}

final class CancelSalesOrderPresenter: Presentable {
	private weak var viewController: CancelSalesOrderDisplayLogic?
	
	init(_ viewController: CancelSalesOrderDisplayLogic?) {
		self.viewController = viewController
	}
}


// MARK: - CancelSalesOrderPresentationLogic
extension CancelSalesOrderPresenter: CancelSalesOrderPresentationLogic {
	
	func presentResponse(_ response: CancelSalesOrderModel.Response) {
		
		switch response {
			
		case .cancelOrder(let data):
			presentCancelOrder(data)
		case .reasons(let result):
			self.presentReasons(result)
		}
	}
}


// MARK: - Private Zone
private extension CancelSalesOrderPresenter {
	
	func presentCancelOrder(_ data: DefaultResponse) {
		
		viewController?.displayViewModel(.cancelOrder(viewModel: data))
	}
	
	func presentReasons(_ result: DeclineOrderResult) {
		
		guard let validData = result.data else { return }
		
		viewController?.displayViewModel(.reasons(viewModel: validData))
	}
}
