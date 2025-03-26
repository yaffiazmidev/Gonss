//
//  OTPPresenter.swift
//  Persada
//
//  Created by monggo pesen 3 on 15/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation

protocol OTPPresentationLogic {
    typealias Completion<T> = Swift.Result<T, DataTransferError>
    
    func presentResponse(_ response: OTPModel.Response)
    func presentOTP(item: AuthOTPItem)
    func presentOTPError(item: AuthOTPItem)
    func presentUpdatePhoneNumber(with result: Completion<RemoteUpdatePhoneNumber?>)
}

final class OTPPresenter: Presentable {
    private weak var viewController: OTPDisplayLogic?
    
    init(_ viewController: OTPDisplayLogic?) {
        self.viewController = viewController
    }
}


// MARK: - OTPPresentationLogic
extension OTPPresenter: OTPPresentationLogic {
    
    func presentResponse(_ response: OTPModel.Response) {
        
        switch response {
            
        case .OTP(let data):
            presentOTPData(data)
        case .verifyOTP(let data): presentVerifyOTP(data)
            
		case .verifyOTPPassword(data: let data):
			presentVerifyOTPPassword(data)
		}
    }
}


// MARK: - Private Zone
private extension OTPPresenter {
    
    func presentOTPData(_ data: ResultData<DefaultResponse>) {
        
        //prepare data for display and send it further
        
        viewController?.displayViewModel(.OTP(viewModelData: data))
    }
    
    func presentVerifyOTP(_ data: ResultData<VerifyOTP>) {
        
        //prepare data for display and send it further
        
        viewController?.displayViewModel(.verifyOTP(viewModelData: data))
    }
	
	func presentVerifyOTPPassword(_ data: ResultData<VerifyForgotPassword>){
		viewController?.displayViewModel(.verifyOTPPassword(viewModelData: data))
	}
}

extension OTPPresenter {
    func presentOTP(item: AuthOTPItem) {
        viewController?.displayOTP(item: item)
    }
    
    func presentOTPError(item: AuthOTPItem) {
        viewController?.displayErrorOTP(item: item)
    }
    
    func presentUpdatePhoneNumber(with result: Completion<RemoteUpdatePhoneNumber?>) {
        switch result {
        case .failure(let error):
            guard let data = error.data else {
                viewController?.displayErrorUpdatePhoneNumber(message: error.message, code: error.statusCode)
                return
            }
            
            struct Root: Codable { let code, message: String? }
            
            guard let decodeError = try? JSONDecoder().decode(Root.self, from: data) else {
                viewController?.displayErrorUpdatePhoneNumber(message: error.message, code: error.statusCode)
                return
            }
            
            viewController?.displayErrorUpdatePhoneNumber(message: decodeError.message ?? "", code: Int(decodeError.code ?? "") ?? 404)
        case .success(_):
            viewController?.displayUpdatePhoneNumber()
        }
    }
}


struct RemoteUpdatePhoneNumber: Codable {
    let code, message: String
    let data: RemoteUpdatePhoneNumberData?
}

struct RemoteUpdatePhoneNumberData: Codable {
    //PE-14294
    let userMobile: String?
}
