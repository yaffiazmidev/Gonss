//
//  HistoryOfBalancePresenter.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 01/03/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class HistoryOfBalancePresenter: BasePresenter {
	weak var viewController: HistoryOfBalanceController?
	
	let disposeBag = DisposeBag()
	private let usecase: TransactionUseCase
	let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
	var lastPage: Int = 0
	var requestedPage: Int = 0
	var counterProduct: Int = 0
	var isDataEmpty: Bool = false

	let _loadingState = BehaviorRelay<Bool>(value: false)
	var loadingState: Driver<Bool> {
		return _loadingState.asDriver()
	}
	
	let balanceDatasource: BehaviorRelay<[Balance]> = BehaviorRelay<[Balance]>(value: [])
	
	init(_ viewController: HistoryOfBalanceController) {
		self.viewController = viewController
		self.usecase = Injection.init().provideTransactionUseCase()
	}
	
	func getNetworkHistoryOfBalance() {
		_loadingState.accept(true)
		return usecase.getNetworkHistoryOfBalance()
			.subscribeOn(self.concurrentBackground)
			.observeOn(MainScheduler.instance)
			.subscribe { result in
				self._loadingState.accept(false)
				if self.requestedPage == 0 {
					self.saveHistoryOfBalance(itemNetwork: result.data!.history!, page: self.requestedPage, currentData: self.balanceDatasource.value)
				} else {
					self.saveHistoryOfBalance(itemNetwork: result.data!.history!, page: self.requestedPage)
				}
				self.requestedPage += 1
			} onError: { error in
				self._errorMessage.accept(error.localizedDescription)
			}.disposed(by: disposeBag)
	}
	
	private func saveHistoryOfBalance(itemNetwork: [Balance], page: Int, currentData: [Balance]? = nil) {
        
        let test = balanceDatasource.value
        if requestedPage == 0  {
            balanceDatasource.accept(currentData ?? [])
        } else {
            balanceDatasource.accept(balanceDatasource.value + itemNetwork)
        }
	}
}

// MARK: - Private Zone
private extension HistoryOfBalancePresenter {
	
}
