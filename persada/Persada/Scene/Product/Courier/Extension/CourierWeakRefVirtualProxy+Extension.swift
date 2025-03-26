//
//  CourierWeakRefVirtualProxy+Extension.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 21/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import KipasKipasShared

// MARK: Get
extension WeakRefVirtualProxy: CourierView where T: CourierView {
    
    func display(_ viewModel: CourierViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: CourierLoadingView where T: CourierLoadingView {
    
    func display(_ viewModel: CourierLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: CourierLoadingErrorView where T: CourierLoadingErrorView {
    
    func display(_ viewModel: CourierLoadingErrorViewModel) {
        object?.display(viewModel)
    }
}


