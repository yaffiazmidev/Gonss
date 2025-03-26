//
//  InAppPurchasePaymentTransaction.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 06/09/23.
//

import Foundation

///An object in the payment queue.
public struct InAppPurchasePaymentTransaction {
    ///The payment for the transaction.
    public let payment: InAppPurchasePayment
    
    ///A string that uniquely identifies a successful payment transaction.
    public let transactionIdentifier: String?
    
    ///The date the transaction was added to the App Store’s payment queue.
    public let transactionDate: Date?
    
    ///An object describing the error that occurred while processing the transaction.
    public let error: Error?
    
    ///The current state of the transaction.
    public let transactionState: InAppPurchasePaymentTransactionState
    
    public init(payment: InAppPurchasePayment, transactionIdentifier: String?, transactionDate: Date?, error: Error?, transactionState: InAppPurchasePaymentTransactionState) {
        self.payment = payment
        self.transactionIdentifier = transactionIdentifier
        self.transactionDate = transactionDate
        self.error = error
        self.transactionState = transactionState
    }
}
