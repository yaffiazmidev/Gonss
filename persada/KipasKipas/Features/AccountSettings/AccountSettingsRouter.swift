//
//  AccountSettingsRouter.swift
//  KipasKipas
//
//  Created by DENAZMI on 05/03/23.
//

import UIKit
import KipasKipasShared

protocol IAccountSettingsRouter {
    func navigateToEditUsername()
    func navigateToEditPhoneNumber()
    func navigateToEditPassword()
    func presentCustomPopUpViewController(title: String, description: String)
}

class AccountSettingsRouter: IAccountSettingsRouter {
    weak var controller: AccountSettingsViewController?
    
    init(controller: AccountSettingsViewController?) {
        self.controller = controller
    }
    
    func navigateToEditUsername() {
        let vc = EditUsernameViewController()
        vc.bindNavigationBar("Ubah Username")
        controller?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigateToEditPhoneNumber() {
        let vc = EditPhoneNumberViewController()
        vc.bindNavigationBar("Ubah Nomor Telfon")
        controller?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigateToEditPassword() {
        let vc = EditPasswordViewController()
        vc.bindNavigationBar("Ubah Password")
        controller?.navigationController?.pushViewController(vc, animated: true)
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

extension AccountSettingsRouter {
    static func configure(controller: AccountSettingsViewController) {
        let router = AccountSettingsRouter(controller: controller)
        let presenter = AccountSettingsPresenter(controller: controller)
        let network = DIContainer.shared.apiDataTransferService
        let interactor = AccountSettingsInteractor(presenter: presenter, network: network)
        controller.router = router
        controller.interactor = interactor
    }
}
