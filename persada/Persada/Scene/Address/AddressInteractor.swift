//
//  AddressInteractor.swift
//  KipasKipas
//
//  Created by movan on 11/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


final class AddressInteractor {
	
	let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
	private let disposeBag = DisposeBag()
	let addressUseCase = Injection.init().provideAddressUseCase()
	
	
	func addressResponse(type: String) -> Observable<AddressResult> {
		return addressUseCase.getAddress(type: type).subscribeOn(concurrentBackground).observeOn(MainScheduler.init())
	}
	
	func searchAddressBuyer(query: String) -> Observable<AddressResult> {
		return addressUseCase.searchAddressBuyer(query: query).subscribeOn(concurrentBackground).observeOn(MainScheduler.init())
	}
	
	func searchAddressSeller(query: String) -> Observable<AddressResult> {
		return addressUseCase.searchAddressSeller(query: query).subscribeOn(concurrentBackground).observeOn(MainScheduler.init())
	}
}
