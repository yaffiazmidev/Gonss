//
//  InAppPurchaseProductSubscriptionPeriod.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 05/09/23.
//

import Foundation

///An object containing the subscription period duration information.
public struct InAppPurchaseProductSubscriptionPeriod {
    ///The number of units per subscription period.
    public let numberOfUnits: Int
    
    ///The increment of time that a subscription period is specified in.
    public let unit: InAppPurchaseProductPeriodUnit
    
    public init(numberOfUnits: Int, unit: InAppPurchaseProductPeriodUnit) {
        self.numberOfUnits = numberOfUnits
        self.unit = unit
    }
}
