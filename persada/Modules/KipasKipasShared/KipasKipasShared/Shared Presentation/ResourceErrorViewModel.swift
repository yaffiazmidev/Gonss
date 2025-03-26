import Foundation

public struct ResourceErrorViewModel {
    public let error: AnyError?
    
    public init(error: AnyError?) {
        self.error = error
    }
}
