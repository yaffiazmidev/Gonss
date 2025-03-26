import Foundation

public struct ReportReason: Codable {
    public let id, type: String
    public var value: String
}

public extension ReportReason {
    var isOtherType: Bool {
        return type == "OTHERS"
    }
}
