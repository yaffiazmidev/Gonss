//
//  RemoteMyStoreAddress.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 10/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

// MARK: - RemoteAddressRoot
struct RemoteMyStoreAddress: Codable {
    let code, message: String?
    let data: [RemoteMyStoreAddressData]?
}

// MARK: - RemoteAddressData
struct RemoteMyStoreAddressData: Codable {
    let id: String?
    let receiverName: String?
    let senderName: String?
    let phoneNumber: String?
    let label: String?
    let province: String?
    let provinceId: String?
    let city: String?
    let cityId: String?
    let postalCode: String?
    let subDistrict: String?
    let subDistrictId: String?
    let latitude: String?
    let longitude: String?
    let isDefault: Bool?
    let isDelivery: Bool?
    let detail: String?
    let accountId: String?
    let addressType: String?
    let isAddresses: Bool?
}
