//
//  InAppPurchasePaymentTransactionState.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 06/09/23.
//

import Foundation

public enum InAppPurchasePaymentTransactionState: Int {
    ///A transaction that is being processed by the App Store.
    case purchasing = 0
    
    ///A successfully processed transaction.
    case purchased = 1
    
    /// A failed transaction.
    case failed = 2
    
    ///A transaction that restores content previously purchased by the user.
    case restored = 3
    
    ///A transaction that is in the queue, but its final status is pending external action such as Ask to Buy.
    case deferred = 4
    
}
