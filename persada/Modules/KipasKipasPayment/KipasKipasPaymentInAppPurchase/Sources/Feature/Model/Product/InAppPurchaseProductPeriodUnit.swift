//
//  InAppPurchaseProductPeriodUnit.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 05/09/23.
//

import Foundation

///Values representing the duration of an interval, from a day up to a year.
public enum InAppPurchaseProductPeriodUnit: Int {
    ///An interval lasting one day.
    case day = 0
    
    ///An interval lasting one week.
    case week = 1
    
    ///An interval lasting one month.
    case month = 2
    
    ///An interval lasting one year.
    case year = 3
}
