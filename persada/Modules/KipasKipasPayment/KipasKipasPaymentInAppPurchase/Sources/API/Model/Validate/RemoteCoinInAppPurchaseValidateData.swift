//
//  RemoteCoinInAppPurchaseValidateData.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 17/10/23.
//

import Foundation

struct RemoteCoinInAppPurchaseValidateData: Codable {
    
    let orderCoin: RemoteCoinInAppPurchaseValidateOrder?
    let notificationId: String?
    
}
