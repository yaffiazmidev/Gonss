//
//  Validator+Length.swift
//  KipasKipasShared
//
//  Created by DENAZMI on 06/02/24.
//

import Foundation

public struct LengthValidator: Validator {
    
    private let min: Int
    private let max: Int
    
    public init(
        min: Int,
        max: Int
    ) {
        self.min = min
        self.max = max
    }
    
    public func validate(_ value: String) -> ValidationResult {
        if value.count > 0 && value.count < min {
            return .init(
                value: value,
                error: ValidationError(message: "Tidak boleh kurang dari \(min)")
            )
        } else if value.count > 0 && value.count > max {
            return .init(
                value: value,
                error: ValidationError(message: "Tidak boleh lebih dari \(max)")
            )
        } else {
            return .init(value: value)
        }
    }
}
