//
//  RxOrderNetworkModel.swift
//  KipasKipas
//
//  Created by PT.Koanba on 11/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift

public final class RxOrderNetworkModel {
    private let network: Network<CheckoutOrderResult>
    private let networkContinue: Network<CheckoutOrderContinueResult>
    private let networkDefault: Network<DelayCheckoutResult>
    
    init(network: Network<CheckoutOrderResult>, networkDefault: Network<DelayCheckoutResult>, networkContinue: Network<CheckoutOrderContinueResult>) {
        self.network = network
        self.networkDefault = networkDefault
        self.networkContinue = networkContinue
    }
    
    func getDelayedOrder() -> Observable<DelayCheckoutResult> {
        let orderEndpoint = OrderEndpoint.getDelayedOrder
        return networkDefault.getItems(orderEndpoint.path, parameters: orderEndpoint.parameter)
    }
    
    func checkoutOrder(order: CheckoutOrderRequest) -> Observable<CheckoutOrderResult> {
        let orderEndpoint = OrderEndpoint.checkoutOrder(order: order)
        return network.postItemObject(orderEndpoint.path, parameters: order, headers: orderEndpoint.header)
    }

    func checkoutOrderContinue(order: CheckoutOrderRequest) -> Observable<CheckoutOrderContinueResult> {
        let orderEndpoint = OrderEndpoint.checkoutOrderContinue(order: order)
        return networkContinue.postItemObject(orderEndpoint.path, parameters: order, headers: orderEndpoint.header)
    }
}
