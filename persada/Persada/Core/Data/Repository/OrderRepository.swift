//
//  OrderRepository.swift
//  KipasKipas
//
//  Created by PT.Koanba on 11/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift

protocol OrderRepository {
    func getDelayedOrder() -> Observable<DelayCheckoutResult>
    func checkoutOrder(order: CheckoutOrderRequest) -> Observable<CheckoutOrderResult>
    func checkoutOrderContinue(order: CheckoutOrderRequest) -> Observable<CheckoutOrderContinueResult>
}

class OrderRepositoryImpl: OrderRepository {
    
    fileprivate let remote: RxOrderNetworkModel
    
    typealias OrderInstance = (RxOrderNetworkModel) -> OrderRepository
    
    private init(remote: RxOrderNetworkModel) {
        self.remote = remote
    }
    
    static let sharedInstance: OrderInstance = { remote in
        return OrderRepositoryImpl(remote: remote)
    }
    
    func getDelayedOrder() -> Observable<DelayCheckoutResult> {
        return remote.getDelayedOrder()
    }
    
    func checkoutOrder(order: CheckoutOrderRequest) -> Observable<CheckoutOrderResult> {
        return remote.checkoutOrder(order: order)
    }
    
    func checkoutOrderContinue(order: CheckoutOrderRequest) -> Observable<CheckoutOrderContinueResult> {
        return remote.checkoutOrderContinue(order: order)
    }
}
