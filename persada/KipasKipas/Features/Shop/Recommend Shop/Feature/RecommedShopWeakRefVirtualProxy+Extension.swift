//
//  RecommedShopWeakRefVirtualProxy+Extension.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 25/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import KipasKipasShared

// MARK: Get
extension WeakRefVirtualProxy: RecommendShopView where T: RecommendShopView {
    
    func display(_ viewModel: [RecommendShopViewModel]) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: RecommendShopLoadingView where T: RecommendShopLoadingView {
    
    func display(_ viewModel: RecommendShopLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: RecommendShopLoadingErrorView where T: RecommendShopLoadingErrorView {
    
    func display(_ viewModel: RecommendShopLoadingErrorViewModel) {
        object?.display(viewModel)
    }
}
