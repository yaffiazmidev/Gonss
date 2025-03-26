//
//  FilterProductUIComposer.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared

final class FilterProductUIComposer {
    private init () {}
    
    internal static func searchProductComposedWith(loader: FilterProductLoader, productCategoryId: String? = nil) -> FilterProductController {
        let loaderService = FilterProductService(loader: MainQueueDispatchDecorator(decoratee: loader))
        
        let controller = FilterProductController(delegate: loaderService, productCategoryId: productCategoryId)
        
        loaderService.presenter = FilterProductPresenter(
            successView: WeakRefVirtualProxy(controller),
            loadingView: WeakRefVirtualProxy(controller),
            errorView: WeakRefVirtualProxy(controller)
        )
        
        return controller
    }
}
