//
//  BalanceRepository.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 23/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift

protocol BalanceRepository {
	func getSaldo() -> Observable<SaldoResult>
	func getBalance(id: String) -> Observable<TransactionProductResult>
}

class BalanceRepositoryImpl: BalanceRepository {
	
	fileprivate let remote: RxBalanceNetworkModel
	typealias SaldoInstance = ( RxBalanceNetworkModel) -> BalanceRepository
	
	private init(remote: RxBalanceNetworkModel) {
		self.remote = remote
	}
	
	static let sharedInstance: SaldoInstance = { remoteRepo in
		return BalanceRepositoryImpl( remote: remoteRepo)
	}
	
	func getSaldo() -> Observable<SaldoResult> {
		return remote.getSaldo()
	}
	
	func getBalance(id: String) -> Observable<TransactionProductResult> {
		return remote.getDetailBalance(id: id)
	}
}
