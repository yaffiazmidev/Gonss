//
//  ResellerValidatorWeakRefVirtualProxy+Extension.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 27/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import KipasKipasShared

// MARK: Get
extension WeakRefVirtualProxy: ResellerValidatorView where T: ResellerValidatorView {
    
    func display(_ viewModel: ResellerValidatorViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: ResellerValidatorLoadingErrorView where T: ResellerValidatorLoadingErrorView {
    
    func display(_ viewModel: ResellerValidatorLoadingErrorViewModel) {
        object?.display(viewModel)
    }
}

