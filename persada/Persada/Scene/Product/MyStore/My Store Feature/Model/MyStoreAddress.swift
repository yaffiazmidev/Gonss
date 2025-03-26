//
//  MyStoreAddress.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 10/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct MyStoreAddress: Hashable {
    let id: String
    let receiverName: String
    let senderName: String
    let phoneNumber: String
    let label: String
    let province: String
    let provinceId: String
    let city: String
    let cityId: String
    let postalCode: String
    let subDistrict: String
    let subDistrictId: String
    let latitude: String
    let longitude: String
    let isDefault: Bool
    let isDelivery: Bool
    let detail: String
    let accountId: String
    let addressType: String
    let isAddresses: Bool?
    
    init(id: String, receiverName: String, senderName: String, phoneNumber: String, label: String, province: String, provinceId: String, city: String, cityId: String, postalCode: String, subDistrict: String, subDistrictId: String, latitude: String, longitude: String, isDefault: Bool, isDelivery: Bool, detail: String, accountId: String, addressType: String, isAddresses: Bool?) {
        self.id = id
        self.receiverName = receiverName
        self.senderName = senderName
        self.phoneNumber = phoneNumber
        self.label = label
        self.province = province
        self.provinceId = provinceId
        self.city = city
        self.cityId = cityId
        self.postalCode = postalCode
        self.subDistrict = subDistrict
        self.subDistrictId = subDistrictId
        self.latitude = latitude
        self.longitude = longitude
        self.isDefault = isDefault
        self.isDelivery = isDelivery
        self.detail = detail
        self.accountId = accountId
        self.addressType = addressType
        self.isAddresses = isAddresses
    }
}
