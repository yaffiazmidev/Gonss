import Foundation

public struct NonEmptyValidator: Validator {
    
    private let errorMessage: String
    
    public init(errorMessage: String) {
        self.errorMessage = errorMessage
    }
    
    public func validate(_ value: String) -> ValidationResult {
        guard value.isEmpty else { return .init(value: value) }
        
        return .init(
            value: value,
            error: ValidationError(message: errorMessage)
        )
    }
}
