import Foundation

public struct RootData<Response: Codable>: Codable {
    public let code, message: String
    public let data: Response
}

