import Foundation

/*
 This is a special case for KipasKipas account username
 A username can contain a (.) dot and (_) underscore symbol
 But it can't be at the beginning or at the end of a sentence.
 */
public struct UsernameSpecialCharValidator: Validator {
 
    public init() {}
    
    public func validate(_ value: String) -> ValidationResult {
        if value.hasPrefix("_") || value.hasPrefix(".") || value.isEmpty {
            return .init(value: value, error: ValidationError(message: "Tidak boleh mengandung simbol diawal dan diakhir"))
        } else if value.hasSuffix("_") || value.hasSuffix(".") || value.isEmpty {
            return .init(value: value, error: ValidationError(message: "Tidak boleh mengandung simbol diawal dan diakhir"))
        } else {
            return .init(value: value)
        }
    }
}
