//
//  DetailOfBalanceInteractor.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 15/03/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class DetailOfBalanceInteractor {

	let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
	private let disposeBag = DisposeBag()
	let balanceUseCase = Injection.init().provideSaldoUseCase()
	
	func getBalance(id: String) -> Observable<TransactionProductResult> {
		return balanceUseCase.gettDetailBalance(id: id).subscribeOn(concurrentBackground).observeOn(MainScheduler.init())
	}
}

