import Foundation

public struct ContainsLowercaseAndUppercaseLetter: Validator {
 
    public init() {}
    
    public func validate(_ value: String) -> ValidationResult {
        let regex = "(?=.*[a-z])(?=.*[A-Z]).{1,}"
        let capitalLetterPredicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        guard capitalLetterPredicate.evaluate(with: value) else {
            return .init(value: value, error: ValidationError(message: "Harus mengandung huruf kapital"))
        }
        
        return .init(value: value)
    }
}
