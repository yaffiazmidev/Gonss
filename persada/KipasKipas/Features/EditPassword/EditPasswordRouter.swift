//
//  EditPasswordRouter.swift
//  KipasKipas
//
//  Created by DENAZMI on 14/03/23.
//

import Foundation
import UIKit

protocol IEditPasswordRouter {
}

class EditPasswordRouter: IEditPasswordRouter {
    weak var controller: EditPasswordViewController?
    
    init(controller: EditPasswordViewController?) {
        self.controller = controller
    }
}

extension EditPasswordRouter {
    static func configure(controller: EditPasswordViewController) {
        let router = EditPasswordRouter(controller: controller)
        let network = DIContainer.shared.apiDataTransferService
        let presenter = EditPasswordPresenter(controller: controller)
        let interactor = EditPasswordInteractor(presenter: presenter, network: network)
        controller.router = router
        controller.interactor = interactor
    }
}
