//
//  DetailOfBalancePresenter.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 15/03/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class DetailOfBalancePresenter {
	
	
	private let disposeBag = DisposeBag()
	private let router : DetailOfBalanceRouter!
	private let interactor = DetailOfBalanceInteractor()
	
	var balanceDataSource = BehaviorRelay<TransactionProduct?>(value: nil)
	var balance: Driver<TransactionProduct?> {
		return balanceDataSource.asDriver()
	}
	
	init(_ router: DetailOfBalanceRouter) {
		self.router = router
	}
	
	func fetchDetailOfBalance(_ id: String) {
		interactor.getBalance(id: id).subscribe { (result) in
			if let validData = result.data {
				self.balanceDataSource.accept(validData)
			}
		} onError: { erro in
			print(erro.localizedDescription)
		}.disposed(by: disposeBag)

	}
}
