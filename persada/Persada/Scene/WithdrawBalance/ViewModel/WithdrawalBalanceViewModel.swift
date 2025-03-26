//
//  WithdrawalBalanceViewModel.swift
//  KipasKipas
//
//  Created by iOS Dev on 25/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import RxCocoa
import RxSwift

class WithdrawalBalanceViewModel {
    var data = BehaviorRelay<WithdrawalBalanceInfoModel?>(value: nil)
    var isLoading = BehaviorRelay<Bool?>(value: nil)
    var errorMessage = BehaviorRelay<String?>(value: nil)
    var isValidDebit = BehaviorRelay<Bool?>(value: nil)
    var isSuccessWithdrawal = BehaviorRelay<Bool?>(value: nil)
    var choiceAccountBank = BehaviorRelay<AccountDestinationModel?>(value: nil)
    var type = BehaviorRelay<TabActive>(value: .penjualan)
    var nominal = BehaviorRelay<Double?>(value: nil)
    var password = BehaviorRelay<String?>(value: nil)
    let profileUseCase = Injection.init().provideProfileUseCase()
    let withdrawFee = BehaviorRelay<Double>(value: 0)
    
    func fetchData() {
        let request = WithdrawalBalanceInfoRequest()
        isLoading.accept(true)
        
        WithdrawalBalanceOperation.info(request: request) { result in
            self.isLoading.accept(false)
            
            switch result {
            case .success(let data):
                self.data.accept(WithdrawalBalanceInfoModel(saldo: data.transactionBalance, withdrawFee: data.withdrawFee, saldoRefund: data.refundBalance))
                
            case .failure(let error):
                self.errorMessage.accept(error.statusMessage)
                
            case .error:
                self.errorMessage.accept("Failed Networking Message")
            }
        }
    }
    
    func confirmPassword(isGopay: Bool) {
        guard let password = self.password.value else { return }
        let request = VerifyPasswordRequest(password: password)
        isLoading.accept(true)
        
        WithdrawalBalanceOperation.VerifyPassword(request: request) { result in
            switch result {
            case .success(let data):
                if data {
                    self.withdrawal(isGopay: isGopay)
                } else {
                    self.errorMessage.accept("Password salah")
                    self.isLoading.accept(false)
                }
                
            case .failure(let error):
                self.errorMessage.accept(error.statusMessage)
                self.isLoading.accept(false)
                
            case .error:
                self.errorMessage.accept("Error")
                self.isLoading.accept(false)
            }
        }
    }
    
    func withdrawal(isGopay: Bool) {
        guard let nominal = nominal.value, let bankAccountId = choiceAccountBank.value?.id else { return }
        let withdrawFee = choiceAccountBank.value?.withdrawFee ?? 0.0
        let total = nominal + withdrawFee
        let request = WithdrawalBalanceRequest(nominal: Int(total), accountBalanceType: type.value.rawValue, bankAccountId: bankAccountId, isGopay: isGopay)
        isLoading.accept(true)
        WithdrawalBalanceOperation.WithdrawalBalance(request: request) { response in
            switch response {
            case .success(_):
                self.isSuccessWithdrawal.accept(true)
                
            case .failure(_):
                self.errorMessage.accept("Penarikan Gagal")
                
            case .error:
                self.errorMessage.accept("Penarikan Gagal")
            }
            self.isLoading.accept(false)
        }
    }
    
    func saveNominal(nominal: Double) -> Bool {
        if Int(nominal) < 10000 {
//            self.errorMessage.accept("Batas nominal penarikan Rp. 10.000")
            return false
        } else {
            self.nominal.accept(nominal)
            return true
        }
    }
    
    func checkInputWithdrawal(input: Double) {
        if input == 0 {
            self.isValidDebit.accept(false)
            return
        }
        
        var minimumTotal: Double = 0
        switch type.value {
        case .penjualan:
            minimumTotal = (data.value?.saldo ?? 0) - withdrawFee.value
        default:
            minimumTotal = (data.value?.saldoRefund ?? 0) - withdrawFee.value
        }
        
        if minimumTotal >= input {
            self.isValidDebit.accept(true)
        } else {
            self.isValidDebit.accept(false)
        }
    }
    
    func getMaxWithdrawal() -> String {
        var maximumTotal: Double = 0
        switch type.value {
        case .penjualan:
            maximumTotal = (data.value?.saldo ?? 0) - withdrawFee.value
        default:
            maximumTotal = (data.value?.saldoRefund ?? 0) - withdrawFee.value
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = "."
        return numberFormatter.string(from: NSNumber(value: maximumTotal)) ?? "0"
    }
}
