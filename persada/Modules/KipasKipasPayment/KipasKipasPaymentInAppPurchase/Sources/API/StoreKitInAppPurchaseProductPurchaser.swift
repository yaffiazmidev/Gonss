//
//  StoreKitInAppPurchaseProductPurchaser.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 07/09/23.
//

import Foundation
import StoreKit

public class StoreKitInAppPurchaseProductPurchaser: NSObject, InAppPurchaseProductPurchaser {
    public typealias Result = Swift.Result<InAppPurchasePaymentTransaction, Error>
    
    private var request: InAppPurchaseProductPurchaserRequest? = nil
    private var completion: ((Result) -> Void)? = nil
    
    public override init() {}
    
    public func purchase(request: InAppPurchaseProductPurchaserRequest, completion: @escaping (Result) -> Void) {
        self.completion = completion
        self.request = request
        
        if request.applicationUsername.isEmpty {
            completion(.failure(InAppPurchaseError.invalidData))
            return
        }
        
        SKPaymentQueue.default().add(self)
        do {
            let product = try StoreKitInAppPurchaseProductLocalManager.shared.product(from: request.product)
            let payment = SKMutablePayment(product: product)
            payment.applicationUsername = self.toUUIDString(request.applicationUsername)
            SKPaymentQueue.default().add(payment)
        } catch {
            completion(.failure(error))
            SKPaymentQueue.default().remove(self)
        }
    }
    
    private func toUUIDString(_ from: String) -> String {
        var formatted = from
        let dashIndices = [8, 13, 18, 23]
        
        for index in dashIndices {
            let stringIndex = formatted.index(formatted.startIndex, offsetBy: index)
            formatted.insert("-", at: stringIndex)
        }
        
        return formatted
    }
}

extension StoreKitInAppPurchaseProductPurchaser: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { transaction in
            if transaction.payment.productIdentifier == self.request?.product.productIdentifier {
                switch(transaction.transactionState){
                case .failed:
                    self.completion?(.failure(transaction.error ?? InAppPurchaseError.unknown))
                    queue.finishTransaction(transaction)
                    SKPaymentQueue.default().remove(self)
                case .purchased:
                    self.completion?(.success(InAppPurchasePaymentTransactionMapper.map(from: transaction)))
                    queue.finishTransaction(transaction)
                    SKPaymentQueue.default().remove(self)
                default: break
                }
            }
        }
    }
}
