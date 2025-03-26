//
//  VerificationCodePresenter.swift
//  KipasKipas
//
//  Created by DENAZMI on 28/11/22.
//

import UIKit

protocol IVerificationCodePresenter {
    typealias VerificationCodeResult<T> = Swift.Result<T, DataTransferError>
    
    func presentRequestOTP(with result: VerificationCodeResult<RemoteAuthOTP?>)
    func presentSuccessAddBankAccount(response: AddAccountBankResponse?)
    func presentFailedAddBankAccount(error: ErrorMessage?)
}

class VerificationCodePresenter: IVerificationCodePresenter {
	weak var controller: IVerificationCodeViewController?
	
	init(controller: IVerificationCodeViewController) {
		self.controller = controller
	}
    
    func presentRequestOTP(with result: VerificationCodeResult<RemoteAuthOTP?>) {
        switch result {
        case .failure(let error):
            let errorItem = mapAuthOTPError(error.data)
            controller?.displayFailedRequestOTP(statusCode: error.statusCode, countdownTimeLeft: errorItem?.data?.tryInSecond ?? 0)
        case .success(let response):
            controller?.displaySuccessRequestOTP(countdownTimeLeft: response?.data?.expireInSecond ?? 0)
            
        }
    }
    
    func presentSuccessAddBankAccount(response: AddAccountBankResponse?) {
        controller?.displaySuccessAddBankAccount(bank: response?.data)
    }
    
    func presentFailedAddBankAccount(error: ErrorMessage?) {
        controller?.displayFailedAddBankAccount(statusCode: error?.statusCode ?? 404, errorMessage: error?.statusData ?? .get(.somethingWrong))
    }
    
    private func mapAuthOTPError(_ data: Data?) -> RemoteAuthOTPError? {
        guard let data = data else {
            return nil
        }
        
        do {
            let response = try JSONDecoder().decode(RemoteAuthOTPError.self, from: data)
            return response
        } catch {
            return nil
        }
    }
}
