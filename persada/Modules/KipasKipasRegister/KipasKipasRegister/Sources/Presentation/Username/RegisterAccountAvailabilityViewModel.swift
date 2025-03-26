import Foundation

public struct RegisterAccountAvailabilityViewModel {
    public let isExists: Bool
    
    public init(isExists: Bool) {
        self.isExists = isExists
    }
}
