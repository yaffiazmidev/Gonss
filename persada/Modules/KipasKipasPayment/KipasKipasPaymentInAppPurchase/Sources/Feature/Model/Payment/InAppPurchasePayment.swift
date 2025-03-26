//
//  InAppPurchasePayment.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 06/09/23.
//

import Foundation

///A request to the App Store to process payment for additional functionality offered by your app.
public struct InAppPurchasePayment {
    ///A string used to identify a product that can be purchased from within your app.
    public let productIdentifier: String
    
    ///The number of items the user wants to purchase.
    public let quantity: Int
    
    ///A string that associates the transaction with a user account on your service.
    public let applicationUsername: String?
    
    ///The details of the discount offer to apply to the payment.
    public let paymentDiscount: InAppPurchasePaymentDiscount?
    
    public init(productIdentifier: String, quantity: Int, applicationUsername: String?, paymentDiscount: InAppPurchasePaymentDiscount?) {
        self.productIdentifier = productIdentifier
        self.quantity = quantity
        self.applicationUsername = applicationUsername
        self.paymentDiscount = paymentDiscount
    }
}
