//
//  CategoryDetailUIComposer.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 30/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared

final class CategoryDetailUIComposer {
    private init () {}
    
    internal static func detailCategoryProductComposedWith(loader: FilterProductLoader, categoryProduct: CategoryShopItem) -> CategoryDetailViewController {
        let loaderService = FilterProductService(loader: MainQueueDispatchDecorator(decoratee: loader))
        
        let controller = CategoryDetailViewController(delegate: loaderService, categoryProduct: categoryProduct)
        
        loaderService.presenter = FilterProductPresenter(
            successView: WeakRefVirtualProxy(controller),
            loadingView: WeakRefVirtualProxy(controller),
            errorView: WeakRefVirtualProxy(controller)
        )
        
        return controller
    }
}
