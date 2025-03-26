//
//  DonationCartUIComposer.swift
//  KipasKipasDonationCart
//
//  Created by Rahmat Trinanda Pramudya Amar on 29/02/24.
//

import Foundation

public enum DonationCartUIComposer {
    public struct Loaders {
        let orderExistLoader: () -> DonationCartOrderExistLoader
        let orderLoader: (DonationCartOrderParam) -> DonationCartOrderLoader
        let orderDetailLoader: (String) -> DonationCartOrderDetailLoader
        let orderContinueLoader: (DonationCartOrderParam) -> DonationCartOrderLoader
        
        public init(
            orderExistLoader: @escaping () -> DonationCartOrderExistLoader,
            orderLoader: @escaping (DonationCartOrderParam) -> DonationCartOrderLoader,
            orderDetailLoader: @escaping (String) -> DonationCartOrderDetailLoader,
            orderContinueLoader: @escaping (DonationCartOrderParam) -> DonationCartOrderLoader
        ) {
            self.orderExistLoader = orderExistLoader
            self.orderLoader = orderLoader
            self.orderDetailLoader = orderDetailLoader
            self.orderContinueLoader = orderContinueLoader
        }
    }
    
    public static func composeConversationWith(loaders: Loaders) -> DonationCartController {
        
        let orderExistAdapter = DonationCartOrderExistInteractorAdapter(loader: loaders.orderExistLoader)
        let orderAdapter = DonationCartOrderInteractorAdapter(loader: loaders.orderLoader)
        let orderDetailAdapter = DonationCartOrderDetailInteractorAdapter(loader: loaders.orderDetailLoader)
        let orderContinueAdapter = DonationCartOrderInteractorAdapter(loader: loaders.orderContinueLoader)

        let controller = DonationCartController(
            orderExistAdapter: orderExistAdapter,
            orderAdapter: orderAdapter,
            orderDetailAdapter: orderDetailAdapter,
            orderContinueAdapter: orderContinueAdapter
        )
        
        return controller
    }
}
