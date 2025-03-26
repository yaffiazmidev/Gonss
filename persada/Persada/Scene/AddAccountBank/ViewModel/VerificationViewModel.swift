//
//  VerificationViewModel.swift
//  KipasKipas
//
//  Created by iOS Dev on 30/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class VerificationViewModel {
    var bank = BehaviorRelay<AccountDestinationModel?>(value: nil)
    var isLoading = BehaviorRelay<Bool?>(value: nil)
    var errorMessage = BehaviorRelay<String?>(value: nil)
    var isSuccessRequestOtp = BehaviorRelay<Bool?>(value: nil)
    var isOtpTrue = BehaviorRelay<Bool?>(value: nil)
    
    func requestOTP() {
        self.isLoading.accept(true)
        let request = OTPRequest()
        AddAccountBankOperation.requestOTP(request: request) { result in
            self.isLoading.accept(false)
            if let data = result.value?.message {
                if data == "General Success" {
                    self.isSuccessRequestOtp.accept(true)
                } else {
                    self.errorMessage.accept(result.value?.data ?? "Request Error")
                }
            }
        }
    }
    
    func addAccountBank(otp: String) {
        guard let bankNama = bank.value?.nama, let bankNumber = bank.value?.noRek, let bankCode = bank.value?.id else {
            self.errorMessage.accept("Rekening Tidak Valid")
            return
        }
        
        guard !otp.isEmpty else {
            self.errorMessage.accept("OTP Tidak Valid")
            return
        }
        
        self.isLoading.accept(true)
        let request = AddBankRequest(bankCode: bankCode, accountName: bankNama, accountNumber: bankNumber, otpCode: otp)
        AddAccountBankOperation.addAccountBank(request: request) { result in
            self.isLoading.accept(false)
            
            if let message = result.value?.message {
                if message == "General Warning" || message == "General Error" {
                    self.errorMessage.accept(result.value?.message ?? "Error")
                } else if result.value?.code == "200" || message == "General Success" {
                    self.isOtpTrue.accept(true)
                }
            }
        }
    }
}
