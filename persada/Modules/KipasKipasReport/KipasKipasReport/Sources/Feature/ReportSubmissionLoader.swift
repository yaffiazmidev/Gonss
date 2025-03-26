import Foundation

public struct ReportSubmissionRequest: Encodable {
    public let reasonReport: ReportReason
    public let type, targetReportedId: String
    
    public init(reasonReport: ReportReason, type: String, targetReportedId: String) {
        self.reasonReport = reasonReport
        self.type = type
        self.targetReportedId = targetReportedId
    }
}

public protocol ReportSubmissionLoader {
    typealias Result = Swift.Result<Void, Error>
    func submit(_ req: ReportSubmissionRequest, completion: @escaping (Result) -> Void)
}
