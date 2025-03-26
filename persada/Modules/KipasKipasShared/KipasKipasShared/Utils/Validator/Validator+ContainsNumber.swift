import Foundation

public struct ContainsNumberValidator: Validator {
 
    public init() {}
    
    public func validate(_ value: String) -> ValidationResult {
        let regex = ".*[0-9]+.*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        guard predicate.evaluate(with: value) else {
            return .init(value: value, error: ValidationError(message: "Harus mengandung angka"))
        }
        
        return .init(value: value)
    }
}

