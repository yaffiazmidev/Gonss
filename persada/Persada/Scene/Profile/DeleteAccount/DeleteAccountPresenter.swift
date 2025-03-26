//
//  DeleteAccountPresenter.swift
//  KipasKipas
//
//  Created by DENAZMI on 26/01/22.
//

import UIKit

protocol DeleteAccountPresenterPresentingLogic {
    func presentSuccessDeleteMyAccount()
    func presentFailedDeleteMyAccount()
    func presentLogout(isSuccess: Bool)
}

class DeleteAccountPresenter: DeleteAccountPresenterPresentingLogic {
	weak var controller: DeleteAccountViewControllerDisplayLogic?
	
	init(_ controller: DeleteAccountViewControllerDisplayLogic) {
		self.controller = controller
	}
    
    func presentSuccessDeleteMyAccount() {
        controller?.displayDeleteMyAccount()
    }
    
    func presentFailedDeleteMyAccount() {
        controller?.displayFailedDeleteMyAccount()
    }
    
    func presentLogout(isSuccess: Bool) {
        controller?.displayLogout(isSuccess: isSuccess)
    }
}
