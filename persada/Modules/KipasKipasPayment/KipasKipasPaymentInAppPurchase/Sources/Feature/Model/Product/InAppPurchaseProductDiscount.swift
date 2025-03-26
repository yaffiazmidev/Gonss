//
//  InAppPurchaseProductDiscount.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 05/09/23.
//

import Foundation

///Values representing the types of discount offers an app can present.
public enum InAppPurchaseProductDiscountType: Int {
    ///A constant indicating the discount type is an introductory offer.
    case introductory = 0
    
    ///A constant indicating the discount type is a promotional offer.
    case subscription = 1
}

///Values representing the payment modes for a product discount.
public enum InAppPurchaseProductDiscountPaymentMode: Int {
    ///A constant indicating that the payment mode of a product discount is billed over a single or multiple billing periods.
    case payAsYouGo = 0
    
    ///A constant indicating that the payment mode of a product discount is paid up front.
    case payUpFront = 1
    
    ///A constant that indicates that the payment mode is a free trial.
    case freeTrial = 2
}

///The details of an introductory offer or a promotional offer for an auto-renewable subscription.
public struct InAppPurchaseProductDiscount {
    ///A string used to uniquely identify a discount offer for a product.
    public let identifier: String?
    
    ///The type of discount offer.
    public let type: InAppPurchaseProductDiscountType
    
    ///The discount price of the product in the local currency.
    public let price: NSDecimalNumber
    
    ///The locale used to format the discount price of the product.
    public let priceLocale: Locale
    
    ///The payment mode for this product discount.
    public let paymentMode: InAppPurchaseProductDiscountPaymentMode
    
    ///An integer that indicates the number of periods the product discount is available.
    public let numberOfPeriods: Int
    
    ///An object that defines the period for the product discount.
    public let subscriptionPeriod: InAppPurchaseProductSubscriptionPeriod
    
    public init(identifier: String?, type: InAppPurchaseProductDiscountType, price: NSDecimalNumber, priceLocale: Locale, paymentMode: InAppPurchaseProductDiscountPaymentMode, numberOfPeriods: Int, subscriptionPeriod: InAppPurchaseProductSubscriptionPeriod) {
        self.identifier = identifier
        self.type = type
        self.price = price
        self.priceLocale = priceLocale
        self.paymentMode = paymentMode
        self.numberOfPeriods = numberOfPeriods
        self.subscriptionPeriod = subscriptionPeriod
    }
}

