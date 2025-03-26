//
//  LocationDonationViewModels.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 04/08/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct LocationDonationViewModel {
    let items: [LocationDonationItem]
}

struct LocationDonationLoadingViewModel {
    let isLoading: Bool
}

struct LocationDonationLoadingErrorViewModel {
    let message: String?
    
    static var noError: LocationDonationLoadingErrorViewModel {
        return LocationDonationLoadingErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> LocationDonationLoadingErrorViewModel {
        return LocationDonationLoadingErrorViewModel(message: message)
    }
}
