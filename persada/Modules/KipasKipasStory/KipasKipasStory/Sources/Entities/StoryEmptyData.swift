import Foundation

public struct StoryEmptyData: Codable {
    public let code: String
    public let message: String
    
    public init(code: String, message: String) {
        self.code = code
        self.message = message
    }
}
