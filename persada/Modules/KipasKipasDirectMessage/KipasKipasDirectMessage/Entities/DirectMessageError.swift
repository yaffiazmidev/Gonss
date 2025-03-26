import Foundation

public struct DirectMessageErrorReason: Error {
    public let errorCode: String
    public let errorMessage: String?
    
    public init(errorCode: String, errorMessage: String? = nil) {
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}

public enum DirectMessageError: Error {
   case general(DirectMessageErrorReason)
   case customWithObject(RemoteErrorConfirmSetDiamondData)
}
