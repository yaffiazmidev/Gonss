import Foundation

public struct BasicEmailValidator: Validator {
    
    private let errorMessage: String
    
    public init(errorMessage: String) {
        self.errorMessage = errorMessage
    }
    
    public func validate(_ value: String) -> ValidationResult {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        guard emailPredicate.evaluate(with: value)else {
            return .init(
                value: value,
                error: ValidationError(message: errorMessage)
            )
        }
        
        return .init(value: value)
    }
}
