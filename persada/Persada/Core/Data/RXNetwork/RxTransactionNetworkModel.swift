//
//  RxTransactionNetworkModel.swift
//  KipasKipas
//
//  Created by NOOR on 19/01/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import RxSwift

public final class RxTransactionNetworkModel {
	private let network: Network<BalanceResult>
	private let networkOrder: Network<PaymentResponse>
	
	init(network: Network<BalanceResult>, networkOrder: Network<PaymentResponse>) {
		self.network = network
		self.networkOrder = networkOrder
	}
	
	func getSalesOrder() -> Observable<StatusOrderResult> {
		let network = Network<StatusOrderResult>()
		return network.getItems(TransactionEndpoint.getOrderSalesTabAll.path, parameters: TransactionEndpoint.getOrderSalesTabAll.parameter
		)
	}
	
	func getHistoryWithdrawal() -> Observable<BalanceResult> {
		let endpoint = TransactionEndpoint.getHistoryWithdrawal
		return network.getItem(endpoint.path, parameters: endpoint.parameter, headers: endpoint.header as! [String: String])
	}
	
	func orderProduct(_ request: TransactionEndpoint, parameter: ParameterOrder) -> Observable<PaymentResponse> {
		let endpoint = TransactionEndpoint.orderProduct
		
		let validBody: Data = try! JSONEncoder().encode(parameter)
		
		return networkOrder.postItemNew(endpoint, body: validBody)
	}
}
