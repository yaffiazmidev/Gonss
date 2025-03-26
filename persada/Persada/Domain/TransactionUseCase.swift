//
//  TransactionUseCase.swift
//  KipasKipas
//
//  Created by NOOR on 19/01/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift

protocol TransactionUseCase {
	func getOrderSales() -> Observable<StatusOrderResult>
	func getNetworkHistoryOfBalance() -> Observable<BalanceResult>
	func orderProduct(_ request: TransactionEndpoint, parameter: ParameterOrder) -> Observable<PaymentResponse>
}

class TransactionInteratorRx: TransactionUseCase {
	
	private let repository: TransactionRepository

	init(repository: TransactionRepository) {
		self.repository = repository
	}

	func getOrderSales() -> Observable<StatusOrderResult> {
		return repository.getSalesOrder()
	}

	func getNetworkHistoryOfBalance() -> Observable<BalanceResult> {
		return repository.getHistoryOfBalance()
	}
	
	func orderProduct(_ request: TransactionEndpoint, parameter: ParameterOrder) ->Observable<PaymentResponse> {
		return repository.orderProduct(request, parameter: parameter)
	}
}
