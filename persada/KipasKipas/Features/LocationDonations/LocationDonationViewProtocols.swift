//
//  LocationDonationViewProtocols.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 04/08/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

protocol LocationDonationView {
    func display(_ viewModel: LocationDonationViewModel)
}

protocol LocationDonationLoadingView {
    func display(_ viewModel: LocationDonationLoadingViewModel)
}

protocol LocationDonationLoadingErrorView {
    func display(_ viewModel: LocationDonationLoadingErrorViewModel)
}
