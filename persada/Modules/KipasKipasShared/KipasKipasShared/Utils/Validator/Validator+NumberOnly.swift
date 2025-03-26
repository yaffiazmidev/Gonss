//
//  Validator+NumberOnly.swift
//  KipasKipasShared
//
//  Created by DENAZMI on 06/02/24.
//

import Foundation

public struct NumberOnlyValidator: Validator {
    
    private let errorMessage: String
    
    public init(
        errorMessage: String
    ) {
        self.errorMessage = errorMessage
    }
    
    public func validate(_ value: String) -> ValidationResult {
        if Int(value) != nil {
            return .init(value: value)
        }
        
        guard !value.isEmpty else {
            return .init(
                value: value,
                error: ValidationError(message: "Harap masukan nomor telepon")
            )
        }
        
        return .init(
            value: value,
            error: ValidationError(message: errorMessage)
        )
    }
}
