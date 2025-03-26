import Foundation

public struct LoginViewModel {
    public let response: LoginResponse
    
    public init(response: LoginResponse) {
        self.response = response
    }
}
