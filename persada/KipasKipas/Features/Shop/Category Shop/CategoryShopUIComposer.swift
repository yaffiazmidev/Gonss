//
//  CategoryShopUIComposer.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 17/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared

final class CategoryShopUIComposer {
    private init () {}
    
    internal static func categoryShopComposedWith(loader: CategoryShopLoader) -> CategoryShopController {
        let loaderService = CategoryShopService(loader: MainQueueDispatchDecorator(decoratee: loader))
        let controller = CategoryShopController(delegate: loaderService)
        
        loaderService.presenter = CategoryShopPresenter(
            successView: WeakRefVirtualProxy(controller),
            loadingView: WeakRefVirtualProxy(controller),
            errorView: WeakRefVirtualProxy(controller)
        )
        
        return controller
    }
}
