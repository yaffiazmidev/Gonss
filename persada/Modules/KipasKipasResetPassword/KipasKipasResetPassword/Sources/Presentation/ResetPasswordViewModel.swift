import Foundation

public struct ResetPasswordViewModel {
    private let code: String
    
    public init(code: String) {
        self.code = code
    }
    
    public var isSuccess: Bool {
        return code == "1000"
    }
}
