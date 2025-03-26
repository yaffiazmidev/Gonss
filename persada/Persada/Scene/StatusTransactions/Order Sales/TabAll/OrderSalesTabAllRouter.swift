//
//  OrderSalesTabAllRouter.swift
//  KipasKipas
//
//  Created by NOOR on 21/01/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import UIKit
import KipasKipasShared

protocol OrderSalesTabAllRouting {
	
	func routeTo(_ route: OrderSalesTabAllModel.Route)
}

final class OrderSalesTabAllRouter: Routeable {
	
	private weak var viewController: UIViewController?
	
	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
}


// MARK: - OrderSalesTabAllRouting
extension OrderSalesTabAllRouter: OrderSalesTabAllRouting {
	
	func routeTo(_ route: OrderSalesTabAllModel.Route) {
		DispatchQueue.main.async {
			switch route {
			
			case .dismiss:
				self.dismiss()
			case let .detailTransaction(data, term, title):
				self.detailTransaction(data, term, title)
			case .browser(let url):
				self.browser(url)
			case .trackingShipment(let id):
				self.trackingShipment(id)
			}
		}
	}
}


// MARK: - Private Zone
private extension OrderSalesTabAllRouter {
	
	func dismiss() {
		viewController?.dismiss(animated: true)
	}
	
	func detailTransaction(_ data: OrderCellViewModel, _ termsCondition: ProcessTermsCondition, _ title: String) {
		var dataSource = DetailTransactionModel.DataSource()
		dataSource.id = data.id
		dataSource.data = nil
		dataSource.dataTransaction = data
		dataSource.termsCondition = termsCondition
		dataSource.title = title
		if title == .get(.detailTransaction) && termsCondition.title == "" {
			let controller = DetailTransactionSalesCancelController(mainView: DetailTransactionSalesCancelView(), dataSource: dataSource)
			self.viewController?.navigationController?.push(controller)
		} else {
			let detailController = DetailTransactionSalesController(mainView: DetailTransactionSalesView(), dataSource: dataSource)
			
			self.viewController?.navigationController?.pushViewController(detailController, animated: true)
		}
	}
	
	func trackingShipment(_ id: String) {
		var datasource = TrackingShipmentModel.DataSource()
		datasource.id = id
		datasource.data = nil
		let trackingController = TrackingShipmentController(mainView: TrackingShipmentView(), dataSource: datasource)

		viewController?.navigationController?.pushViewController(trackingController, animated: false)
	}
	
	func browser(_ url: String) {
		let browserController = BrowserController(url: url, type: .general)
		
		viewController?.navigationController?.pushViewController(browserController, animated: false)
	}
}
