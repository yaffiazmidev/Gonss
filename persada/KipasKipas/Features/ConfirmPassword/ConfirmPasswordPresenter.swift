//
//  ConfirmPasswordPresenter.swift
//  KipasKipas
//
//  Created by DENAZMI on 02/02/23.
//

import UIKit

protocol IConfirmPasswordPresenter {
    typealias CompletionResult<T> = Swift.Result<T, DataTransferError>
    
    func presentVerifyPassword(with result: CompletionResult<RemoteDefaultBool?>)
}

class ConfirmPasswordPresenter: IConfirmPasswordPresenter {
	weak var controller: IConfirmPasswordViewController?
	
	init(controller: IConfirmPasswordViewController) {
		self.controller = controller
	}
    
    func presentVerifyPassword(with result: CompletionResult<RemoteDefaultBool?>) {
        switch result {
        case .failure(let error):
            guard let data = error.data else {
                controller?.displayError(message: error.message, code: error.statusCode)
                return
            }
            
            struct Root: Codable { let code, message: String? }
            
            guard let decodeError = try? JSONDecoder().decode(Root.self, from: data) else {
                controller?.displayError(message: error.message, code: error.statusCode)
                return
            }
            
            controller?.displayError(message: decodeError.message ?? "", code: Int(decodeError.code ?? "") ?? 404)
        case .success(_):
            controller?.displaySuccessVerifyPassword()
        }
    }
}
