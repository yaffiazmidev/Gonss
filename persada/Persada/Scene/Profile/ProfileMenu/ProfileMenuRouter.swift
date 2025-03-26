//
//  ProfileMenuRouter.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 10/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.

import UIKit
import KipasKipasDirectMessageUI
import KipasKipasDirectMessage
import KipasKipasShared

protocol ProfileMenuRouting {

	func routeTo(_ route: ProfileMenuModel.Route)
}

final class ProfileMenuRouter: Routeable {

	private weak var viewController: UIViewController?

	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
}


// MARK: - ProfileMenuRouting
extension ProfileMenuRouter: ProfileMenuRouting {

	func routeTo(_ route: ProfileMenuModel.Route) {
		DispatchQueue.main.async {
			switch route {

			case .dismiss(let id, let showNavBar):
				self.dismiss(id, showNavBar)

				case .xScene(let data):
					self.showXSceneBy(data)
				case .navigateToProfileSettingAccount:
					self.navigateToProfileSetting()
				case .navigateToTnC:
					self.navigateToTnC()
                case .navigateToPrivacyPolicy:
                    self.navigateToPrivacyPolicy()
				case .navigateToMyAddress:
					self.navigateToMyAddress()
				case .navigateToProfileEdit(let id):
					self.navigateToProfileEdit(id: id)
				case .dismissToLogin: break
			case .navigateToRekeningSaya:
				self.navigateToRekeningSaya()
            case .navigateToFundraising:
                self.navigateToFundraising()
			case .navigateToSetDiamond:
				self.navigateToSetDiamond()
            case .navigateToWithdrawDiamondDiamond:
                self.navigateToWithdrawDiamond()
            case .navigateToTopUpCoin:
                self.naviagetToTopUpCoin()
			}
		}
	}
}


// MARK: - Private Zone
private extension ProfileMenuRouter {

	func dismiss(_ id: String, _ showNavBar: Bool = false) {
		if id == getIdUser() && showNavBar {
			viewController?.navigationController?.popViewController(animated: true)
		} else {
			viewController?.navigationController?.setNavigationBarHidden(true, animated: false)
			viewController?.navigationController?.popViewController(animated: true)
		}
		
	}

	func showXSceneBy(_ data: Int) {
		print("will show the next screen")
	}

	func navigateToProfileSetting(){
		let controller = AccountSettingsViewController()
        controller.bindNavigationBar("Pengaturan Akun")
		viewController?.navigationController?.pushViewController(controller, animated: true)
	}

	func navigateToTnC(){
        let browserController = AlternativeBrowserController(url: .get(.kipasKipasTermsConditionsUrl))
        browserController.bindNavigationBar(.get(.syaratKetentuan))
        
        viewController?.navigationController?.pushViewController(browserController, animated: true)
	}
    
    func navigateToPrivacyPolicy() {
        let browserController = AlternativeBrowserController(url: .get(.kipasKipasPrivacyPolicyUrl))
        browserController.bindNavigationBar(.get(.kebijakanPrivasi))
        viewController?.navigationController?.pushViewController(browserController, animated: true)
    }
	
	func navigateToMyAddress(){
		let addressController = AddressController(mainView: AddressView(), type: .buyer)
		viewController?.navigationController?.pushViewController(addressController, animated: true)
	}

	func navigateToProfileEdit(id: String){
		let profileController = EditProfileViewController(mainView: EditProfileView(), dataSource: EditProfileModel.DataSource(id: id))
		viewController?.navigationController?.pushViewController(profileController, animated: true)
	}

	func navigateToRekeningSaya() {
        let vc = AccountDestinationViewController(isMyAccount: true)
        vc.bindNavigationBar(String.get(.rekeningSaya))
        viewController?.navigationController?.pushViewController(vc, animated: true)
	}
    
    func navigateToFundraising() {
        let vc = DonationViewController()
        vc.bindNavigationBar()
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigateToSetDiamond() {
        let vc = SetDiamondsReceivedUIFactory.create(accountId: getIdUser())
        vc.bindNavigationBar()
        vc.hidesBottomBarWhenPushed = true
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
	
	func navigateToWithdrawDiamond() {
        let vc = DiamondWithdrawalRouter.create(
//            diamond: KKCache.common.readInteger(key: .diamond) ?? 0,
            type:"LIVE",
            baseUrl: APIConstants.baseURL,
            authToken: getToken() ?? "",
            showListBank: showListBank, 
            showVerifyIdentity: showVerifyIdentity
        )
		vc.bindNavigationBar()
		vc.hidesBottomBarWhenPushed = true
		viewController?.navigationController?.pushViewController(vc, animated: true)
	}
    
    func naviagetToTopUpCoin() { 
        let vc = BalanceMianRouter.create(
            baseUrl: APIConstants.baseURL,
            authToken: getToken() ?? "",
            showListBank: showListBank,
            showVerifyIdentity: showVerifyIdentity,
            showVerifyIdentityStatus: showVerifyIdentityStatus
        )
        vc.hidesBottomBarWhenPushed = true
        vc.overrideUserInterfaceStyle = .light
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
