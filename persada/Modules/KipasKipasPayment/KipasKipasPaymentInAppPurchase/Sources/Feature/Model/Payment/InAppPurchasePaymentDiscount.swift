//
//  File.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 06/09/23.
//

import Foundation

///The signed discount applied to a payment.
public struct InAppPurchasePaymentDiscount {
    ///A string used to uniquely identify a discount offer for a product.
    public let identifier: String
    
    ///A string that identifies the key used to generate the signature.
    public let keyIdentifier: String
    
    ///A universally unique ID (UUID) value that you define.
    public let nonce: UUID
    
    ///A string representing the properties of a specific promotional offer, cryptographically signed.
    public let signature: String
    
    ///The date and time of the signature's creation in milliseconds, formatted in Unix epoch time.
    public let timestamp: NSNumber
    
    public init(identifier: String, keyIdentifier: String, nonce: UUID, signature: String, timestamp: NSNumber) {
        self.identifier = identifier
        self.keyIdentifier = keyIdentifier
        self.nonce = nonce
        self.signature = signature
        self.timestamp = timestamp
    }
}
