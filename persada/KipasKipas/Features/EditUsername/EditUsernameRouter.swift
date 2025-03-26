//
//  EditUsernameRouter.swift
//  KipasKipas
//
//  Created by DENAZMI on 12/03/23.
//

import UIKit
import KipasKipasShared

protocol IEditUsernameRouter {
    func presentCustomPopUpViewController(title: String, description: String)
}

class EditUsernameRouter: IEditUsernameRouter {
    weak var controller: EditUsernameViewController?
    
    init(controller: EditUsernameViewController?) {
        self.controller = controller
    }
    
    func presentCustomPopUpViewController(title: String, description: String) {
        let vc = CustomPopUpViewController(
            title: title, description: description,
            iconImage: UIImage(named: "img_warning_red"),
            iconHeight: 50, okBtnTitle: "Oke, saya mengerti.",
            isHideIcon: false,
            okBtnBgColor: .primary
        )
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        controller?.present(vc, animated: true, completion: nil)
    }
}

extension EditUsernameRouter {
    static func configure(controller: EditUsernameViewController) {
        let router = EditUsernameRouter(controller: controller)
        let presenter = EditUsernamePresenter(controller: controller)
        let network = DIContainer.shared.apiDataTransferService
        let interactor = EditUsernameInteractor(presenter: presenter, network: network)
        controller.router = router
        controller.interactor = interactor
    }
}
