//
//  ShopUIComposer.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 17/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared

final class ShopUIComposer {
    private init() {}
    
    public static func shopComposerWith(category: CategoryShopLoader, recommend: RecommendShopLoader, shop: ShopLoader, photoLibraryChecker: PhotoLibraryPreferencesPermissionChecker) -> ShopViewController {
        
        let categoryShopService = CategoryShopService(loader: MainQueueDispatchDecorator(decoratee: category))
        let recommendShopService = RecommendShopService(loader: MainQueueDispatchDecorator(decoratee: recommend))
        let shopService = ShopService(loader: MainQueueDispatchDecorator(decoratee: shop))
        let photoLibraryCheckerService = PermissionPhotoLibraryPreferencesService(checker: MainQueueDispatchDecorator(decoratee: photoLibraryChecker))
        
        let serviceFactory = ShopServiceFactory(categoryShop: categoryShopService, recommendShop: recommendShopService, shop: shopService, photoLibraryChecker: photoLibraryCheckerService)
        
        let network = DIContainer.shared.toolsDataTransferService
        let viewModel = KKShopViewModel(network: network)
        
        let controller = ShopViewController(delegate: serviceFactory, viewModel: viewModel)
        
        categoryShopService.presenter = CategoryShopPresenter(
            successView: WeakRefVirtualProxy(controller),
            loadingView: WeakRefVirtualProxy(controller),
            errorView: WeakRefVirtualProxy(controller)
        )
        
        recommendShopService.presenter = RecommendShopPresenter(
            successView: WeakRefVirtualProxy(controller),
            loadingView: WeakRefVirtualProxy(controller),
            errorView: WeakRefVirtualProxy(controller)
        )
        
        shopService.presenter = ShopPresenter(
            successView: WeakRefVirtualProxy(controller),
            loadingView: WeakRefVirtualProxy(controller),
            errorView: WeakRefVirtualProxy(controller)
        )
        
        photoLibraryCheckerService.presenter = PermissionPhotoLibraryPreferencesPresenter(
            successView: WeakRefVirtualProxy(controller)
        )
        
        viewModel.delegate = WeakRefVirtualProxy(controller)
        
        return controller
    }
}
