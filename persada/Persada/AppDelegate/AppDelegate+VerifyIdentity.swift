//
//  AppDelegate+VerifyIdentity.swift
//  KipasKipas
//
//  Created by DENAZMI on 12/06/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit
import KipasKipasShared
import KipasKipasNetworking
import KipasKipasNetworkingUtils
import KipasKipasVerificationIdentity
import KipasKipasVerificationIdentityiOS
import KipasKipasDirectMessageUI

var showVerifyIdentity: ((String) -> Void)?
var showVerifyIdentityStatus: (() -> Void)?

extension AppDelegate {
    
    func configureVerifyIdentityFeature() {
        KipasKipas.showVerifyIdentity = showVerifyIdentityController(by:)
        KipasKipas.showVerifyIdentityStatus = showVerifyIdentityStatusController
    }
    
    private func showVerifyIdentityController(by status: String) {
        let checker: VerifyIdentityChecker = RemoteVerifyIdentityChecker(
            baseURL: baseURL,
            client: authenticatedHTTPClient
        )
        
        let viewModel = VerifyIdentityViewModel(checker: MainQueueDispatchDecorator(decoratee: checker))
        let router = VerifyIdentityRouter(handleBackToBalanceView: handleBackToBalanceView)
        let viewController = VerifyIdentityController(
            viewModel: viewModel,
            verificationStatus: VerifyIdentityStatusType(rawValue: status) ?? .unverified
        )
        viewModel.delegate = viewController
        router.controller = viewController
        viewController.router = router
        window?.topNavigationController?.pushViewController(viewController, animated: true)
    }
    
    private func showVerifyIdentityStatusController() {
        let statusLoader: VerifyIdentityStatusLoader = RemoteVerifyIdentityStatusLoader(
            baseURL: baseURL,
            client: authenticatedHTTPClient
        )
        
        let viewModel = VerifyIdentityUploadStatusViewModel(statusLoader: MainQueueDispatchDecorator(decoratee: statusLoader))
        
        let viewController = VerifyIdentityUploadStatusController(viewModel: viewModel, handleBackToBalanceView: handleBackToBalanceView)
        viewModel.delegate = viewController
        window?.topNavigationController?.pushViewController(viewController, animated: true)
    }
    
    private func handleBackToBalanceView() {
        window?.topViewController?.popToViewController(ofType: BalanceMianViewController.self)
    }
}

extension UIViewController {
    func popToViewController<T: UIViewController>(ofType type: T.Type, animated: Bool = true) {
        if let navigationController = self.navigationController {
            guard let vc = navigationController.viewControllers.lazy.filter({ $0 is T }).first else { return }
            navigationController.popToViewController(vc, animated: animated)
        }
    }
}

extension MainQueueDispatchDecorator: VerifyIdentityChecker where T == VerifyIdentityChecker {
    public func check(completion: @escaping (VerifyIdentityChecker.Result) -> Void) {
        decoratee.check { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
