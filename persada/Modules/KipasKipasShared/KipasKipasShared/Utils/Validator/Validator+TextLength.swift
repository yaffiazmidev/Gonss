import Foundation

public struct TextLengthValidator: Validator {
    
    public enum InputType {
        case number
        case char
        
        var descriptiveText: String {
            switch self {
            case .char: "karakter"
            case .number: "angka"
            }
        }
    }
    
    private let min: Int
    private let max: Int
    private let inputType: InputType
    private let message: String?
    
    public init(
        min: Int,
        max: Int,
        inputType: InputType,
        message: String? = nil
    ) {
        self.min = min
        self.max = max
        self.inputType = inputType
        self.message = message
    }
    
    public func validate(_ value: String) -> ValidationResult {
        if value.count >= 0 && value.count < min {
            return .init(
                value: value,
                error: ValidationError(message: message ?? "Tidak boleh kurang dari \(min)" + " \(inputType.descriptiveText)")
            )
        } else if value.count >= 0 && value.count > max {
            return .init(
                value: value,
                error: ValidationError(message: message ?? "Tidak boleh lebih dari \(max)" + " \(inputType.descriptiveText)")
            )
        } else {
            return .init(value: value)
        }
    }
}
