//
//  SearchProductUIComposer.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 30/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared

final class SearchProductUIComposer {
    private init () {}
    
    internal static func searchProductComposedWith(loader: FilterProductLoader, categoryProduct: CategoryShopItem?) -> SearchProductViewController {
        let loaderService = FilterProductService(loader: MainQueueDispatchDecorator(decoratee: loader))
        
        let controller = SearchProductViewController(delegate: loaderService, categoryProduct: categoryProduct)
        
        loaderService.presenter = FilterProductPresenter(
            successView: WeakRefVirtualProxy(controller),
            loadingView: WeakRefVirtualProxy(controller),
            errorView: WeakRefVirtualProxy(controller)
        )
        
        return controller
    }
}
