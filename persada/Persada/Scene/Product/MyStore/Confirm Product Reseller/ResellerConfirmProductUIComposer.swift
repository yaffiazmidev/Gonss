//
//  ResellerConfirmProductUIComposer.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 07/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared

final class ResellerConfirmProductUIComposer {
    private init() {}
    
    static func resellerConfirmComposedWith(with params: ConfirmProductParams, confirm: ResellerProductConfirm, loader: UserSellerLoader, loaderProduct: ResellerProductLoader, validator: ResellerValidator) -> ResellerConfirmProductController {
        
        let confirmService: ResellerConfirmProductService = ResellerConfirmProductService(confirm: MainQueueDispatchDecorator(decoratee: confirm))
        let loaderService: UserSellerService = UserSellerService(loader: MainQueueDispatchDecorator(decoratee: loader))
        let loaderProductService: ResellerProductService = ResellerProductService(loader: loaderProduct)
        let validatorService = ResellerValidatorService(loader: validator)
        
        let serviceFactory = ResellerConfirmProductServiceFactory(confirm: confirmService, loader: loaderService, loaderProduct: loaderProductService, validator: validatorService)
        
        let controller = ResellerConfirmProductController(delegate: serviceFactory, params: params)
        
        confirmService.presenter = ResellerConfirmProductPresenter(
            successView: WeakRefVirtualProxy(controller),
            errorView: WeakRefVirtualProxy(controller)
        )
        
        loaderService.presenter = UserSellerPresenter(
            successView: WeakRefVirtualProxy(controller),
            errorView: WeakRefVirtualProxy(controller)
        )
        
        loaderProductService.presenter = ResellerProductPresenter(
            successView: WeakRefVirtualProxy(controller),
            errorView: WeakRefVirtualProxy(controller)
        )
        
        validatorService.presenter = ResellerValidatorPresenter(
            successView: WeakRefVirtualProxy(controller),
            errorView: WeakRefVirtualProxy(controller)
        )
        
        return controller
    }
}
