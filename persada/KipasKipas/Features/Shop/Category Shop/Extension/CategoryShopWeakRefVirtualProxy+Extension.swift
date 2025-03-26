//
//  CategoryShopWeakRefVirtualProxy+Extension.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 17/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import KipasKipasShared

// MARK: Get
extension WeakRefVirtualProxy: CategoryShopView where T: CategoryShopView {
    
    func display(_ viewModel: CategoryShopViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: CategoryShopLoadingView where T: CategoryShopLoadingView {
    
    func display(_ viewModel: CategoryShopLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: CategoryShopLoadingErrorView where T: CategoryShopLoadingErrorView {
    
    func display(_ viewModel: CategoryShopLoadingErrorViewModel) {
        object?.display(viewModel)
    }
}
