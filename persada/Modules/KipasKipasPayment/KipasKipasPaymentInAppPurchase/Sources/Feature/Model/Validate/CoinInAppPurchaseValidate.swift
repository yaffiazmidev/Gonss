//
//  CoinInAppPurchaseValidate.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 17/10/23.
//

import Foundation

internal struct CoinInAppPurchaseValidate: Hashable {
    
    let data: CoinInAppPurchaseValidateData?
    let code: String?
    let message: String?
    
    
    internal init(data: CoinInAppPurchaseValidateData?, code: String?, message: String?) {
        self.data = data
        self.code = code
        self.message = message
    }
}
