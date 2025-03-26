import Foundation

public struct ValidationError: Error {
    public let message: String
    
    public init(message: String) {
        self.message = message
    }
}

public struct ValidationResult {
    public let value: String
    public let error: ValidationError?
    
    public init(
        value: String,
        error: ValidationError? = nil
    ) {
        self.value = value
        self.error = error
    }
}

public extension ValidationResult {
    var isValid: Bool {
        error == nil
    }
}

public protocol Validator {
    func validate(_ value: String) -> ValidationResult
}
