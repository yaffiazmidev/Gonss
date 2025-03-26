import Foundation

public struct KKErrorNetworkRemoteResponse: Codable {
    public let code, message, data: String?
}

public struct KKErrorDescription: Codable {
    public let code, message: String?
}

public struct KKErrorNetworkResponse: Hashable {
    public let code, message: String
    public let data: Data?
    
    public init(code: String, message: String, data: Data? = nil){
        self.code = code
        self.message = message
        self.data = data
    }
    
    public static func fromRemote(_ error: KKErrorNetworkRemoteResponse) -> KKErrorNetworkResponse {
        return KKErrorNetworkResponse(
            code: error.code ?? "Unknown",
            message: error.data ?? error.message ?? "Unknown Error"
        )
    }
}
