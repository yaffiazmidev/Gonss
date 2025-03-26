//
//  SearchProductWeakRefVirtualProxy+Extension.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import KipasKipasShared

// MARK: Get
extension WeakRefVirtualProxy: FilterProductView where T: FilterProductView {
    
    func display(_ viewModel: [FilterProductViewModel]) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FilterProductLoadingView where T: FilterProductLoadingView {
    
    func display(_ viewModel: FilterProductLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FilterProductLoadingErrorView where T: FilterProductLoadingErrorView {
    
    func display(_ viewModel: FilterProductLoadingErrorViewModel) {
        object?.display(viewModel)
    }
}
