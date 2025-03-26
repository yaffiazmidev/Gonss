import Foundation

public struct IndonesiaPhoneNumberValidator: Validator {
    
    private let message: String
    
    public init(message: String = "Format nomor telepon harus 62xx atau 08xx") {
        self.message = message
    }
    
    public func validate(_ value: String) -> ValidationResult {
        if value.count >= 2 && !value.hasPrefix("62") && !value.hasPrefix("08") {
            guard !value.hasPrefix("8") else {
                return .init(value: value)
            }
            return .init(
                value: value,
                error: ValidationError(message: message)
            )
        } else {
            return .init(value: value)
        }
    }
}

public struct PhoneNumberOnlyValidator: Validator {
    
    public init() {}
    
    public func validate(_ value: String) -> ValidationResult {
        if !isInteger(text: value) {
            return .init(
                value: "",
                error: ValidationError(message: "Nomor telepon harus angka")
            )
        } else {
            return .init(value: value)
        }
    }
    
    private func isInteger(text: String) -> Bool {
        guard !text.isEmpty else { return false }
        
        for character in text {
            if !character.isNumber {
                return false // Found a non-digit character
            }
        }
        
        return true
    }
}
