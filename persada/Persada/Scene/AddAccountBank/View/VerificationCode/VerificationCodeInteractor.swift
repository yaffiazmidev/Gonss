//
//  VerificationCodeInteractor.swift
//  KipasKipas
//
//  Created by DENAZMI on 28/11/22.
//

import UIKit

protocol IVerificationCodeInteractor: AnyObject {
    var requestOTPCount: Int { get set }
    var bank: AccountDestinationModel? { get set }
    var platform: String { get set }
    
    func requestOTP()
    func addBankAccount(otpCode: String)
}

class VerificationCodeInteractor: IVerificationCodeInteractor {
    
    private let presenter: IVerificationCodePresenter
    private let apiService: DataTransferService
    
    var requestOTPCount: Int = 0
    var bank: AccountDestinationModel?
    var platform: String = ""
    
    init(presenter: IVerificationCodePresenter, apiService: DataTransferService) {
        self.presenter = presenter
        self.apiService = apiService
    }
    
    func requestOTP() {
        let endpoint = Endpoint<RemoteAuthOTP?>(
            path: "bankaccounts/request-otp",
            method: .post,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"],
            queryParameters: ["platform" : platform]
        )
        
        apiService.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            self.presenter.presentRequestOTP(with: result)
        }
    }
    
    func addBankAccount(otpCode: String) {
        guard let accountName = bank?.nama, let accountNumber = bank?.noRek, let bankCode = bank?.id else {
            presenter.presentFailedAddBankAccount(error: ErrorMessage(statusCode: 404, statusMessage: "General Error", statusData: "Data not found.."))
            return
        }
        
        let endpoint = Endpoint<AddAccountBankResponse?>(
            path: "bankaccounts",
            method: .post,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"],
            bodyParamaters: [
                "bankCode" : bankCode,
                "accountName" : accountName,
                "accountNumber" : accountNumber,
                "otpCode": otpCode,
                "platform": platform
            ]
        )
        apiService.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.presenter.presentFailedAddBankAccount(error: ErrorMessage(statusCode: error.statusCode, statusMessage: error.message, statusData: error.message))
            case .success(let response):
                self.presenter.presentSuccessAddBankAccount(response: response)
            }
        }
    }
}
