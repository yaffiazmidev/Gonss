//
//  InAppPurchaseProduct.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 05/09/23.
//

import Foundation

///An App Store response to a request for information about a list of products.
public struct InAppPurchaseProductsResponse {
    ///An array of product identifier strings that the App Store doesn’t recognize.
    public let invalidProductIdentifiers: [String]
    
    ///A list of products, one product for each valid product identifier provided in the original request.
    public let products: [InAppPurchaseProduct]
    
    public init(invalidProductIdentifiers: [String], products: [InAppPurchaseProduct]) {
        self.invalidProductIdentifiers = invalidProductIdentifiers
        self.products = products
    }
}

///Information about a product previously registered in App Store Connect.
public struct InAppPurchaseProduct {
    ///The string that identifies the product to the Apple App Store.
    public let productIdentifier: String
    
    ///A description of the product.
    public let localizedDescription: String
    
    ///The name of the product.
    public let localizedTitle: String
    
    ///A string that identifies the version of the content.
    public let contentVersion: String
    
    ///A Boolean value that indicates whether the product is available for family sharing in App Store Connect.
    public var isFamilyShareable: Bool = false
    
    ///The cost of the product in the local currency.
    public let price: NSDecimalNumber
    
    ///The locale used to format the price of the product.
    public let priceLocale: Locale
    
    ///The object containing introductory price information for the product.
    public let introductoryPrice: InAppPurchaseProductDiscount?
    
    ///An array of subscription offers available for the auto-renewable subscription.
    public let discounts: [InAppPurchaseProductDiscount]
    
    ///The identifier of the subscription group to which the subscription belongs.
    public let subscriptionGroupIdentifier: String?
    
    ///The period details for products that are subscriptions.
    public let subscriptionPeriod: InAppPurchaseProductSubscriptionPeriod?
    
    ///A Boolean value that indicates whether the App Store has downloadable content for this product.
    public let isDownloadable: Bool
    
    ///The lengths of the downloadable files available for this product.
    public let downloadContentLengths: [NSNumber]
    
    ///A string that identifies which version of the content is available for download.
    public let downloadContentVersion: String
    
    public init(productIdentifier: String, localizedDescription: String, localizedTitle: String, contentVersion: String, price: NSDecimalNumber, priceLocale: Locale, introductoryPrice: InAppPurchaseProductDiscount?, discounts: [InAppPurchaseProductDiscount], subscriptionGroupIdentifier: String?, subscriptionPeriod: InAppPurchaseProductSubscriptionPeriod?, isDownloadable: Bool, downloadContentLengths: [NSNumber], downloadContentVersion: String) {
        self.productIdentifier = productIdentifier
        self.localizedDescription = localizedDescription
        self.localizedTitle = localizedTitle
        self.contentVersion = contentVersion
        self.price = price
        self.priceLocale = priceLocale
        self.introductoryPrice = introductoryPrice
        self.discounts = discounts
        self.subscriptionGroupIdentifier = subscriptionGroupIdentifier
        self.subscriptionPeriod = subscriptionPeriod
        self.isDownloadable = isDownloadable
        self.downloadContentLengths = downloadContentLengths
        self.downloadContentVersion = downloadContentVersion
    }
}

