//
//  MyBankAccountConfirmationInteractor.swift
//  KipasKipas
//
//  Created by Yaffi Azmi on 25/10/21.
//

import UIKit

protocol MyBankAccountConfirmationInteractorBusinessLogic: AnyObject {
	var parameters: [String: Any]? { get }
    
    func verifyPAssword(password: String, id: String)
}

class MyBankAccountConfirmationInteractor: MyBankAccountConfirmationInteractorBusinessLogic {
    
    var presenter: MyBankAccountConfirmationPresenterPresentingLogic!
    var parameters: [String: Any]?
    
    func verifyPAssword(password: String, id: String) {
        WithdrawalBalanceOperation.VerifyPassword(request: VerifyPasswordRequest(password: password)) { result in
            switch result {
            case .success(let value):
                value ? self.deleteBankAccount(id: id) : self.presenter.verifyPassword(isSuccess: false)
            case .failure(let error):
                print(error)
                self.presenter.verifyPassword(isSuccess: false)
            case .error:
                print("Something swrong!")
                self.presenter.verifyPassword(isSuccess: false)
            }
        }
    }
    
    func deleteBankAccount(id: String) {
        WithdrawalBalanceOperation.deleteBankAccount(request: DeleteBankAccountRequest(id: id)) { result in
            switch result {
            case .success(_):
                self.presenter.successDeleteBankAccount()
            case .failure(_):
                self.presenter.failedDeleteBankAccount()
            case .error:
                self.presenter.failedDeleteBankAccount()
            }
        }
    }
}
