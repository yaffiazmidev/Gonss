//
//  EditPhoneNumberRouter.swift
//  KipasKipas
//
//  Created by DENAZMI on 21/03/23.
//

import UIKit
import KipasKipasShared

protocol IEditPhoneNumberRouter {
    func presentCustomPopUpViewController(title: String, description: String)
    func navigateToOTPMethodOption(phoneNumber: String, handleEditPhoneNumberCallback: @escaping (([String: Any]) -> Void))
}

class EditPhoneNumberRouter: IEditPhoneNumberRouter {
    weak var controller: EditPhoneNumberViewController?
    
    init(controller: EditPhoneNumberViewController?) {
        self.controller = controller
    }
    
    func navigateToOTPMethodOption(phoneNumber: String, handleEditPhoneNumberCallback: @escaping (([String: Any]) -> Void)) {
        let otpMethodOption = OTPMethodOptionViewController(
            otpFrom: .editPhoneNumber,
            phoneNumber: phoneNumber,
            whatsappCountdown: CountdownManager(
                notificationCenter: NotificationCenter.default,
                willResignActive: UIApplication.willResignActiveNotification,
                willEnterForeground: UIApplication.willEnterForegroundNotification),
            smsCountdown: CountdownManager(
                notificationCenter: NotificationCenter.default,
                willResignActive: UIApplication.willResignActiveNotification,
                willEnterForeground: UIApplication.willEnterForegroundNotification)
        )
        otpMethodOption.handleEditPhoneNumberCallback = handleEditPhoneNumberCallback
        controller?.navigationController?.pushViewController(otpMethodOption, animated: true)
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

extension EditPhoneNumberRouter {
    static func configure(controller: EditPhoneNumberViewController) {
        let router = EditPhoneNumberRouter(controller: controller)
        let presenter = EditPhoneNumberPresenter(controller: controller)
        let network = DIContainer.shared.apiDataTransferService
        let interactor = EditPhoneNumberInteractor(presenter: presenter, network: network)
        controller.router = router
        controller.interactor = interactor
    }
}
