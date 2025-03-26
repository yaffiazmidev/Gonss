//
//  MyStoreAddressMapper.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 10/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

final class MyStoreAddressMapper {
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [MyStoreAddress] {
        guard response.isOK, let root = try? JSONDecoder().decode(RemoteMyStoreAddress.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.data?.map({ address in
            MyStoreAddress(
                id: address.id ?? "",
                receiverName: address.receiverName ?? "",
                senderName: address.senderName ?? "",
                phoneNumber: address.phoneNumber ?? "",
                label: address.label ?? "",
                province: address.province ?? "",
                provinceId: address.provinceId ?? "",
                city: address.city ?? "",
                cityId: address.cityId ?? "",
                postalCode: address.postalCode ?? "",
                subDistrict: address.subDistrict ?? "" ,
                subDistrictId: address.subDistrictId ?? "",
                latitude: address.latitude ?? "",
                longitude: address.longitude ?? "",
                isDefault: address.isDefault ?? false,
                isDelivery: address.isDelivery ?? false,
                detail: address.detail ?? "",
                accountId: address.accountId ?? "",
                addressType: address.addressType ?? "",
                isAddresses: address.isAddresses
            )
        }) ?? []
    }
}
