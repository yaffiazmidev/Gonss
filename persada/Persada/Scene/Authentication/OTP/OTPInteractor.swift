//
//  OTPInteractor.swift
//  Persada
//
//  Created by monggo pesen 3 on 15/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

typealias OTPInteractable = OTPBusinessLogic & OTPDataStore

protocol OTPBusinessLogic {
    
    func doRequest(_ request: OTPModel.Request)
    func requestOTP()
    func updatePhoneNumber(code: String)
}

protocol OTPDataStore {
    var dataSource: OTPModel.DataSource { get }
    var requestOTPCount: Int { get set }
    var platform: String { get set }
    var phoneNumber: String { get set }
    var isFromEditPhoneNumber: Bool { get set }
}

final class OTPInteractor: Interactable, OTPDataStore {
    
    var dataSource: OTPModel.DataSource
    var requestOTPCount: Int = 1
    var platform: String = ""
    var phoneNumber: String = ""
    var isFromEditPhoneNumber: Bool = false
    
    var presenter: OTPPresentationLogic
    
    private var authModel: AuthNetworkModel
    
    private let apiService: DataTransferService = DIContainer.shared.defaultAPIDataTransferService
    
    init(viewController: OTPDisplayLogic?, dataSource: OTPModel.DataSource) {
        self.dataSource = dataSource
        self.presenter = OTPPresenter(viewController)
        self.authModel = AuthNetworkModel()
    }
}


// MARK: - OTPBusinessLogic
extension OTPInteractor: OTPBusinessLogic {
    
	func doRequest(_ request: OTPModel.Request) {
		DispatchQueue.global(qos: .userInitiated).async {
			
			switch request {
			
			case .OTP(let number):
                self.requestOTP(phoneNumber: number, platform: self.platform)
				
			case .verifyOTP(let code, let phoneNumber):
				if self.dataSource.isFromForgotPassword {
                    self.verifyOTPPasword(code: code, number: phoneNumber, platform: self.platform)
				}else {
                    self.verifyOTP(code, phoneNumber, platform: self.platform)
				}
			}
		}
	}
}


// MARK: - Private Zone
private extension OTPInteractor {
    
    func requestOTP(phoneNumber: String, platform: String) {
        if dataSource.isFromForgotPassword {
            authModel.requestForgotPassword(.requstForgotPassword(phoneNumber: phoneNumber, platform: platform)) { data in
                self.presenter.presentResponse(.OTP(data: data))
            }
        } else {
            authModel.requestOTP(.requestOTP(phone: phoneNumber, platform: platform)) { data in
                self.presenter.presentResponse(.OTP(data: data))
            }
        }
    }
    
    func verifyOTP(_ code: String, _ phoneNumber: String, platform: String) {
        authModel.verifyOTP(.verifyOTP(code: code, phoneNumber: phoneNumber, platform: platform)) { data in
            self.presenter.presentResponse(.verifyOTP(data: data))
        }
    }
	
	func verifyOTPPasword(code: String, number: String, platform: String){
        authModel.verifyOTPPassword(.forgotPasswordVerifyOTP(code: code, phoneNumber: number, platform: platform)) { data in
			self.presenter.presentResponse(.verifyOTPPassword(data: data))
		}
	}
    
}

extension OTPInteractor {
    
    func updatePhoneNumber(code: String) {
        let endpoint = Endpoint<RemoteUpdatePhoneNumber?>(
            path: "account/\(getIdUser())/setting/mobile",
            method: .put,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"],
            bodyParamaters: [
                "mobile": phoneNumber,
                "otpCode": code,
                "platform": platform,
                "deviceId": getDeviceId()
            ]
        )
        
        apiService.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            if case .success(_) = result {
                
                if var loginData = retrieveCredentials() {
                    if self.phoneNumber.first == "0" {
                        self.phoneNumber.removeFirst()
                        self.phoneNumber = "62\(self.phoneNumber)"
                    }
                    loginData.userMobile = self.phoneNumber
                    updateLoginData(data: loginData)
                }
            }
            self.presenter.presentUpdatePhoneNumber(with: result)
        }
    }
    
    func requestOTP() {
        
        let endpoint: Endpoint<RemoteAuthOTP?> = createEnpoint(phoneNumber: phoneNumber, platform: platform)
        
        apiService.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                let errorItem = self.mapAuthOTPError(error.data)
                
                self.presenter.presentOTPError(
                    item: AuthOTPItem(expireInSecond: errorItem?.data?.expireInSecond,
                                      tryInSecond: errorItem?.data?.tryInSecond,
                                      platform: errorItem?.data?.platform ?? "",
                                      code: error.statusCode,
                                      message: errorItem?.message ?? "")
                )
            case .success(let response):
                self.presenter.presentOTP(
                    item: AuthOTPItem(expireInSecond: response?.data?.expireInSecond,
                                      tryInSecond: response?.data?.tryInSecond,
                                      platform: response?.data?.platform ?? "",
                                      code: response?.code ?? "" == "1000" ? 200 : Int("\(response?.code ?? "")") ?? 0,
                                      message: response?.message ?? "")
                )
            }
        }
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
    
    private func createEnpoint<T: Codable>(phoneNumber: String, platform: String) -> Endpoint<T?> {
        if dataSource.isFromForgotPassword {
            let endpoint = Endpoint<T?>(
                path: "auth/forgot-password/request",
                method: .post,
                headerParamaters: ["Content-Type":"application/json"],
                bodyParamaters: [
                    "key" : phoneNumber,
                    "platform" : platform
                ]
            )
            
            return endpoint
        }
        
        let endpoint = Endpoint<T?>(
            path: "auth/otp",
            method: .post,
            headerParamaters: ["Content-Type":"application/json"],
            bodyParamaters: [
                "phoneNumber" : phoneNumber,
                "type": isFromEditPhoneNumber ? "CHANGE_MOBILE" : "REGISTER",
                "platform" : platform
            ]
        )
        
        return endpoint
    }
}
