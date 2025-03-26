//
//  InAppPurchasePaymentTransactionMapper.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 07/09/23.
//

import Foundation
import StoreKit

final class InAppPurchasePaymentTransactionMapper {
    static func map(from skTransacion: SKPaymentTransaction) -> InAppPurchasePaymentTransaction {
        return InAppPurchasePaymentTransaction(
            payment: InAppPurchasePayment(
                productIdentifier: skTransacion.payment.productIdentifier,
                quantity: skTransacion.payment.quantity,
                applicationUsername: skTransacion.payment.applicationUsername,
                paymentDiscount: skTransacion.payment.paymentDiscount == nil ? nil : InAppPurchasePaymentDiscount(
                    identifier: skTransacion.payment.paymentDiscount!.identifier,
                    keyIdentifier: skTransacion.payment.paymentDiscount!.keyIdentifier,
                    nonce: skTransacion.payment.paymentDiscount!.nonce,
                    signature: skTransacion.payment.paymentDiscount!.signature,
                    timestamp: skTransacion.payment.paymentDiscount!.timestamp
                )
            ),
            transactionIdentifier: skTransacion.transactionIdentifier,
            transactionDate: skTransacion.transactionDate,
            error: skTransacion.error,
            transactionState: InAppPurchasePaymentTransactionState(rawValue: Int(skTransacion.transactionState.rawValue))!
        )
    }
}
