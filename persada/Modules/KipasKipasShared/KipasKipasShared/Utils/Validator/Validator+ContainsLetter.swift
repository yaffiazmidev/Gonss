import Foundation

public struct ContainsLetterValidator: Validator {
 
    public init() {}
    
    public func validate(_ value: String) -> ValidationResult {
        let regex = ".*[a-zA-Z]+.*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        guard predicate.evaluate(with: value) else {
            return .init(value: value, error: ValidationError(message: "Harus mengandung huruf"))
        }
        
        return .init(value: value)
    }
}

