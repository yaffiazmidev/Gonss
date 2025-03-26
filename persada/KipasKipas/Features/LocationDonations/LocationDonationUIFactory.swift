//
//  LocationDonationUIFactory.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 22/08/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

final class LocationDonationUIFactory {
    
    static func create(
        selectByProvinceId: @escaping (LocationDonationItem) -> Void,
        selectByCurrentLocation: @escaping (_ long: Double?, _ lat: Double?) -> Void,
        selectAllLocation: @escaping () -> Void
    ) -> LocationDonationController {
        let isLoggedIn = getToken() != nil
        let baseURLString = APIConstants.baseURL + (isLoggedIn ? String() : "/public")
        let client = isLoggedIn ? HTTPClientFactory.makeAuthHTTPClient() : HTTPClientFactory.makeHTTPClient()
        let baseURL = URL(string: baseURLString)!
        let loader = RemoteLocationDonation(url: baseURL, client: client)
        let controller = LocationDonationUIComposer.locationDonation(
            loader: loader,
            selectByProvinceId: selectByProvinceId,
            selectByCurrentLocation: selectByCurrentLocation,
            selectAllLocation: selectAllLocation
        )
        return controller
    }
}
