//
//  LocationDonationWeakRefVirtualProxy+Ext.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 04/08/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import KipasKipasShared

extension WeakRefVirtualProxy: LocationDonationView where T: LocationDonationView {
    
    func display(_ viewModel: LocationDonationViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: LocationDonationLoadingView where T: LocationDonationLoadingView {
    
    func display(_ viewModel: LocationDonationLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: LocationDonationLoadingErrorView where T: LocationDonationLoadingErrorView {
    
    func display(_ viewModel: LocationDonationLoadingErrorViewModel) {
        object?.display(viewModel)
    }
}
