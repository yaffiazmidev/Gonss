//
//  MyStoreSettingModel.swift
//  KipasKipas
//
//  Created by IEN-Yasin-MacbookPro on 18/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

enum MyStoreSettingModel {

    enum Route {
        case dismissMyStoreSetting
        case showMyAddress
        case showMyCourier
        case showMyArchiveProduct
			case addAddress
    }

    struct DataSource: DataSourceable {
        var items: [MyStoreSetting] = []
    }
}

enum MyStoreSetting: String, CaseIterable {
    case alamat
}
