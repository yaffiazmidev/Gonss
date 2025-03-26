//
//  OTPRouter.swift
//  Persada
//
//  Created by monggo pesen 3 on 15/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import UIKit

protocol OTPRouting {
	
	func routeTo(_ route: OTPModel.Route)
}

final class OTPRouter: Routeable {
	
	private weak var viewController: UIViewController?
	
	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
}


// MARK: - OTPRouting
extension OTPRouter: OTPRouting {
	
	func routeTo(_ route: OTPModel.Route) {
		DispatchQueue.main.async {
			switch route {
				
			case .dismissOTPScene:
				self.dismissOTPScene()
			case let .inputUserScene(data, otpCode):
				self.showInputUserScene(data, otpCode)
			case .navigateToResetPassword(id: let id, phoneNumber: let phoneNumber, otp: let otp, let otpPlatform):
                self.showResetPassword(number: phoneNumber, otp: otp, id: id, otpPlatform: otpPlatform)
			}
		}
	}
}


// MARK: - Private Zone
private extension OTPRouter {
	
	func dismissOTPScene() {
		viewController?.dismiss(animated: true)
	}
	
	func showInputUserScene(_ data: String, _ otp: String) {
        showUserBasicInfo?(.init(otp: otp, phone: data))
	}
	
    func showResetPassword(number: String, otp: String, id: String, otpPlatform: String){}
}
