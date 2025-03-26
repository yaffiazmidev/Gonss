//
//  CheckoutInteractor.swift
//  Persada
//
//  Created by movan on 22/07/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class CheckoutInteractor {
	
	let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
	private let disposeBag = DisposeBag()
	let addressUsecase = Injection.init().provideAddressUseCase()
	let productUsecase = Injection().provideProductUseCase()
	let transactionUsecase = Injection().provideTransactionUseCase()
    let orderUsecase = Injection().provideOrderUseCase()
	
	func fetchAddress(type: AddressFetchType) -> Observable<AddressResult> {
		return addressUsecase.getAddress(type: type.rawValue).subscribeOn(concurrentBackground).observeOn(MainScheduler.init())
	}
	
	func orderProduct(parameter: ParameterOrder) -> Observable<PaymentResponse> {
		return transactionUsecase.orderProduct(.orderProduct, parameter: parameter)
			.subscribeOn(concurrentBackground).observeOn(MainScheduler.instance)
	}
    
    func isOrderDelayed() -> Observable<DelayCheckoutResult> {
        return orderUsecase.getDelayedOrder()
    }
    
    func checkout(order: CheckoutOrderRequest) -> Observable<CheckoutOrderResult> {
        return orderUsecase.checkoutOrder(order: order)
    }
    
    func checkoutContinue(order: CheckoutOrderRequest) -> Observable<CheckoutOrderContinueResult> {
        return orderUsecase.checkoutOrderContinue(order: order)
    }
    
    func getProductById(id: String) -> Observable<ProductDetailResult> {
        return productUsecase.detailProduct(id: id)
    }
}
