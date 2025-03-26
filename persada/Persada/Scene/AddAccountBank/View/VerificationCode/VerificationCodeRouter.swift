//
//  VerificationCodeRouter.swift
//  KipasKipas
//
//  Created by DENAZMI on 28/11/22.
//

import Foundation

protocol IVerificationCodeRouter {
	// do someting...
}

class VerificationCodeRouter: IVerificationCodeRouter {
    weak var controller: VerificationCodeViewController?
    
    init(controller: VerificationCodeViewController?) {
        self.controller = controller
    }
}

extension VerificationCodeRouter {
    static func configure(_ controller: VerificationCodeViewController) {
        let router = VerificationCodeRouter(controller: controller)
        let presenter = VerificationCodePresenter(controller: controller)
        let apiService = DIContainer.shared.apiDataTransferService
        let interactor = VerificationCodeInteractor(presenter: presenter, apiService: apiService)
        controller.router = router
        controller.interactor = interactor
    }
}
