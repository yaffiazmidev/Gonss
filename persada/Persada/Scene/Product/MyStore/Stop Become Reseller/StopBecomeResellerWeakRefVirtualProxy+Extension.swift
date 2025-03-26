//
//  StopBecomeResellerWeakRefVirtualProxy+Extension.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 28/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import KipasKipasShared

extension WeakRefVirtualProxy: StopBecomeResellerView where T: StopBecomeResellerView {
    
    func display(_ viewModel: StopBecomeResellerViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: StopBecomeResellerLoadingErrorView where T: StopBecomeResellerLoadingErrorView {
    func display(_ viewModel: StopBecomeResellerLoadingErrorViewModel) {
        object?.display(viewModel)
    }
}
