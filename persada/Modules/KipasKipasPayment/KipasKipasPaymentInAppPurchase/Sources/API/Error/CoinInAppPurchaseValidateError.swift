//
//  CoinInAppPurchaseValidateError.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 18/10/23.
//

import Foundation

public enum CoinInAppPurchaseValidateError: Error {
    case connectivity
    case invalidData
    case alreadyValidated
}

extension CoinInAppPurchaseValidateError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .connectivity:
            return NSLocalizedString("Error Connectivity", comment: "Error Connectivity")
        case .invalidData:
            return NSLocalizedString("Data Invalid.", comment: "Data Invalid")
        case .alreadyValidated:
            return NSLocalizedString("Transaction Already Registered.", comment: "Transaction Already Registered")
        }
    }
}
