//
//  OrderUseCase.swift
//  KipasKipas
//
//  Created by PT.Koanba on 11/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift

protocol OrderUseCase {
    func getDelayedOrder() -> Observable<DelayCheckoutResult>
    func checkoutOrder(order: CheckoutOrderRequest) -> Observable<CheckoutOrderResult>
    func checkoutOrderContinue(order: CheckoutOrderRequest) -> Observable<CheckoutOrderContinueResult>
}

class OrderInteractorRx : OrderUseCase {

    private let repository : OrderRepository
    
    required init(repository: OrderRepository) {
        self.repository = repository
    }
    
    func getDelayedOrder() -> Observable<DelayCheckoutResult> {
        return repository.getDelayedOrder()
    }
    
    func checkoutOrder(order: CheckoutOrderRequest) -> Observable<CheckoutOrderResult> {
        return repository.checkoutOrder(order: order)
    }
    
    func checkoutOrderContinue(order: CheckoutOrderRequest) -> Observable<CheckoutOrderContinueResult> {
        return repository.checkoutOrderContinue(order: order)
    }

}
