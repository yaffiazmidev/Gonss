import Foundation

public struct NoSymbolsAndSpacesValidator: Validator {
 
    public init() {}
    
    public func validate(_ value: String) -> ValidationResult {
        let regex = "^[a-zA-Z0-9_.]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        guard predicate.evaluate(with: value) else {
            return .init(value: value, error: ValidationError(message: "Tidak boleh mengandung simbol dan spasi"))
        }
        
        return .init(value: value)
    }
}


