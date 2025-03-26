//
//  MyBankAccountViewModel.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 05/10/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MyBankAccountViewModel {
    var data = BehaviorRelay<[AccountDestinationModel]>(value: [])
    var isLoading = BehaviorRelay<Bool?>(value: nil)
    var errorMessage = BehaviorRelay<String?>(value: nil)
    var choice = BehaviorRelay<AccountDestinationModel?>(value: nil)
    var select = BehaviorRelay<Int?>(value: nil)
    
    func fetchBanckAccount() {
        let request = ListBankAccountUserRequest()
        isLoading.accept(true)
        
        WithdrawalBalanceOperation.listBankUser(request: request) { result in
            self.isLoading.accept(false)

            switch result {
            case .success(let data):
                if !data.isEmpty {
                    self.data.accept(data.map({ (account) -> AccountDestinationModel in

                        return AccountDestinationModel(
                            id: account.id ?? "",
                            namaBank: account.bank?.name ?? "",
                            noRek: account.accountNumber,
                            nama: account.accountName,
                            swiftCode: account.bank?.swiftCode,
                            isSelected: false, withdrawFee: account.withdrawFee
                        )
                    }))
                } else {
                    return self.data.accept([])
                }

                if let selectIndex = self.select.value {
                    self.selectBank(index: selectIndex)
                }
            case .failure(let error):
                self.errorMessage.accept(error.statusMessage)

            case .error:
                self.errorMessage.accept("Failed Networking Message")
            }
        }
    }
    
    func selectBank(index: Int) {
        let data = self.data.value
        var dataArray = data.map{ data -> AccountDestinationModel in
            var data = data
            data.isSelected = false
            return data
        }
        dataArray[index].isSelected = true
        self.data.accept(dataArray)
        self.choice.accept(dataArray[index])
        self.select.accept(index)
    }
    
    func getBank() -> AccountDestinationModel? {
        guard let choiceData = choice.value else {
            self.errorMessage.accept("Belum memilih bank")
            return nil
        }
        
        return choiceData
    }
}
