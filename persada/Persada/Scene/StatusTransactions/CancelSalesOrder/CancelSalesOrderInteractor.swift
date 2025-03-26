//
//  CancelSalesOrderInteractor.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 03/02/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import Foundation
import Combine

typealias CancelSalesOrderInteractable = CancelSalesOrderBusinessLogic & CancelSalesOrderDataStore

protocol CancelSalesOrderBusinessLogic {
	
	func doRequest(_ request: CancelSalesOrderModel.Request)
}

protocol CancelSalesOrderDataStore {
	var dataSource: CancelSalesOrderModel.DataSource { get set }
}

final class CancelSalesOrderInteractor: Interactable, CancelSalesOrderDataStore {
	
	var dataSource: CancelSalesOrderModel.DataSource
	private var subscriptions = Set<AnyCancellable>()
	private var presenter: CancelSalesOrderPresentationLogic
	private let network = OrderNetworkModel()
	
	init(viewController: CancelSalesOrderDisplayLogic?, dataSource: CancelSalesOrderModel.DataSource) {
		self.dataSource = dataSource
		self.presenter = CancelSalesOrderPresenter(viewController)
	}
}


// MARK: - CancelSalesOrderBusinessLogic
extension CancelSalesOrderInteractor: CancelSalesOrderBusinessLogic {
	
	func doRequest(_ request: CancelSalesOrderModel.Request) {
		DispatchQueue.global(qos: .userInitiated).async {
			
			switch request {
			case .cancelSalesOrder(let input):
				self.cancelSalesOrder(input)
			case .reasonDecline:
				self.reasonDecline()
			}
		}
	}
}


// MARK: - Private Zone
private extension CancelSalesOrderInteractor {
	
	func cancelSalesOrder(_ input: CancelSalesOrderInput) {
		
		network.postCancelSalesOrder(.cancelSalesOrder, input).sink { (completion) in
			switch completion {
			case .failure(let error): print(error.localizedDescription)
			case .finished: break
			}
		} receiveValue: { [weak self] (model: DefaultResponse) in
			self?.presenter.presentResponse(.cancelOrder(result: model))
		}.store(in: &subscriptions)
	}
	
	func reasonDecline() {
		network.getReasonDeclineOrder(.reasonDeclineOrder).sink { (completion) in
			switch completion {
			case .failure(let error): print(error.localizedDescription)
			case .finished: break
			}
		} receiveValue: { (model: DeclineOrderResult) in
			self.presenter.presentResponse(.reasons(result: model))
		}.store(in: &subscriptions)
	}
}
