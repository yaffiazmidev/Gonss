//
//  AccountSettingsPresenter.swift
//  KipasKipas
//
//  Created by DENAZMI on 05/03/23.
//

import UIKit

protocol IAccountSettingsPresenter {
    typealias Completion<T> = Swift.Result<T, DataTransferError>
    typealias CompletionHandler<T> = Swift.Result<T, DataTransferError>
    
    func presentCheckUsername(with result: Completion<DefaultEntity?>)
    func presentCheckPhoneNumber(with result: Completion<DefaultEntity?>)
    
    func presentCheckReferalCode(with result: CompletionHandler<ProfileResult?>)
    
}

class AccountSettingsPresenter: IAccountSettingsPresenter {
    
    
    func presentCheckReferalCode(with result: CompletionHandler<ProfileResult?>) {
        
        switch result {
            case .failure(let error):
                return
            case .success(let response):
            controller?.displayReferralCode(referralCode: response?.data?.referralCode)
        }
        
    }
    
	weak var controller: IAccountSettingsViewController?
	
	init(controller: IAccountSettingsViewController) {
		self.controller = controller
	}
    
    func presentCheckUsername(with result: Completion<DefaultEntity?>) {
        switch result {
        case .failure(let error):
            guard let data = error.data else {
                controller?.displayCheckUsernameError(with: error.message, code: error.statusCode)
                return
            }
            
            struct Root: Codable { let code, message: String? }
            
            guard let decodeError = try? JSONDecoder().decode(Root.self, from: data) else {
                controller?.displayCheckUsernameError(with: error.message, code: error.statusCode)
                return
            }
            controller?.displayCheckUsernameError(with: decodeError.message ?? "", code: Int(decodeError.code ?? "") ?? 404)
        case .success(_):
            controller?.displayCheckUsername()
        }
    }
    
    func presentCheckPhoneNumber(with result: Completion<DefaultEntity?>) {
        switch result {
        case .failure(let error):
            guard let data = error.data else {
                controller?.displayCheckPhoneNumberError(with: error.message, code: error.statusCode)
                return
            }
            
            struct Root: Codable { let code, message: String? }
            
            guard let decodeError = try? JSONDecoder().decode(Root.self, from: data) else {
                controller?.displayCheckPhoneNumberError(with: error.message, code: error.statusCode)
                return
            }
            controller?.displayCheckPhoneNumberError(with: decodeError.message ?? "", code: Int(decodeError.code ?? "") ?? 404)
        case .success(_):
            controller?.displayCheckPhoneNumber()
        }
    }
}
