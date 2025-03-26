//
//  OrderPurchaseTabAllInteractor.swift
//  KipasKipas
//
//  Created by NOOR on 26/01/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import Foundation
import Combine

typealias OrderPurchaseTabAllInteractable = OrderPurchaseTabAllBusinessLogic & OrderPurchaseTabAllDataStore

protocol OrderPurchaseTabAllBusinessLogic {
	
	func doRequest(_ request: OrderPurchaseTabAllModel.Request)
}

protocol OrderPurchaseTabAllDataStore {
	var dataSource: OrderPurchaseTabAllModel.DataSource { get set }
}

final class OrderPurchaseTabAllInteractor: Interactable, OrderPurchaseTabAllDataStore {
	
	var dataSource: OrderPurchaseTabAllModel.DataSource
    private var subscriptions: AnyCancellable?
    private var subscriptionsComplete: AnyCancellable?
	private var presenter: OrderPurchaseTabAllPresentationLogic
	private var network: OrderNetworkModel = OrderNetworkModel()
	
	init(viewController: OrderPurchaseTabAllDisplayLogic?, dataSource: OrderPurchaseTabAllModel.DataSource) {
		self.dataSource = dataSource
		self.presenter = OrderPurchaseTabAllPresenter(viewController)
	}
}


// MARK: - OrderPurchaseTabAllBusinessLogic
extension OrderPurchaseTabAllInteractor: OrderPurchaseTabAllBusinessLogic {
	
	func doRequest(_ request: OrderPurchaseTabAllModel.Request) {
		DispatchQueue.global(qos: .userInitiated).async {
			
			switch request {
				
			case .getOrderPurchaseTabAll(let page):
				self.getOrderPurchaseTab(.getOrderPurchaseTabAll(page: page))
			case .getOrderPurchaseTabProcess(let page):
				self.getOrderPurchaseTab(.getOrderPurchaseTabProcess(page: page))
			case .getOrderPurchaseTabWaiting(let page):
				self.getOrderPurchaseTab(.getOrderPurchaseTabWaiting(page: page))
			case .getOrderPurchaseTabShipping(let page):
				self.getOrderPurchaseTab(.getOrderPurchaseTabShipping(page: page))
			case .getOrderPurchaseTabUnpaid(let page):
				self.getOrderPurchaseTab(.getOrderPurchaseTabUnpaid(page: page))
			case .getOrderPurchaseTabComplete(let page):
				self.getOrderPurchaseTab(.getOrderPurchaseTabComplete(page: page))
			case	.getOrderPurchaseTabCancel(let page):
				self.getOrderPurchaseTab(.getOrderPurchaseTabCancel(page: page))
            case .completeOrder(let id):
                self.completeOrder(id)
            }
		}
	}
}


// MARK: - Private Zone
private extension OrderPurchaseTabAllInteractor {
	
	func getOrderPurchaseTab(_ endpoint: TransactionEndpoint) {
		subscriptions = network.getOrderTransaction(endpoint).sink { (complete) in
			switch complete {
			case .failure(let error): print(error.localizedDescription)
			case .finished: break
			}
		} receiveValue: { [weak self] (model: StatusOrderResult) in
			
			guard let validTotalOrder = model.data?.totalElements else { return }
			
			self?.dataSource.totalOrder.send(validTotalOrder)
			
			self?.presenter.presentResponse(.orderPurchase(result: model))
		}
	}
    
    func completeOrder(_ id: String) {
        let network = OrderNetworkModel()
        
        subscriptionsComplete = network.completeOrder(.completeOrder(id: id))
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .failure(let error):
                    print(error.localizedDescription)
                case .finished:
                    print("finished tracking shipmen")
                }
            }) { (model: DefaultResponse) in
                self.presenter.presentResponse(.completeOrder(result: model))
        }
    }
}
