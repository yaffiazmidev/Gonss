//
//  TransactionRepository.swift
//  KipasKipas
//
//  Created by NOOR on 19/01/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift

protocol TransactionRepository {
	func getSalesOrder() -> Observable<StatusOrderResult>
	func getHistoryOfBalance() -> Observable<BalanceResult>
	func orderProduct(_ request: TransactionEndpoint, parameter: ParameterOrder) -> Observable<PaymentResponse>
}

final class TransactionRepositoryImpl: TransactionRepository {
	
	typealias StatusOrderInstance = ( RxTransactionNetworkModel) -> TransactionRepository
	
	fileprivate let remote: RxTransactionNetworkModel
	
	private init(remote: RxTransactionNetworkModel) {
		self.remote = remote
	}
	
	static var sharedInstance: StatusOrderInstance = { remoteRepo in
		return TransactionRepositoryImpl(remote: remoteRepo)
	}
	
	func getSalesOrder() -> Observable<StatusOrderResult> {
		self.remote.getSalesOrder()
	}
	
	func getHistoryOfBalance() -> Observable<BalanceResult> {
		return self.remote.getHistoryWithdrawal()
	}
	
	func orderProduct(_ request: TransactionEndpoint, parameter: ParameterOrder) -> Observable<PaymentResponse> {
		return remote.orderProduct(request, parameter: parameter)
	}
}
