//
//  InAppPurchaseProductMapper.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 05/09/23.
//

import Foundation
import StoreKit

final class InAppPurchaseProductMapper {
    static func map(from response: SKProductsResponse) -> InAppPurchaseProductsResponse {
        var products: [InAppPurchaseProduct] = []
        
        response.products.forEach { product in
            //Append SKProduct to local storage
            StoreKitInAppPurchaseProductLocalManager.shared.add(data: product)
            
            var discounts: [InAppPurchaseProductDiscount] = []
            product.discounts.forEach { discount in
                discounts.append(
                    InAppPurchaseProductDiscount(
                        identifier: discount.identifier,
                        type: InAppPurchaseProductDiscountType(rawValue: Int(discount.type.rawValue))!,
                        price: discount.price,
                        priceLocale: discount.priceLocale,
                        paymentMode: InAppPurchaseProductDiscountPaymentMode(rawValue: Int(discount.paymentMode.rawValue))!,
                        numberOfPeriods: discount.numberOfPeriods,
                        subscriptionPeriod: InAppPurchaseProductSubscriptionPeriod(
                            numberOfUnits: discount.subscriptionPeriod.numberOfUnits,
                            unit: InAppPurchaseProductPeriodUnit(rawValue: Int(discount.subscriptionPeriod.unit.rawValue))!
                        )
                    )
                )
            }
            
            var iapProduct = InAppPurchaseProduct(
                productIdentifier: product.productIdentifier,
                localizedDescription: product.localizedDescription,
                localizedTitle: product.localizedTitle,
                contentVersion: product.contentVersion,
                price: product.price,
                priceLocale: product.priceLocale,
                introductoryPrice: product.introductoryPrice == nil ? nil : InAppPurchaseProductDiscount(
                    identifier: product.introductoryPrice!.identifier,
                    type: InAppPurchaseProductDiscountType(rawValue: Int(product.introductoryPrice!.type.rawValue))!,
                    price: product.introductoryPrice!.price,
                    priceLocale: product.introductoryPrice!.priceLocale,
                    paymentMode: InAppPurchaseProductDiscountPaymentMode(rawValue: Int(product.introductoryPrice!.paymentMode.rawValue))!,
                    numberOfPeriods: product.introductoryPrice!.numberOfPeriods,
                    subscriptionPeriod: InAppPurchaseProductSubscriptionPeriod(
                        numberOfUnits: product.introductoryPrice!.subscriptionPeriod.numberOfUnits,
                        unit: InAppPurchaseProductPeriodUnit(rawValue: Int(product.introductoryPrice!.subscriptionPeriod.unit.rawValue))!
                    )
                ),
                discounts: discounts,
                subscriptionGroupIdentifier: product.subscriptionGroupIdentifier,
                subscriptionPeriod: product.subscriptionPeriod == nil ? nil : InAppPurchaseProductSubscriptionPeriod(
                    numberOfUnits: product.subscriptionPeriod!.numberOfUnits,
                    unit: InAppPurchaseProductPeriodUnit(rawValue: Int(product.subscriptionPeriod!.unit.rawValue))!
                ),
                isDownloadable: product.isDownloadable,
                downloadContentLengths: product.downloadContentLengths,
                downloadContentVersion: product.downloadContentVersion
            )
            
            if #available(iOS 14.0, *) {
                iapProduct.isFamilyShareable = product.isFamilyShareable
            }
            
            products.append(iapProduct)
        }
        
        return InAppPurchaseProductsResponse(
            invalidProductIdentifiers: response.invalidProductIdentifiers,
            products: products
        )
    }
}
