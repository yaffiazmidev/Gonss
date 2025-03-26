//
//  AppDelegate+DonationCart.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 29/02/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import Foundation
import UIKit
import KipasKipasNetworking
import KipasKipasDonationCart
import KipasKipasDonationCartUI

var showDonationCart: (() -> Void)?

extension AppDelegate {
    func configureDonationCartFeature() {
        KipasKipas.showDonationCart = navigateToDonationCart
    }
}

// MARK: - Navigator
fileprivate extension AppDelegate {
    func makeDonationCartController() -> DonationCartController {
        let loaders = DonationCartUIComposer.Loaders(
            orderExistLoader: makeOrderExistLoader,
            orderLoader: makeOrderLoader,
            orderDetailLoader: makeOrderDetailLoader,
            orderContinueLoader: makeOrderContinueLoader
        )
        
        let controller = DonationCartUIComposer.composeConversationWith(loaders: loaders)
        controller.delegate = self
        
        return controller
    }
    
    func navigateToDonationCart() {
        let destination = makeDonationCartController()
        destination.modalPresentationStyle = .overFullScreen
        window?.topViewController?.presentPanModal(destination)
    }
}

// MARK: - Loader
fileprivate extension AppDelegate {
    func makeOrderExistLoader() -> DonationCartOrderExistLoader {
        let request = DonationCartEndpoint.orderExist.url(baseURL: baseURL)
        
        return authenticatedHTTPClient
            .getPublisher(request: request)
            .tryMap(Mapper<Root<DonationCartOrderExist>>.map)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    func makeOrderLoader(_ param: DonationCartOrderParam) -> DonationCartOrderLoader {
        let request = DonationCartEndpoint.order(param).url(baseURL: baseURL)
        
        return authenticatedHTTPClient
            .getPublisher(request: request)
            .tryMap(Mapper<Root<DonationCartOrder>>.map)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    func makeOrderContinueLoader(_ param: DonationCartOrderParam) -> DonationCartOrderLoader {
        let request = DonationCartEndpoint.orderContinue(param).url(baseURL: baseURL)
        
        return authenticatedHTTPClient
            .getPublisher(request: request)
            .tryMap(Mapper<Root<DonationCartOrder>>.map)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    func makeOrderDetailLoader(_ orderId: String) -> DonationCartOrderDetailLoader {
        let request = DonationCartEndpoint.orderDetail(orderId).url(baseURL: baseURL)
        
        return authenticatedHTTPClient
            .getPublisher(request: request)
            .tryMap(Mapper<Root<DonationCartOrderDetail>>.map)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
}

extension AppDelegate: DonationCartControllerDelegate {
    func didOpenVA(_ url: String) {
        guard let url = URL(string: url), UIApplication.shared.canOpenURL(url) else { return }
        
        UIApplication.shared.open(url)
    }
    
    func didOpenDetail(donation id: String) {
        
    }
}
