//
//  CommentHalftRouter.swift
//  KipasKipas
//
//  Created by DENAZMI on 08/08/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasReport
import KipasKipasShared

protocol ICommentHalftRouter {
    func navigateToCustomCommentInput(attributedText: NSAttributedString, followings: [RemoteFollowingContent], isAutoMention: Bool)
    func navigateToReport(type: ReportType, id: String, accountId: String)
    func showReportPopUp()
    func showDeleteAlert(completion: (() -> Void)?)
    func navigateToProfile(id: String, type: String)
    func navigateToProfile(with username: String)
}

class CommentHalftRouter: ICommentHalftRouter {
    
    let controller: CommentHalftController
    
    init(controller: CommentHalftController) {
        self.controller = controller
    }
    
    func navigateToProfile(id: String, type: String) {
        let vc =  AnotherUserProfileViewController(mainView: AnotherUserProfileView(), dataSource: NewUserProfileModel.DataSource(id: id, type: type))
        vc.setProfile(id: id, type: type)
        vc.bindNavigationBar("", true)
        vc.hidesBottomBarWhenPushed = true
        controller.present(vc, animated: true)
    }
    
    func navigateToProfile(with username: String) {
        let vc =  AnotherUserProfileViewController(mainView: AnotherUserProfileView(), dataSource: NewUserProfileModel.DataSource())
        vc.username = username
        vc.bindNavigationBar("", true)
        vc.hidesBottomBarWhenPushed = true
        controller.present(vc, animated: true)
    }
    
    func navigateToCustomCommentInput(attributedText: NSAttributedString, followings: [RemoteFollowingContent], isAutoMention: Bool) {
        let vc = CustomCommentInputViewController(draftAttributeText: attributedText, followings: followings, isAutoMention: isAutoMention)
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        vc.delegate = controller
        controller.present(vc, animated: false)
    }
    
    func navigateToReport(type: ReportType, id: String, accountId: String) {
        let kind = ReportKind(rawValue: type.rawValue)!
        showCommentReport?(.init(
            targetReportedId: id,
            accountId: accountId, 
            username: nil,
            kind: kind,
            delegate: controller
        ))
    }
    
    func showReportPopUp() {
        let customAlert = CustomPopUpViewController(title: .get(.reportedTitle), description: .get(.reportedDescription), okBtnTitle: .get(.back), isHideIcon: true)
        customAlert.modalPresentationStyle = .overCurrentContext
        controller.present(customAlert, animated: false)
    }
    
    func showDeleteAlert(completion: (() -> Void)?) {
        let customAlert = CustomPopUpViewController(title: .get(.deleteComment), description: .get(.deleteCommentAsk), withOption: true, okBtnTitle: "Hapus", isHideIcon: true)
        customAlert.modalPresentationStyle = .overCurrentContext
        customAlert.handleTapOKButton = {
            completion?()
        }
        controller.present(customAlert, animated: false)
    }
}

extension CommentHalftRouter {
    static func configure(_ controller: CommentHalftController) {
        let networkService = DIContainer.shared.apiDataTransferService
        let presenter = CommentHalftPresenter(controller: controller)
        let worker = CommentHalftWorker(network: networkService)
        let interactor = CommentHalftInteractor(presenter: presenter, worker: worker)
        let router = CommentHalftRouter(controller: controller)
        let mainView = CommentHalftView()
        
        controller.interactor = interactor
        controller.router = router
        controller.mainView = mainView
    }
}
