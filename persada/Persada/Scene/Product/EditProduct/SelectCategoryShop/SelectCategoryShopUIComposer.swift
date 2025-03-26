//
//  SelectCategoryShopUIComposer.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 27/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared

final class SelectCategoryShopUIComposer {
    private init () {}
    
    internal static func categoryShopComposedWith(loader: CategoryShopLoader) -> SelectCategoryShopController {
        let loaderService = CategoryShopService(loader: MainQueueDispatchDecorator(decoratee: loader))
        let controller = SelectCategoryShopController(delegate: loaderService)
        
        loaderService.presenter = CategoryShopPresenter(
            successView: WeakRefVirtualProxy(controller),
            loadingView: WeakRefVirtualProxy(controller),
            errorView: WeakRefVirtualProxy(controller)
        )
        
        return controller
    }
}
