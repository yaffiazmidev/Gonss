//
//  EditUsernamePresenter.swift
//  KipasKipas
//
//  Created by DENAZMI on 12/03/23.
//

import UIKit

protocol IEditUsernamePresenter {
    typealias Completion<T> = Swift.Result<T, DataTransferError>
    
    func presentUpdateUsername(with result: Completion<RemoteUpdateUsername?>)
}

class EditUsernamePresenter: IEditUsernamePresenter {
	weak var controller: IEditUsernameViewController?
	
	init(controller: IEditUsernameViewController) {
		self.controller = controller
	}
    
    func presentUpdateUsername(with result: Completion<RemoteUpdateUsername?>) {
        switch result {
        case .failure(let error):
            guard let data = error.data else {
                controller?.displayError(with: error.message, code: error.statusCode)
                return
            }
            
            struct Root: Codable { let code, message: String? }
            
            guard let decodeError = try? JSONDecoder().decode(Root.self, from: data) else {
                controller?.displayError(with: error.message, code: error.statusCode)
                return
            }
            controller?.displayError(with: decodeError.message ?? "", code: Int(decodeError.code ?? "") ?? 404)
        case .success(let response):
            if let data = response?.data {
                updateLoginData(data: data)
            }
            
            controller?.displayUpdateUsername()
        }
    }
}
