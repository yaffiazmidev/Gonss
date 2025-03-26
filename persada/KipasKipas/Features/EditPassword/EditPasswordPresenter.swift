//
//  EditPasswordPresenter.swift
//  KipasKipas
//
//  Created by DENAZMI on 14/03/23.
//

import UIKit

protocol IEditPasswordPresenter {
    typealias Completion<T> = Swift.Result<T, DataTransferError>
    
    func presentUpdatePassword(with result: Completion<RemoteUpdatePassword?>)
}

class EditPasswordPresenter: IEditPasswordPresenter {
	weak var controller: IEditPasswordViewController?
	
	init(controller: IEditPasswordViewController) {
		self.controller = controller
	}
    
    func presentUpdatePassword(with result: Completion<RemoteUpdatePassword?>) {
        switch result {
        case .failure(let error):
            guard let data = error.data else {
                controller?.displayError(with: error.message, code: error.statusCode)
                return
            }
            
            struct Root: Codable {
                let code: String?
                let message: String?
            }
            
            guard let decodeError = try? JSONDecoder().decode(Root.self, from: data) else {
                controller?.displayError(with: error.message, code: error.statusCode)
                return
            }
            
            controller?.displayError(with: decodeError.message ?? "", code: Int(decodeError.code ?? "") ?? 404)
        case .success(let response):
            if let data = response?.data {
                updateLoginData(data: data)
            }
            controller?.displayUpdatePassword(phoneNumber: response?.data?.userMobile ?? "")
        }
    }
}
