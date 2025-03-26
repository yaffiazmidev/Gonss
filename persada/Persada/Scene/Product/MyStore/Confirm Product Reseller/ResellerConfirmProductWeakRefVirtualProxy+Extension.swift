//
//  ResellerConfirmProductWeakRefVirtualProxy+Extension.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 07/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import KipasKipasShared

extension WeakRefVirtualProxy: ResellerConfirmProductView where T: ResellerConfirmProductView {
    
    func display(_ viewModel: ResellerConfirmProductViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: ResellerConfirmProductLoadingErrorView where T: ResellerConfirmProductLoadingErrorView {
    
    func display(_ viewModel: ResellerConfirmProductLoadingErrorViewModel) {
        object?.display(viewModel)
    }
}


extension WeakRefVirtualProxy: UserSellerView where T: UserSellerView {
    
    func display(_ viewModel: UserSellerViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: UserSellerLoadingErrorView where T: UserSellerLoadingErrorView {
    
    func display(_ viewModel: UserSellerLoadingErrorViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: ResellerProductView where T: ResellerProductView {
    
    func display(_ viewModel: ResellerProductViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: ResellerProductLoadingErrorView where T: ResellerProductLoadingErrorView {
    
    func display(_ viewModel: ResellerProductLoadingErrorViewModel) {
        object?.display(viewModel)
    }
}
