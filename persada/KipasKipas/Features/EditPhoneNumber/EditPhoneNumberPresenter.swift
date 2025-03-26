//
//  EditPhoneNumberPresenter.swift
//  KipasKipas
//
//  Created by DENAZMI on 21/03/23.
//

import UIKit

struct VerifyPhoneNumberEntity: Codable {
    let code: String?
    let message: String?
    let data: VerifyPhoneNumberData?
}

struct VerifyPhoneNumberData: Codable {
    let type: String?
    let message: String?
    let status: Bool?
}


protocol IEditPhoneNumberPresenter {
    typealias Completion<T> = Swift.Result<T, DataTransferError>
    
    func presentCheckPhoneNumber(with result: Completion<VerifyPhoneNumberEntity?>)
}

class EditPhoneNumberPresenter: IEditPhoneNumberPresenter {
	weak var controller: IEditPhoneNumberViewController?
	
	init(controller: IEditPhoneNumberViewController) {
		self.controller = controller
	}
    
    func presentCheckPhoneNumber(with result: Completion<VerifyPhoneNumberEntity?>) {
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
            controller?.displayCheckPhoneNumber(item: response?.data)
        }
    }
}
