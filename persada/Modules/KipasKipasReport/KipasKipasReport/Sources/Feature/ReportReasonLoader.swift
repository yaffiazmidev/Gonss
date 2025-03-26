import Foundation

public protocol ReportReasonLoader {
    typealias Result = Swift.Result<ReportReasonResponse, Error>
    func fetch(_ reportType: ReportKind, completion: @escaping (Result) -> Void)
}
