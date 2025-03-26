import Foundation

public struct MinimumLengthValidator: Validator {
    
    private let min: Int
    private let errorMessage: String
    
    public init(
        min: Int,
        errorMessage: String
    ) {
        self.min = min
        self.errorMessage = errorMessage
    }
    
    public func validate(_ value: String) -> ValidationResult {
        guard value.count >= 0 && value.count < min else { return .init(value: value) }
        return .init(
            value: value,
            error: ValidationError(message: errorMessage)
        )
    }
}
