import UIKit
import KipasKipasReport
import KipasKipasReportiOS
import KipasKipasShared
import FeedCleeps

public final class KKReportUIComposer {
    private init() {}

    public static func composeReportWith(
        targetReportedId: String,
        kind: ReportKind,
        reasonLoader: ReportReasonLoader,
        reportSubmissionLoader: ReportSubmissionLoader,
        reportSubmissionCallback: @escaping () -> Void
    ) -> UIViewController {
        let viewController = KKReportViewController(
            targetReportedId: targetReportedId,
            reportKind: kind,
            reasonLoader: reasonLoader,
            reportSubmissionLoader: reportSubmissionLoader
        )
        viewController.reportSubmissionCallback = { DispatchQueue.main.async(execute: reportSubmissionCallback) }
        return viewController
    }
}
