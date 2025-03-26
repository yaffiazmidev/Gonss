//
//  BalanceUseCase.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 23/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift

protocol BalanceUseCase {
	func getSaldo() -> Observable<SaldoResult>
	func gettDetailBalance(id: String) -> Observable<TransactionProductResult>
}

class BalanceInteractorRx: BalanceUseCase {
	private let repository: BalanceRepository

	required init(repository: BalanceRepository) {
		self.repository = repository
	}
	
	func getSaldo() -> Observable<SaldoResult> {
		return repository.getSaldo()
	}
	
	func gettDetailBalance(id: String) -> Observable<TransactionProductResult> {
		self.repository.getBalance(id: id)
	}
}
