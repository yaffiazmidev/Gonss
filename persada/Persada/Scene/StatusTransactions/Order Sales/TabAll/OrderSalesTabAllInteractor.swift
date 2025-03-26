//
//  OrderSalesTabAllInteractor.swift
//  KipasKipas
//
//  Created by NOOR on 21/01/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import Foundation
import Combine

typealias OrderSalesTabAllInteractable = OrderSalesTabAllBusinessLogic & OrderSalesTabAllDataStore

protocol OrderSalesTabAllBusinessLogic {
	
	func doRequest(_ request: OrderSalesTabAllModel.Request)
}

protocol OrderSalesTabAllDataStore {
	var dataSource: OrderSalesTabAllModel.DataSource { get set }
}

final class OrderSalesTabAllInteractor: Interactable, OrderSalesTabAllDataStore {
	
	var dataSource: OrderSalesTabAllModel.DataSource
	private var saleSubscriptions: AnyCancellable?
	private var shipSubscriptions: AnyCancellable?
	private var presenter: OrderSalesTabAllPresentationLogic
	private var network: OrderNetworkModel = OrderNetworkModel()
	
	init(viewController: OrderSalesTabAllDisplayLogic?, dataSource: OrderSalesTabAllModel.DataSource) {
		self.dataSource = dataSource
		self.presenter = OrderSalesTabAllPresenter(viewController)
	}
}


// MARK: - OrderSalesTabAllBusinessLogic
extension OrderSalesTabAllInteractor: OrderSalesTabAllBusinessLogic {
	
	func doRequest(_ request: OrderSalesTabAllModel.Request) {
		DispatchQueue.global(qos: .userInitiated).async {
			
			switch request {
			case .getOrderSalesTabNew(let page):
				self.getOrderSales(.getOrderSalesTabNew(page: page))
			case .getOrderSalesTabProcess(let page):
				self.getOrderSales(.getOrderSalesTabProcess(page: page))
			case .getOrderSalesTabShipping(let page):
				self.getOrderSales(.getOrderSalesTabShipping(page: page))
			case .getOrderSalesTabComplete(let page):
				self.getOrderSales(.getOrderSalesTabComplete(page: page))
			case .getOrderSalesTabCancel(let page):
				self.getOrderSales(.getOrderSalesTabCancel(page: page))
			case .requestPickUp(let service, let id):
				self.requestPickUp(service, id)
			}
		}
	}
}


// MARK: - Private Zone
private extension OrderSalesTabAllInteractor {
	
	func getOrderSales(_ endpoint: TransactionEndpoint) {
		
		shipSubscriptions = network.getOrderTransaction(endpoint).sink { (completion) in
			switch completion {
			case .failure(let error): print(error.localizedDescription)
			case .finished: break
			}
		} receiveValue: { [weak self] (result: StatusOrderResult) in
			guard let self = self, let totalItem = result.data?.totalElements else { return }
			
			self.dataSource.totalOrder.send(totalItem)
			
			self.presenter.presentResponse(.orderSales(result: result))
		}
	}
	
	func requestPickUp(_ service: String, _ id: String) {
		let network = ShipmentNetworkModel()
		
		saleSubscriptions = network.requestPickUp(.requestPickUp(serviceName: service, id: id)).sink { (completion) in
			switch completion {
			case .failure(let error): print(error.localizedDescription)
			case .finished: break
			}
		} receiveValue: { [weak self] (model) in
			self?.presenter.presentResponse(.pickUp(result: model))
		}
	}
}
