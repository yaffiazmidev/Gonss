//
//  RemoteCoinInAppPurchaseValidateOrderDetail.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 17/10/23.
//

import Foundation

struct RemoteCoinInAppPurchaseValidateOrderDetail: Codable {
    
    let id: String?
    let coinId: String?
    let coinName: String?
    let coinPrice: Double?
    let coinAmount: Int?
    let storeProductId: String?
    let qty: Int?
    let storeEventTime: String?
    let totalAmount: Double?
    
}
