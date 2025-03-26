//
//  OTPMethodOptionInteractor.swift
//  KipasKipas
//
//  Created by DENAZMI on 05/01/23.
//

import UIKit
import KipasKipasNetworking
import KipasKipasShared

protocol IOTPMethodOptionInteractor {
    var otpFrom: RequestOTPFrom? { get set }
    var phoneNumber: String { get set }
    
    func requestWhatsappOTP()
    func requestSmsOTP()
}

class OTPMethodOptionInteractor: IOTPMethodOptionInteractor {
    
    private let presenter: IOTPMethodOptionPresenter
    private let client: HTTPClient
    private let logger: NetworkErrorLogger
    private let apiService: DataTransferService
    
    var otpFrom: RequestOTPFrom?
    var phoneNumber: String = ""
    
    typealias Result = Swift.Result<AuthOTPItem, Error>
    
    init(presenter: IOTPMethodOptionPresenter, apiService: DataTransferService) {
        self.presenter = presenter
        self.client = HTTPClientFactory.makeHTTPClient()
        self.logger = DefaultNetworkErrorLogger()
        self.apiService = apiService
    }
    
    func requestWhatsappOTP() {
        
        let endpoint: Endpoint<RemoteAuthOTP?> = createEnpoint(phoneNumber: phoneNumber, platform: "WHATSAPP")
        
        apiService.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                let errorItem = self.mapAuthOTPError(error.data)
                
                self.presenter.presentWhatsappOTPError(
                    item: AuthOTPItem(expireInSecond: errorItem?.data?.expireInSecond,
                                      tryInSecond: errorItem?.data?.tryInSecond,
                                      platform: errorItem?.data?.platform ?? "",
                                      code: error.statusCode,
                                      message: errorItem?.message ?? "")
                )
            case .success(let response):
                self.presenter.presentWhatsappOTP(
                    item: AuthOTPItem(expireInSecond: response?.data?.expireInSecond,
                                      tryInSecond: response?.data?.tryInSecond,
                                      platform: response?.data?.platform ?? "",
                                      code: response?.code ?? "" == "1000" ? 200 : Int("\(response?.code ?? "")") ?? 0,
                                      message: response?.message ?? "")
                )
            }
        }
    }
    
    func requestSmsOTP() {
        
        let endpoint: Endpoint<RemoteAuthOTP?> = createEnpoint(phoneNumber: phoneNumber, platform: "SMS")
        
        apiService.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                let errorItem = self.mapAuthOTPError(error.data)
                
                self.presenter.presentSmsOTPError(
                    item: AuthOTPItem(expireInSecond: errorItem?.data?.expireInSecond,
                                      tryInSecond: errorItem?.data?.tryInSecond,
                                      platform: errorItem?.data?.platform ?? "",
                                      code: error.statusCode,
                                      message: errorItem?.message ?? "")
                )
            case .success(let response):
                self.presenter.presentSmsOTP(
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
        
        switch otpFrom {
        case .register:
            let endpoint = Endpoint<T?>(
                path: "auth/otp",
                method: .post,
                headerParamaters: ["Content-Type":"application/json"],
                bodyParamaters: [
                    "phoneNumber" : phoneNumber,
                    "platform" : platform
                ]
            )
            
            return endpoint
        case .forgotPassword:
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
        case .bankAccount:
            
            let endpoint = Endpoint<T?>(
                path: "bankaccounts/request-otp",
                method: .post,
                headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"],
                queryParameters: ["platform" : platform]
            )
            return endpoint
        case .editPhoneNumber:
            let endpoint = Endpoint<T?>(
                path: "auth/otp",
                method: .post,
                headerParamaters: ["Content-Type":"application/json"],
                bodyParamaters: [
                    "phoneNumber" : phoneNumber,
                    "type": "CHANGE_MOBILE",
                    "platform" : platform
                ]
            )
            
            return endpoint
        case .none:
            return Endpoint<T?>(path: "https://any-url.com", method: .post)
        }
    }
}
