//
//  MyBankAccountConfirmationPresenter.swift
//  KipasKipas
//
//  Created by Yaffi Azmi on 25/10/21.
//

import UIKit

protocol MyBankAccountConfirmationPresenterPresentingLogic {
    func verifyPassword(isSuccess: Bool)
    func successDeleteBankAccount()
    func failedDeleteBankAccount()
}

class MyBankAccountConfirmationPresenter: MyBankAccountConfirmationPresenterPresentingLogic {
	weak var view: MyBankAccountConfirmationViewControllerDisplayLogic?
	
	init(view: MyBankAccountConfirmationViewControllerDisplayLogic) {
		self.view = view
	}
    
    func verifyPassword(isSuccess: Bool) {
        isSuccess ? view?.displaySuccessDeleteBankAccount() : view?.displayFailedDeleteBankAccount(.get(.errorVarifyPassword))
    }
    
    func successDeleteBankAccount() {
        view?.displaySuccessDeleteBankAccount()
    }
    
    func failedDeleteBankAccount() {
        view?.displayFailedDeleteBankAccount("Failed to delete bank account, please try again")
    }
}
