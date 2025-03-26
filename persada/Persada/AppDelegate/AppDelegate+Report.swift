import UIKit
import Combine
import KipasKipasReport
import KipasKipasReportiOS
import KipasKipasShared
import FeedCleeps

var showFeedReport: ((ReportParameter) -> Void)?
var showCommentReport: ((ReportParameter) -> Void)?

private var cancellables: Set<AnyCancellable> = []

struct ReportParameter {
    let targetReportedId: String
    let accountId: String
    let username: String?
    let kind: ReportKind
    let delegate: ReportFeedDelegate
}

extension AppDelegate {
    func configureReportFeature() {
        KipasKipas.showFeedReport = { [weak self] in
            self?.showFeedReport($0)
            NotificationCenter.default.post(name: .shouldPausePlayer, object: nil)
        }
        KipasKipas.showCommentReport = { [weak self] in
            self?.showCommentReport($0)
            NotificationCenter.default.post(name: .shouldPausePlayer, object: nil)
        }
    }
    
    private func showFeedReport(_ parameter: ReportParameter) {
        let reasonLoader = RemoteReportReasonLoader(baseURL: baseURL, client: authenticatedHTTPClient)
        let reportSubmissionLoader = RemoteReportSubmissionLoader(baseURL: baseURL, client: authenticatedHTTPClient)
        let reportViewController = KKReportUIComposer.composeReportWith(
            targetReportedId: parameter.targetReportedId,
            kind: parameter.kind,
            reasonLoader: reasonLoader,
            reportSubmissionLoader: reportSubmissionLoader
        ) { [weak self] in
            self?.showReportedFeedStatusPopUp(parameter: parameter)
        }
        reportViewController.bindNavigationBar("Laporan", hasNavigationController)
        
        if isAuthenticated {
            pushViewControllerWithPresentFallback(reportViewController)
        } else {
            showAuthPopUp()
        }
    }
    
    private func showCommentReport(_ parameter: ReportParameter) {
        let reasonLoader = RemoteReportReasonLoader(baseURL: baseURL, client: authenticatedHTTPClient)
        let reportSubmissionLoader = RemoteReportSubmissionLoader(baseURL: baseURL, client: authenticatedHTTPClient)
        let reportViewController = KKReportUIComposer.composeReportWith(
            targetReportedId: parameter.targetReportedId,
            kind: parameter.kind,
            reasonLoader: reasonLoader,
            reportSubmissionLoader: reportSubmissionLoader
        ) { [weak self] in
            self?.showReportedCommentStatusPopUp()
        }
        
        reportViewController.bindNavigationBar("Laporan", hasNavigationController)
        
        if isAuthenticated {
            pushViewControllerWithPresentFallback(reportViewController)
        } else {
            showAuthPopUp()
        }
    }
    
    private func showReportedCommentStatusPopUp() {
        let customAlert = CustomPopUpViewController(
            title: .get(.reportedTitle),
            description: .get(.reportedDescription),
            okBtnTitle: .get(.back),
            isHideIcon: true
        )
        customAlert.modalPresentationStyle = .overCurrentContext
        customAlert.delegate = self
        
        dismissControllerWithPopFallback(animated: true) { [weak self] in
            self?.window?.topViewController?.present(customAlert, animated: true)
        }
    }
    
    private func showReportedFeedStatusPopUp(parameter: ReportParameter) {
        let destination = KKReportStatusViewController()
        destination.modalPresentationStyle = .fullScreen
        destination.backButton.tapPublisher
            .sink { [weak self] in
                parameter.delegate.reported()
                self?.dismiss(until: NewHomeController.self)
            }
            .store(in: &cancellables)
        
        if let username = parameter.username {
            destination.blockButton.setTitle("Blokir @" + username, for: .normal)
        }
        
        destination.blockButton.tapPublisher
            .sink { [weak self] in
                self?.showBlockConfirmationPopUp(parameter: parameter)
            }
            .store(in: &cancellables)
        
        window?.topViewController?.present(destination, animated: true)
    }
    
    private func showBlockConfirmationPopUp(parameter: ReportParameter) {
        let destination = CustomPopUpViewController(
            title: "Yakin memblokir pengguna?",
            description: "Pengguna yang telah diblokir tidak akan berinteraksi dengan Anda.",
            withOption: true,
            cancelBtnTitle: "Batal",
            okBtnTitle: "Ya, blokir",
            isHideIcon: true,
            actionStackAxis: .vertical
        )
        destination.modalPresentationStyle = .overCurrentContext
        
        destination.handleTapOKButton = { [weak self] in
            self?.blockedUserStore.insert([parameter.accountId]) { _ in}
            self?.showBlockStatusPopUp(parameter: parameter)
        }
        
        window?.topViewController?.present(destination, animated: true)
    }
    
    private func showBlockStatusPopUp(parameter: ReportParameter) {
        let destination = CustomPopUpViewController(
            title: "Berhasil memblokir",
            description: "Pengguna yang telah diblokir tidak akan berinteraksi dengan Anda.",
            iconImage: .illustrationStopHand,
            iconHeight: 100,
            okBtnTitle: "Oke",
            isHideIcon: false
        )
        destination.modalPresentationStyle = .overCurrentContext
        
        destination.handleTapOKButton = { [weak self] in
            parameter.delegate.reported()
            self?.dismiss(until: NewHomeController.self)
        }
        
        window?.topViewController?.present(destination, animated: true)
    }
    
    private func showAuthPopUp() {
        let popup = AuthPopUpViewController(mainView: AuthPopUpView())
        popup.modalPresentationStyle = .overFullScreen
        popup.modalTransitionStyle = .crossDissolve
        popup.handleWhenNotLogin = {
            popup.dismiss(animated: true, completion: nil)
        }
        
        window?.topViewController?.dismiss(animated: true, completion: { [window] in
            window?.topViewController?.present(popup, animated: true)
        })
    }
}

extension AppDelegate: CustomPopUpViewControllerDelegate {
    func didSelectOK() {
        NotificationCenter.default.post(name: .shouldResumePlayer, object: nil)
    }
}
